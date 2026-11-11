
"""HRS Agent tools: read-only, deterministic, and grounded in metadata.

Every tool in this module builds its own SQL from validated Python
arguments — the LLM never supplies raw SQL. All queries are SELECT-only.
Generated DDL/DML is text output marked DRAFT; nothing is executed here.

Query execution uses the active SparkSession when one exists (notebook,
IDE, testing) and falls back to the Databricks SDK Statement Execution API
when the agent runs on Model Serving without Spark.
"""

import re
import time

import mlflow

from src.agent import config


# ---------------------------------------------------------------------------
# Query execution (Spark when available, Statement Execution API otherwise)
# ---------------------------------------------------------------------------


def _execute_query(query):
    """Execute a SELECT-only query and return rows as a list of dicts."""

    if not isinstance(query, str) or not query.strip().lower().startswith(
        "select"
    ):
        raise ValueError("Only SELECT queries may be executed.")

    rows = _run_sql(query)

    return [dict(row) for row in rows]


def _run_sql(query):
    """Run SQL on Spark, or via the Statement Execution API on serving."""

    try:
        from pyspark.sql import SparkSession

        spark = SparkSession.getActiveSession()
    except ImportError:
        spark = None

    if spark is not None:
        return [row.asDict() for row in spark.sql(query).collect()]

    # Model Serving path (no SparkSession).
    if not config.SQL_WAREHOUSE_ID:
        raise RuntimeError(
            "Set HRS_AGENT_WAREHOUSE_ID so the agent can query metadata "
            "from a serving endpoint, or run inside a notebook with a "
            "SparkSession."
        )

    from databricks.sdk import WorkspaceClient

    workspace = WorkspaceClient()
    statement = workspace.statement_execution.execute_statement(
        statement=query,
        warehouse_id=config.SQL_WAREHOUSE_ID,
        wait_timeout="50s",
    )

    deadline = time.time() + 60
    while (
        statement.status
        and statement.status.state.name != "SUCCEEDED"
        and time.time() < deadline
    ):
        if statement.status.state.name == "FAILED":
            raise RuntimeError(
                f"Statement failed: {statement.status.error.message}"
            )
        time.sleep(1)
        statement = workspace.statement_execution.get_statement(
            statement.statement_id
        )

    if (
        not statement.status
        or statement.status.state.name != "SUCCEEDED"
    ):
        raise RuntimeError("Statement execution timed out.")

    if not statement.result:
        return []

    columns = [
        column.name
        for column in statement.manifest.schema.columns
    ]

    return [
        {
            name: (
                value if not isinstance(value, (list, tuple)) else list(value)
            )
            for name, value in zip(columns, row)
        }
        for row in (statement.result.data_array or [])
    ]


# ---------------------------------------------------------------------------
# Input helpers
# ---------------------------------------------------------------------------


def _clean_string_list(values, max_values, field_name):
    """Validate and normalize a list-of-strings tool argument."""

    if values is None:
        return None

    if not isinstance(values, (list, tuple)):
        raise ValueError(f"{field_name} must be a list of strings.")

    cleaned = [str(value).strip().upper() for value in values]

    if len(cleaned) > max_values:
        raise ValueError(
            f"{field_name} accepts at most {max_values} values."
        )

    return [value for value in cleaned if value]


def _sql_string_list(values):
    """Render a Python list as a SQL IN-list of quoted literals."""

    if not values:
        return "('')"

    return "(" + ", ".join(f"'{v}'" for v in values) + ")"


# ---------------------------------------------------------------------------
# Longitudinal variable intelligence (variant vs invariant)
# ---------------------------------------------------------------------------


_WAVE_PREFIX_PATTERN = re.compile(r"^R(\d{1,2})([A-Z]\w*)$")


def _classify_variable(name):
    """Classify an approved variable as WAVE_SPECIFIC or INVARIANT.

    Wave-specific variables follow the RAND HRS naming convention
    R{wave}{STEM} (e.g. R1BMI ... R16BMI). Everything else — including
    the all-waves respondent prefix RA (e.g. RARACEM, RAGENDER, RABYEAR)
    and household variables (e.g. HACOHORT) — is invariant.
    """

    match = _WAVE_PREFIX_PATTERN.match(name or "")

    if match and 1 <= int(match.group(1)) <= config.MAX_WAVE_NUMBER:
        return {
            "scope": "WAVE_SPECIFIC",
            "wave": int(match.group(1)),
            "stem": match.group(2),
        }

    return {"scope": "INVARIANT", "wave": None, "stem": None}


def _get_bronze_column_types(variable_names):
    """Look up actual bronze column types for the given variables.

    Used so generated silver DDL mirrors the physical source types
    instead of assuming them (e.g. RAND HRS columns are DOUBLE).
    """

    query = f"""
        SELECT UPPER(TRIM(column_name)) AS column_name, data_type
        FROM {config.BRONZE_COLUMNS_VIEW}
        WHERE table_schema = '{config.BRONZE_SOURCE_SCHEMA}'
          AND table_name = '{config.BRONZE_SOURCE_TABLE_NAME}'
          AND column_name IN {_sql_string_list(variable_names)}
    """

    return {
        row["column_name"]: row["data_type"]
        for row in _execute_query(query)
    }


def _validate_whole_number_columns(variable_names):
    """Count fractional (non-integer) values per column in bronze.

    DOUBLE -> integer casts are only lossless when the source column
    contains whole numbers, so the generator validates before casting
    rather than assuming.
    """

    expressions = [
        f"SUM(CASE WHEN {name} IS NOT NULL AND {name} != FLOOR({name}) "
        f"THEN 1 ELSE 0 END) AS fractional_{name}"
        for name in variable_names
    ]

    query = (
        "SELECT " + ", ".join(expressions)
        + " FROM " + config.BRONZE_SOURCE_TABLE
    )

    row = _execute_query(query)[0]

    return {
        name: row.get(f"fractional_{name}", 0)
        for name in variable_names
    }


def _fetch_approved_rows(use_case_name=None, codebook_version=None):
    """Fetch approved-variable rows from the metadata table."""

    use_case = use_case_name or config.ACTIVE_USE_CASE_NAME
    version = codebook_version or config.DEFAULT_CODEBOOK_VERSION

    query = f"""
        SELECT
            variable_name,
            variable_label,
            definition,
            survey_section,
            source_page,
            bronze_column_match,
            approval_status,
            use_case_name,
            codebook_version
        FROM {config.APPROVED_VARIABLES_TABLE}
        WHERE use_case_name = '{use_case}'
          AND codebook_version = '{version}'
          AND approval_status = 'Approved'
        ORDER BY variable_name
    """

    rows = _execute_query(query)

    if not rows:
        raise ValueError(
            f"No approved variables found for use case '{use_case}' "
            f"and Codebook version '{version}'."
        )

    return rows


@mlflow.trace(span_type="TOOL")
def get_variable_longitudinal_profile(
    variable_names=None,
    use_case_name=None,
    codebook_version=None,
):
    """Classify approved variables as invariant or wave-specific.

    Groups wave-specific variables into families (stem, naming pattern,
    wave range) and lists invariant attributes. This is the authority for
    longitudinal structure claims.
    """

    requested = _clean_string_list(
        variable_names, config.MAX_RESULT_ROWS, "variable_names"
    )

    rows = _fetch_approved_rows(use_case_name, codebook_version)

    if requested:
        requested_lower = {name.lower() for name in requested}
        rows = [
            row
            for row in rows
            if row["variable_name"].lower() in requested_lower
        ]

        if not rows:
            return {
                "ok": True,
                "message": (
                    "None of the requested variables are approved for "
                    "this use case. Treat them as candidates requiring "
                    "review."
                ),
                "families": [],
                "invariant_variables": [],
            }

    families = {}
    invariant_variables = []

    for row in rows:
        classification = _classify_variable(row["variable_name"])

        entry = {
            "variable_name": row["variable_name"],
            "variable_label": row.get("variable_label"),
            "source_page": row.get("source_page"),
            "bronze_column_match": row.get("bronze_column_match"),
        }

        if classification["scope"] == "WAVE_SPECIFIC":
            stem = classification["stem"]
            family = families.setdefault(
                stem,
                {
                    "measure_stem": stem,
                    "scope": "WAVE_SPECIFIC",
                    "naming_pattern": f"R{{wave}}{stem}",
                    "waves": [],
                    "variables": [],
                    "variable_label": row.get("variable_label"),
                    "source_page": row.get("source_page"),
                    "bronze_column_match": row.get("bronze_column_match"),
                },
            )
            family["waves"].append(classification["wave"])
            family["variables"].append(row["variable_name"])
        else:
            entry["scope"] = "INVARIANT"
            invariant_variables.append(entry)

    family_list = []

    for family in families.values():
        waves = sorted(set(family["waves"]))
        family["waves"] = waves
        family["wave_start"] = waves[0] if waves else None
        family["wave_end"] = waves[-1] if waves else None
        family["wave_count"] = len(waves)
        family_list.append(family)

    return {
        "ok": True,
        "use_case_name": rows[0]["use_case_name"],
        "codebook_version": rows[0]["codebook_version"],
        "families": family_list,
        "invariant_variables": invariant_variables,
    }


@mlflow.trace(span_type="TOOL")
def get_approved_variables(
    variable_names=None,
    use_case_name=None,
    codebook_version=None,
):
    """List approved variables with labels, evidence, and bronze matches."""

    requested = _clean_string_list(
        variable_names, config.MAX_RESULT_ROWS, "variable_names"
    )

    rows = _fetch_approved_rows(use_case_name, codebook_version)

    if requested:
        requested_lower = {name.lower() for name in requested}
        rows = [
            row
            for row in rows
            if row["variable_name"].lower() in requested_lower
        ]

    return {
        "ok": True,
        "count": len(rows),
        "variables": rows[: config.MAX_RESULT_ROWS],
    }


# ---------------------------------------------------------------------------
# Codebook retrieval
# ---------------------------------------------------------------------------


@mlflow.trace(span_type="TOOL")
def search_codebook(
    search_terms=None,
    codebook_version=None,
):
    """Keyword-search the RAND HRS Codebook pages and return excerpts.

    Semantic chunk search is reserved for when hrs_document_chunks is
    populated; today this searches the full page text.
    """

    if not isinstance(search_terms, (list, tuple)) or not search_terms:
        raise ValueError("search_terms must be a non-empty list of strings.")

    terms = [
        str(term).strip()
        for term in search_terms[: config.MAX_SEARCH_TERMS]
        if str(term).strip()
    ]

    if not terms:
        raise ValueError("search_terms contained no usable terms.")

    version = codebook_version or config.DEFAULT_CODEBOOK_VERSION
    like_clauses = " OR ".join(
        f"page_text ILIKE '%{term.replace(chr(39), '')}%'" for term in terms
    )

    query = f"""
        SELECT page_number, page_text
        FROM {config.DOCUMENT_PAGES_TABLE}
        WHERE document_id = '{config.CODEBOOK_DOCUMENT_ID}'
          AND codebook_version = '{version}'
          AND ({like_clauses})
        ORDER BY page_number
        LIMIT 20
    """

    rows = _execute_query(query)

    results = []

    for row in rows:
        text = row["page_text"] or ""
        lowered = text.lower()
        hits = sum(lowered.count(term.lower()) for term in terms)

        first_position = min(
            (
                lowered.find(term.lower())
                for term in terms
                if lowered.find(term.lower()) >= 0
            ),
            default=-1,
        )

        if first_position > 0:
            start = max(0, first_position - 150)
            excerpt = text[start : start + config.MAX_CODEBOOK_SNIPPET_CHARS]
        else:
            excerpt = text[: config.MAX_CODEBOOK_SNIPPET_CHARS]

        results.append(
            {
                "page_number": row["page_number"],
                "term_hits": hits,
                "excerpt": excerpt,
            }
        )

    results.sort(key=lambda item: item["term_hits"], reverse=True)

    return {
        "ok": True,
        "codebook_version": version,
        "results": results[: config.MAX_CODEBOOK_PAGES],
    }


@mlflow.trace(span_type="TOOL")
def get_codebook_pages(
    page_numbers,
    document_id=None,
    codebook_version=None,
):
    """Retrieve full Codebook pages by page number."""

    if not isinstance(page_numbers, (list, tuple)) or not page_numbers:
        raise ValueError("page_numbers must be a non-empty list of integers.")

    pages = sorted(
        {
            int(page)
            for page in page_numbers[: config.MAX_CODEBOOK_PAGES]
        }
    )

    if not pages or min(pages) < 1:
        raise ValueError("page_numbers must be positive integers.")

    document = document_id or config.CODEBOOK_DOCUMENT_ID
    version = codebook_version or config.DEFAULT_CODEBOOK_VERSION

    query = f"""
        SELECT page_number, page_text
        FROM {config.DOCUMENT_PAGES_TABLE}
        WHERE document_id = '{document}'
          AND codebook_version = '{version}'
          AND page_number IN {_sql_string_list(str(p) for p in pages)}
        ORDER BY page_number
    """

    rows = _execute_query(query)

    return {
        "ok": True,
        "pages": [
            {
                "page_number": row["page_number"],
                "text": (row["page_text"] or "")[
                    : config.MAX_CODEBOOK_SNIPPET_CHARS
                ],
            }
            for row in rows
        ],
    }


# ---------------------------------------------------------------------------
# Coverage and source validation
# ---------------------------------------------------------------------------


@mlflow.trace(span_type="TOOL")
def get_cohort_coverage(
    variable_names=None,
    use_case_name=None,
    codebook_version=None,
    wave_number=None,
):
    """Summarize variable coverage by wave and HRS cohort."""

    requested = _clean_string_list(
        variable_names, config.MAX_RESULT_ROWS, "variable_names"
    )

    use_case = use_case_name or config.ACTIVE_USE_CASE_NAME
    version = codebook_version or config.DEFAULT_CODEBOOK_VERSION

    filters = [
        f"use_case_name = '{use_case}'",
        f"codebook_version = '{version}'",
    ]

    if requested:
        filters.append(
            f"variable_name IN {_sql_string_list(requested)}"
        )

    if wave_number is not None:
        if isinstance(wave_number, bool) or not isinstance(wave_number, int):
            raise ValueError("wave_number must be an integer.")
        filters.append(f"wave_number = {wave_number}")

    query = f"""
        SELECT
            variable_name,
            wave_number,
            COUNT(*) AS cohort_count,
            SUM(CASE WHEN coverage_status = 'HAS_DATA' THEN 1 ELSE 0 END)
                AS cohorts_with_data,
            SUM(non_null_record_count) AS total_non_null_records
        FROM {config.COHORT_COVERAGE_TABLE}
        WHERE {' AND '.join(filters)}
        GROUP BY variable_name, wave_number
        ORDER BY variable_name, wave_number
    """

    rows = _execute_query(query)

    return {
        "ok": True,
        "count": len(rows),
        "coverage": rows[: config.MAX_RESULT_ROWS],
    }


@mlflow.trace(span_type="TOOL")
def validate_source_variables(
    variable_names=None,
    use_case_name=None,
    codebook_version=None,
):
    """Check whether approved variables match bronze source columns."""

    requested = _clean_string_list(
        variable_names, config.MAX_RESULT_ROWS, "variable_names"
    )

    rows = _fetch_approved_rows(use_case_name, codebook_version)

    variables = [row["variable_name"] for row in rows]

    if requested:
        requested_lower = {name.lower() for name in requested}
        variables = [
            name for name in variables if name.lower() in requested_lower
        ]

    query = f"""
        SELECT UPPER(TRIM(column_name)) AS column_name
        FROM {config.BRONZE_COLUMNS_VIEW}
        WHERE table_schema = '{config.BRONZE_SOURCE_SCHEMA}'
          AND table_name = '{config.BRONZE_SOURCE_TABLE_NAME}'
          AND column_name IN {_sql_string_list(variables)}
    """

    found = {row["column_name"] for row in _execute_query(query)}

    results = [
        {
            "variable_name": name,
            "bronze_column_match": name in found,
        }
        for name in variables
    ]

    matched = sum(1 for item in results if item["bronze_column_match"])

    return {
        "ok": True,
        "bronze_source_table": config.BRONZE_SOURCE_TABLE,
        "total": len(results),
        "matched": matched,
        "unmatched": [
            item["variable_name"]
            for item in results
            if not item["bronze_column_match"]
        ],
        "results": results,
    }


# ---------------------------------------------------------------------------
# Warehouse artifact generation (routed against the Silver CDM / Gold star)
# ---------------------------------------------------------------------------


def _get_cdm_column_map():
    """Build a column -> table routing map from the live Silver CDM.

    Queries the catalog information_schema for the project's CDM tables
    (dim_cohort, hub_respondent, dim_wave, fact_demographics,
    fact_health, fact_leave_behind) so approved variables are routed to
    the tables that already store them instead of new parallel ones.
    """

    tables_sql = ", ".join(
        f"'{table}'" for table in config.CDM_TABLE_ROLES
    )

    query = f"""
        SELECT LOWER(table_name) AS table_name,
            LOWER(column_name) AS column_name
        FROM {config.CATALOG_COLUMNS_VIEW}
        WHERE table_schema = '{config.SILVER_CDM_SCHEMA}'
          AND LOWER(table_name) IN ({tables_sql})
    """

    column_map = {}

    for row in _execute_query(query):
        column_map.setdefault(row["column_name"], row["table_name"])

    if not column_map:
        raise RuntimeError(
            "Silver CDM tables were not found in "
            f"{config.METADATA_CATALOG}.{config.SILVER_CDM_SCHEMA}. "
            "Routing requires the project data model to exist — run "
            "the repo's sql/ddl/ and sql/dml/ scripts first."
        )

    return column_map


def _get_dim_wave_years():
    """Wave -> year mapping from the CDM's dim_wave (curated values).

    dim_wave.wave_year is hand-curated (e.g. wave 2 = '1993' because HRS
    fielding windows span two calendar years), so wave years must be
    read from the dimension — never computed with a 1992 + 2*(n-1)
    formula.
    """

    query = (
        f"SELECT wave_number, wave_year FROM "
        f"{config.METADATA_CATALOG}.{config.SILVER_CDM_SCHEMA}.dim_wave "
        "ORDER BY wave_number"
    )

    rows = _execute_query(query)

    if not rows:
        raise RuntimeError(
            "dim_wave is empty — load it (sql/dml/load_hrs_wave_data.sql) "
            "before generating artifacts."
        )

    return {
        str(row["wave_number"]): str(row["wave_year"]) for row in rows
    }


def _load_scripts_for_tables(tables):
    """Map routed CDM tables to the repo load scripts that populate them."""

    scripts = {}

    for table in sorted(set(tables)):
        if table in config.CDM_LOAD_SCRIPTS:
            scripts[table] = config.CDM_LOAD_SCRIPTS[table]

    return scripts


@mlflow.trace(span_type="TOOL")
def generate_warehouse_artifacts(
    use_case_name=None,
    target_layer="silver",
    catalog=None,
):
    """Route approved variables against the project Silver CDM / Gold star.

    The data model (docs/Data Model/Silver_CDM_Data_Model.ipynb) defines
    five entities — dim_cohort, hub_respondent, dim_wave,
    fact_demographics, fact_health — plus the fact_leave_behind
    extension. This tool maps every approved variable to the CDM column
    that already stores it. When everything routes (the normal case) it
    returns a COVERAGE REPORT pointing at the repo load scripts that
    already move the data and generates no SQL. DDL/DML drafts are
    produced only for variables with no home in the model, and follow
    the repo's own templates (multi-value UNPIVOT loads with
    hub_respondent/dim_wave FK resolution, audit columns, gold
    star-join aggregates via vw_dim_wave / vw_dim_cohort).

    All output is DRAFT text requiring human review. Nothing is executed.
    """

    if target_layer not in ("silver", "gold"):
        raise ValueError("target_layer must be 'silver' or 'gold'.")

    use_case = use_case_name or config.ACTIVE_USE_CASE_NAME
    target_catalog = catalog or config.METADATA_CATALOG

    profile = get_variable_longitudinal_profile(use_case_name=use_case)

    families = profile["families"]
    invariant = profile["invariant_variables"]

    if not families:
        raise ValueError(
            "No wave-specific variable families found; cannot route this "
            "use case against the longitudinal CDM."
        )

    column_map = _get_cdm_column_map()

    routed = []
    report_only = []
    gaps = []

    for family in families:
        stem = family["measure_stem"]
        table = column_map.get(stem.lower())

        entry = {
            "kind": "WAVE_SPECIFIC_FAMILY",
            "variable_pattern": f"R{{wave}}{stem}",
            "measure_stem": stem.lower(),
            "waves": family["waves"],
            "cdm_table": table,
        }

        if table:
            entry["table_role"] = config.CDM_TABLE_ROLES.get(
                table, "silver table"
            )
            routed.append(entry)
        else:
            gaps.append(entry)

    for entry in invariant:
        name = entry["variable_name"]
        table = column_map.get(name.lower())

        result = {
            "kind": "INVARIANT",
            "variable": name,
            "cdm_table": table,
        }

        if table:
            result["table_role"] = config.CDM_TABLE_ROLES.get(
                table, "silver table"
            )
            routed.append(result)
        elif name.upper() in config.EQUIVALENT_COLUMN_NOTES:
            result["note"] = config.EQUIVALENT_COLUMN_NOTES[
                name.upper()
            ]
            report_only.append(result)
        else:
            gaps.append(result)

    artifacts = {
        "use_case_name": use_case,
        "target_layer": target_layer,
        "data_model": (
            "Silver CDM 5-entity model: dim_cohort -> hub_respondent -> "
            "fact_demographics / fact_health <- dim_wave "
            "(plus fact_leave_behind extension)"
        ),
        "routed": routed,
        "report_only": report_only,
        "unrouted": gaps,
        "load_scripts": _load_scripts_for_tables(
            [item["cdm_table"] for item in routed]
        ),
    }

    if not gaps:
        artifacts["status"] = "COVERAGE_REPORT"
        artifacts["notes"] = [
            "Every approved variable already has a home in the Silver "
            "CDM — no new tables or loads are required for this use "
            "case.",
            "The repo load scripts above already move this data. Gold "
            "aggregates build on the silver facts with the star-join "
            "pattern (see "
            "sql/gold_dml/load_fact_hrs_bmi_stats_data.sql).",
            "Before publishing reports that decode cohort codes, run "
            "the codebook label cross-check "
            "(generate_codebook_label_dimension).",
        ]
        return artifacts

    artifacts["status"] = "DRAFT_REVIEW_REQUIRED"

    gap_families = [
        item for item in gaps if item["kind"] == "WAVE_SPECIFIC_FAMILY"
    ]
    gap_invariants = [
        item for item in gaps if item["kind"] == "INVARIANT"
    ]

    if target_layer == "silver":
        if gap_families:
            artifacts.update(
                _generate_silver_gap_artifacts(
                    use_case=use_case,
                    catalog=target_catalog,
                    families=gap_families,
                    invariants=gap_invariants,
                )
            )
        else:
            # Invariant-only gaps are structural modeling decisions the
            # agent does not auto-draft. Flag them for hub / dimension
            # review instead of raising, so the coverage report for the
            # homed variables still returns.
            artifacts["status"] = "INVARIANT_GAP_REVIEW_REQUIRED"
            for item in gap_invariants:
                item["note"] = (
                    "invariant gap — belongs in hub / dimension modeling "
                    "review (e.g., add the column to hub_respondent / "
                    "fact_demographics scripts and deploy); not "
                    "auto-drafted. Once deployed, routing picks it up "
                    "from the live schema."
                )
    else:
        artifacts.update(
            _generate_gold_gap_artifacts(
                use_case=use_case,
                catalog=target_catalog,
                families=gap_families,
            )
        )

    return artifacts


def _generate_silver_gap_artifacts(
    use_case,
    catalog,
    families,
    invariants,
):
    """Render DRAFT silver DDL/DML for variables with no CDM home.

    Follows the repo's own templates: create_hrs_leave_behind.sql for
    the DDL (identity surrogate key, hub_respondent / dim_wave FKs,
    audit columns, UNIQUE (respondent_id, wave_id)) and
    load_hrs_health_data.sql for the DML (one-pass multi-value UNPIVOT
    from the wide bronze table, TRY_CAST types, INNER-JOIN FK
    resolution, insert-only after TRUNCATE).
    """

    if not families:
        raise ValueError(
            "Silver gap drafting requires wave-specific families with "
            "no CDM home; invariant-only gaps belong in hub / dimension "
            "review."
        )

    table_stem = re.sub(r"[^a-z0-9]+", "_", use_case.lower()).strip("_")
    table_name = (
        f"{catalog}.{config.SILVER_CDM_SCHEMA}.fact_{table_stem}"
    )
    key_column = f"fact_{table_stem}_id"

    # Whole-number scan decides TINYINT (categorical codes) vs
    # DECIMAL(10, 2) (continuous measures) per family, mirroring the
    # repo's TRY_CAST type discipline.
    probe_names = [
        f"R{family['waves'][0]}{family['measure_stem']}"
        for family in families
    ]

    fractional_counts = _validate_whole_number_columns(probe_names)

    type_notes = []
    family_types = {}

    for family in families:
        probe = (
            f"R{family['waves'][0]}{family['measure_stem']}"
        ).upper()

        if fractional_counts.get(probe, 1) == 0:
            family_types[family["measure_stem"]] = "TINYINT"
            type_notes.append(
                f"{family['measure_stem']}: whole-number scan clean — "
                "TINYINT (categorical-code treatment)."
            )
        else:
            family_types[family["measure_stem"]] = "DECIMAL(10, 2)"
            type_notes.append(
                f"{family['measure_stem']}: fractional values present — "
                "DECIMAL(10, 2) (continuous-measure treatment)."
            )

    measure_lines = [
        f"    {family['measure_stem'].lower()} "
        f"{family_types[family['measure_stem']]} COMMENT 'R#"
        f"{family['measure_stem']}: "
        f"{family.get('variable_label') or family['measure_stem']}'"
        for family in families
    ]

    # Group families by identical wave sets: each group becomes one
    # multi-value UNPIVOT (partial fielding, e.g. waves 8-16 only, is
    # preserved per group the way fact_leave_behind handles it).
    wave_groups = {}

    for family in families:
        wave_groups.setdefault(
            tuple(family["waves"]), []
        ).append(family)

    source_select = ["        SELECT HHIDPN"]

    for wave_key, group in wave_groups.items():
        for wave in wave_key:
            source_select.append(
                "            "
                + ", ".join(
                    f"R{wave}{family['measure_stem']}"
                    for family in group
                )
            )

    source_select.append(
        f"        FROM {config.BRONZE_SOURCE_TABLE}"
    )

    source_sql = ",\n".join(source_select)

    group_ctes = []
    first_group_names = None

    for index, (wave_key, group) in enumerate(
        wave_groups.items(), start=1
    ):
        names = [family["measure_stem"].lower() for family in group]
        names_sql = ", ".join(names)

        if first_group_names is None:
            first_group_names = names

        value_tuples = ",\n".join(
            "                    ("
            + ", ".join(
                f"R{wave}{family['measure_stem']}"
                for family in group
            )
            + ") AS `" + str(wave) + "`"
            for wave in wave_key
        )

        group_ctes.append(
            f"    wave_group_{index} AS (\n"
            f"        SELECT HHIDPN, wave_number, {names_sql}\n"
            f"        FROM source_base\n"
            f"        UNPIVOT INCLUDE NULLS (\n"
            f"                ({names_sql}) FOR wave_number IN (\n"
            f"{value_tuples}\n"
            f"                )\n"
            f"        )\n"
            f"    )"
        )

    groups_sql = ",\n".join(group_ctes)

    if len(wave_groups) == 1:
        unpivot_cte = ""
        unpivot_source = "wave_group_1 u"
    else:
        extra_columns = []

        for index, group in enumerate(wave_groups.values(), 1):
            if index == 1:
                continue

            extra_columns.extend(
                f"g{index}.{family['measure_stem'].lower()}"
                for family in group
            )

        joins = "\n".join(
            f"        LEFT JOIN wave_group_{i} g{i} "
            f"ON g1.HHIDPN = g{i}.HHIDPN "
            f"AND g1.wave_number = g{i}.wave_number"
            for i in range(2, len(wave_groups) + 1)
        )

        extra_sql = (
            ", " + ", ".join(extra_columns)
            if extra_columns
            else ""
        )

        unpivot_cte = (
            "    ,wave_unpivoted AS (\n"
            "        SELECT g1.HHIDPN, g1.wave_number, "
            + ", ".join(f"g1.{name}" for name in first_group_names)
            + extra_sql
            + "\n        FROM wave_group_1 g1\n"
            + joins
            + "\n    )"
        )
        unpivot_source = "wave_unpivoted u"

    measure_columns = [stem.lower() for stem in family_types]

    measure_casts = ",\n        ".join(
            f"TRY_CAST(u.{name} AS "
            f"{family_types[name.upper()]}) AS {name}"
            for name in measure_columns
        )

    ddl = (
        "-- DRAFT — generated for variables with no home in the Silver CDM\n"
        f"-- Use case: {use_case}\n"
        "-- Template: sql/ddl/create_hrs_leave_behind.sql "
        "(fact extension pattern)\n"
        f"DROP TABLE IF EXISTS {table_name};\n"
        "--\n"
        f"CREATE TABLE {table_name} (\n"
        "    -- ---------------------------------------------------------------\n"
        "    -- Identity Column\n"
        "    -- ---------------------------------------------------------------\n"
        f"    {key_column} BIGINT GENERATED ALWAYS AS IDENTITY "
        "COMMENT 'System-generated surrogate key',\n"
        "    -- ---------------------------------------------------------------\n"
        "    -- Foreign Keys\n"
        "    -- ---------------------------------------------------------------\n"
        "    respondent_id BIGINT NOT NULL "
        "COMMENT 'Foreign key to hub_respondent.respondent_id',\n"
        "    wave_id BIGINT NOT NULL "
        "COMMENT 'Foreign key to dim_wave.wave_id',\n"
        "    -- ---------------------------------------------------------------\n"
        "    -- Identifier Columns\n"
        "    -- ---------------------------------------------------------------\n"
        "    hhidpn BIGINT NOT NULL "
        "COMMENT 'Household Respondent Identifier',\n"
        "    wave_number STRING NOT NULL COMMENT 'Wave Number',\n"
        "    -- ---------------------------------------------------------------\n"
        "    -- Business Columns (gap variables; no existing CDM home)\n"
        "    -- ---------------------------------------------------------------\n"
        + ",\n".join(measure_lines)
        + ",\n"
        "    -- ---------------------------------------------------------------\n"
        "    -- Audit Columns\n"
        "    -- ---------------------------------------------------------------\n"
        "    create_date DATE NOT NULL "
        "COMMENT 'Record creation date',\n"
        "    update_date DATE NOT NULL "
        "COMMENT 'Last update date',\n"
        "    active BOOLEAN NOT NULL "
        "COMMENT 'Active indicator',\n"
        "    -- ---------------------------------------------------------------\n"
        "    -- Constraints\n"
        "    -- ---------------------------------------------------------------\n"
        f"    CONSTRAINT pk_{table_stem} PRIMARY KEY ({key_column}),\n"
        f"    CONSTRAINT fk_{table_stem}_hub_respondent FOREIGN KEY "
        f"(respondent_id) REFERENCES "
        f"{catalog}.{config.SILVER_CDM_SCHEMA}.hub_respondent "
        "(respondent_id),\n"
        f"    CONSTRAINT fk_{table_stem}_dim_wave FOREIGN KEY (wave_id) "
        f"REFERENCES {catalog}.{config.SILVER_CDM_SCHEMA}.dim_wave "
        "(wave_id),\n"
        f"    CONSTRAINT uq_{table_stem}_respondent_wave UNIQUE "
        "(respondent_id, wave_id)\n"
        f") USING DELTA COMMENT 'DRAFT gap fact for use case {use_case} "
        "— review name and placement (extension pattern per "
        "fact_leave_behind)';\n"
    )

    insert_columns = "\n".join(
        "        " + name + "," for name in measure_columns
    )

    dml = (
        "-- DRAFT — generated for variables with no home in the Silver CDM\n"
        f"-- Use case: {use_case}\n"
        "-- Template: sql/dml/load_hrs_health_data.sql "
        "(multi-value UNPIVOT + FK resolution)\n"
        f"TRUNCATE TABLE {table_name};\n"
        "--\n"
        f"INSERT INTO {table_name}\n"
        "(\n"
        "        respondent_id,\n"
        "        wave_id,\n"
        "        hhidpn,\n"
        "        wave_number,\n"
        + insert_columns
        + "\n        create_date,\n"
        "        update_date,\n"
        "        active\n"
        "    ) WITH source_base AS (\n"
        + source_sql
        + "\n    ),\n"
        + groups_sql
        + unpivot_cte
        + "\n    SELECT r.respondent_id,\n"
        "        w.wave_id,\n"
        "        u.HHIDPN AS hhidpn,\n"
        "        u.wave_number,\n"
        "        "
        + measure_casts
        + ",\n"
        "        CURRENT_DATE() AS create_date,\n"
        "        CURRENT_DATE() AS update_date,\n"
        "        TRUE AS active\n"
        f"    FROM {unpivot_source}\n"
        f"        INNER JOIN "
        f"{catalog}.{config.SILVER_CDM_SCHEMA}.hub_respondent r\n"
        "            ON u.HHIDPN = r.HHIDPN\n"
        f"        INNER JOIN "
        f"{catalog}.{config.SILVER_CDM_SCHEMA}.dim_wave w\n"
        "            ON u.wave_number = w.wave_number\n"
    )

    notes = type_notes + [
        "Table name is a placeholder (fact_<use-case-stem>) — rename to "
        "the repo's semantic section convention (fact_health, "
        "fact_leave_behind) at review.",
        "Wave years come from dim_wave.wave_year (curated), never a "
        "formula; dim_wave also holds 'A' and 'E' reference rows that "
        "will never match a UNPIVOT wave alias.",
    ]

    if invariants:
        notes.append(
            "Invariant gap variables "
            + ", ".join(item["variable"] for item in invariants)
            + " have no CDM home and were NOT drafted — they need a "
            "hub / dimension decision by the model owner."
        )

    return {
        "target_layer": "silver",
        "table_name": table_name,
        "grain": "one row per respondent per wave (CDM fact pattern)",
        "gap_families": [
            family["measure_stem"] for family in families
        ],
        "ddl": ddl,
        "dml": dml,
        "notes": notes,
    }


def _generate_gold_gap_artifacts(
    use_case,
    catalog,
    families,
):
    """Render DRAFT gold DDL/DML for gap families (star-join pattern).

    Follows sql/gold_ddl/create_fact_hrs_bmi_stats.sql and
    sql/gold_dml/load_fact_hrs_bmi_stats_data.sql: cohort_id / wave_id
    FKs to dim_hrs_cohort / dim_hrs_wave, aggregate stats per measure,
    audit columns, TRUNCATE + INSERT star-join through hub_respondent,
    vw_dim_wave and vw_dim_cohort with active = TRUE filters.
    """

    if not families:
        raise ValueError(
            "Gold gap drafting requires wave-specific families with no "
            "CDM home."
        )

    table_stem = re.sub(r"[^a-z0-9]+", "_", use_case.lower()).strip("_")
    silver_table = (
        f"{catalog}.{config.SILVER_CDM_SCHEMA}.fact_{table_stem}"
    )
    table_name = (
        f"{catalog}.{config.GOLD_STAR_SCHEMA}.fact_hrs_{table_stem}"
    )
    key_column = f"fact_hrs_{table_stem}_id"

    stat_lines = []
    stat_casts = []
    stat_columns = []

    for family in families:
        stem = family["measure_stem"].lower()
        stat_columns.extend(
            [
                f"{stem}_count",
                f"{stem}_mean",
                f"{stem}_sd",
                f"{stem}_min",
                f"{stem}_max",
            ]
        )
        stat_lines.extend(
            [
                f"    {stem}_count INT "
                f"COMMENT 'Total records for {stem.upper()}'",
                f"    {stem}_mean DOUBLE COMMENT 'Mean {stem.upper()}'",
                f"    {stem}_sd DOUBLE "
                f"COMMENT 'StdDev {stem.upper()}'",
                f"    {stem}_min INT COMMENT 'Min {stem.upper()}'",
                f"    {stem}_max INT COMMENT 'Max {stem.upper()}'",
            ]
        )
        stat_casts.extend(
            [
                f"CAST(COUNT(*) AS INT) AS {stem}_count",
                f"CAST(AVG(h.{stem}) AS DOUBLE) AS {stem}_mean",
                f"CAST(STDDEV(h.{stem}) AS DOUBLE) AS {stem}_sd",
                f"CAST(MIN(h.{stem}) AS INT) AS {stem}_min",
                f"CAST(MAX(h.{stem}) AS INT) AS {stem}_max",
            ]
        )

    stat_sql = ",\n".join(stat_lines)
    insert_stats = ",\n        ".join(
        name + "," for name in stat_columns
    )
    stat_cast_sql = ",\n    ".join(stat_casts)
    where_sql = "\n    AND ".join(
        f"h.{family['measure_stem'].lower()} IS NOT NULL"
        for family in families
    )

    ddl = (
        "-- DRAFT — generated for variables with no home in the CDM\n"
        f"-- Use case: {use_case}\n"
        "-- Template: sql/gold_ddl/create_fact_hrs_bmi_stats.sql\n"
        f"DROP TABLE IF EXISTS {table_name};\n"
        "--\n"
        f"CREATE TABLE {table_name} (\n"
        "    -- ---------------------------------------------------------------\n"
        "    -- Identity Column\n"
        "    -- ---------------------------------------------------------------\n"
        f"    {key_column} BIGINT GENERATED ALWAYS AS IDENTITY "
        "COMMENT 'System-generated surrogate key',\n"
        "    -- ---------------------------------------------------------------\n"
        "    -- Foreign Keys\n"
        "    -- ---------------------------------------------------------------\n"
        "    cohort_id BIGINT NOT NULL "
        "COMMENT 'Foreign key to dim_hrs_cohort.cohort_id',\n"
        "    wave_id BIGINT NOT NULL "
        "COMMENT 'Foreign key to dim_hrs_wave.wave_id',\n"
        "    -- ---------------------------------------------------------------\n"
        "    -- Business Columns\n"
        "    -- ---------------------------------------------------------------\n"
        "    hacohort INT,\n"
        + stat_sql
        + ",\n"
        "    -- ---------------------------------------------------------------\n"
        "    -- Audit Columns\n"
        "    -- ---------------------------------------------------------------\n"
        "    create_date DATE NOT NULL "
        "COMMENT 'Record creation date',\n"
        "    update_date DATE NOT NULL "
        "COMMENT 'Last update date',\n"
        "    active BOOLEAN NOT NULL "
        "COMMENT 'Active indicator',\n"
        "    -- ---------------------------------------------------------------\n"
        "    -- Constraints\n"
        "    -- ---------------------------------------------------------------\n"
        f"    CONSTRAINT pk_{table_stem} PRIMARY KEY ({key_column}),\n"
        f"    CONSTRAINT fk_{table_stem}_dim_hrs_cohort FOREIGN KEY "
        f"(cohort_id) REFERENCES "
        f"{catalog}.{config.GOLD_STAR_SCHEMA}.dim_hrs_cohort "
        "(cohort_id),\n"
        f"    CONSTRAINT fk_{table_stem}_dim_hrs_wave FOREIGN KEY "
        f"(wave_id) REFERENCES "
        f"{catalog}.{config.GOLD_STAR_SCHEMA}.dim_hrs_wave (wave_id)\n"
        f") USING DELTA COMMENT 'DRAFT gold gap fact for use case "
        f"{use_case}';\n"
    )

    dml = (
        "-- DRAFT — generated for variables with no home in the CDM\n"
        f"-- Use case: {use_case}\n"
        "-- Template: sql/gold_dml/load_fact_hrs_bmi_stats_data.sql "
        "(star join)\n"
        f"TRUNCATE TABLE {table_name};\n"
        "--\n"
        f"INSERT INTO {table_name}\n"
        "(\n"
        "        cohort_id,\n"
        "        wave_id,\n"
        "        hacohort,\n"
        + insert_stats
        + "\n        create_date,\n"
        "        update_date,\n"
        "        active\n"
        "    )\n"
        "SELECT dc.cohort_id,\n"
        "    dw.wave_id,\n"
        "    r.hacohort,\n"
        "    "
        + stat_cast_sql
        + ",\n"
        "        CURRENT_DATE() AS create_date,\n"
        "        CURRENT_DATE() AS update_date,\n"
        "        TRUE AS active\n"
        f"FROM {silver_table} h\n"
        f"    INNER JOIN "
        f"{catalog}.{config.SILVER_CDM_SCHEMA}.hub_respondent r\n"
        "        ON h.respondent_id = r.respondent_id\n"
        f"    INNER JOIN "
        f"{catalog}.{config.GOLD_STAR_SCHEMA}.vw_dim_wave dw\n"
        "        ON h.wave_id = dw.wave_id\n"
        f"    INNER JOIN "
        f"{catalog}.{config.GOLD_STAR_SCHEMA}.vw_dim_cohort dc\n"
        "        ON r.cohort_id = dc.cohort_id\n"
        "WHERE "
        + where_sql
        + "\n    AND h.active = TRUE\n"
        "    AND r.active = TRUE\n"
        "GROUP BY dw.wave_id,\n"
        "    dc.cohort_id,\n"
        "    r.hacohort\n"
        "ORDER BY dw.wave_id,\n"
        "    dc.cohort_id;\n"
    )

    return {
        "target_layer": "gold",
        "table_name": table_name,
        "grain": "one row per cohort per wave (gold star pattern)",
        "gap_families": [
            family["measure_stem"] for family in families
        ],
        "ddl": ddl,
        "dml": dml,
        "notes": [
            "Wave -> year reference is dim_wave.wave_year (curated "
            "values, e.g. wave 2 = '1993'); never derive years by "
            "formula.",
            "This draft exists only because the measure has no silver "
            "CDM home; check the existing gold facts "
            "(fact_hrs_bmi_stats, analytic_hrs_bmi_race_gender_stats) "
            "before adding a new one.",
            "The DML reads the silver gap draft first — generate and "
            f"run {silver_table} before this table.",
        ],
    }


# ---------------------------------------------------------------------------
# Codebook label cross-check (parsed labels vs. CDM dimensions)
# ---------------------------------------------------------------------------

_CODE_ENTRY_RE = re.compile(
    r"(?m)^\s*(\d+)\.([^\n|]+?)\s*\n\s*\|\s*\n\s*(\d+)\s*$"
)

_MISSING_ENTRY_RE = re.compile(
    r"(?m)^\s*\.([A-Za-z0-9]+)=([^\n|]+?)\s*\n\s*\|\s*\n\s*(\d+)\s*$"
)

# Next variable header, e.g. 'SwGENDER: Gender' — names may mix upper,
# lower (Sw = spouse-by-wave), and digits (S1GENDER).
_NEXT_SECTION_HEADER_RE = re.compile(r"(?m)^[A-Za-z0-9]+\s*:")


@mlflow.trace(span_type="TOOL")
def generate_codebook_label_dimension(
    use_case_name=None,
    codebook_version=None,
    catalog=None,
):
    """Cross-check Codebook categorical labels against the CDM dimensions.

    Parses the Codebook's 'Categorical Variable Codes' sections
    (format: 'code.label', newline, '|', newline, 'frequency') for the
    use case's categorical variables, then compares the parsed labels
    with the curated labels actually used in the warehouse:

      - HACOHORT is compared against dim_cohort (live query, falling
        back to the curated CASE labels from
        sql/dml/load_hrs_cohort_data.sql when the table is not
        queryable).
      - Other categorical variables (e.g. RAGENDER, RARACEM) are
        reported as reference data for display layers, since the CDM
        stores them as numeric codes by design.

    Returns a cross-check report (MATCH / CONSISTENT / REVIEW /
    MISSING_IN_DIM / REFERENCE_ONLY statuses) — no DDL/DML is
    generated, because the model's dimensions already own label
    storage.
    """

    use_case = use_case_name or config.ACTIVE_USE_CASE_NAME
    version = codebook_version or config.DEFAULT_CODEBOOK_VERSION
    target_catalog = catalog or config.METADATA_CATALOG

    profile = get_variable_longitudinal_profile(use_case_name=use_case)

    categorical = [
        entry["variable_name"].upper()
        for entry in profile["invariant_variables"]
        if "YEAR" not in entry["variable_name"].upper()
    ]

    if not categorical:
        raise ValueError(
            "No categorical invariant variables found for this use case."
        )

    notes = []
    label_rows = []

    for variable in categorical:
        page_rows = _execute_query(
            f"""
            SELECT page_number, page_text
            FROM {config.DOCUMENT_PAGES_TABLE}
            WHERE page_text LIKE '%Categorical Variable Codes%'
              AND page_text LIKE '%{variable}:%'
            ORDER BY page_number
            """
        )

        entries = []

        for page_row in page_rows:
            text = page_row["page_text"]

            header = re.search(
                rf"(?m)^\s*{re.escape(variable)}\s*:", text
            )

            if header is None:
                continue

            rest = text[header.end():]
            next_header = _NEXT_SECTION_HEADER_RE.search(rest)
            section = rest[: next_header.start()] if next_header else rest

            entries.extend(
                {
                    "variable_name": variable,
                    "code_value": int(match.group(1)),
                    "label": match.group(2).strip(),
                    "source_frequency": int(match.group(3)),
                    "source_page": page_row["page_number"],
                }
                for match in _CODE_ENTRY_RE.finditer(section)
            )

            entries.extend(
                {
                    "variable_name": variable,
                    "code_value": None,
                    "label": (
                        f"{match.group(1)}="
                        f"{match.group(2).strip()} (missing marker)"
                    ),
                    "source_frequency": int(match.group(3)),
                    "source_page": page_row["page_number"],
                }
                for match in _MISSING_ENTRY_RE.finditer(section)
            )

            if entries:
                break

        if not entries:
            notes.append(
                f"{variable}: no categorical-codes section found; "
                "no labels generated — review manually."
            )
            continue

        label_rows.extend(entries)

    seen = set()
    deduped_rows = []

    for row in label_rows:
        key = (row["variable_name"], row["code_value"], row["label"])

        if key not in seen:
            seen.add(key)
            deduped_rows.append(row)

    # -- Cross-check against the curated warehouse labels -----------

    dim_labels = {}
    dim_source = "live dim_cohort query"

    try:
        dim_rows = _execute_query(
            f"""
            SELECT hacohort_number, hacohort_label
            FROM {target_catalog}.{config.SILVER_CDM_SCHEMA}.dim_cohort
            ORDER BY hacohort_number
            """
        )
        dim_labels = {
            int(row["hacohort_number"]): row["hacohort_label"]
            for row in dim_rows
        }
    except Exception:
        dim_labels = {}

    if not dim_labels:
        dim_labels = dict(config.DIM_COHORT_CURATED_LABELS)
        dim_source = (
            "curated labels from sql/dml/load_hrs_cohort_data.sql "
            "(dim_cohort empty or not queryable)"
        )

    def _normalized(text):
        return re.sub(r"[^A-Z0-9]", "", str(text or "").upper())

    def _compare(curated, codebook):
        left = _normalized(curated)
        right = _normalized(codebook)

        if not left or not right:
            return "REVIEW"

        if left == right:
            return "MATCH"

        if left in right or right in left:
            return "CONSISTENT"

        return "REVIEW"

    cross_check = []

    for row in deduped_rows:
        variable = row["variable_name"]

        if variable == "HACOHORT" and row["code_value"] is not None:
            code = row["code_value"]
            curated = dim_labels.get(code)
            status = (
                "MISSING_IN_DIM"
                if curated is None
                else _compare(curated, row["label"])
            )
            cross_check.append(
                {
                    "variable": variable,
                    "code": code,
                    "codebook_label": row["label"],
                    "warehouse_label": curated,
                    "status": status,
                }
            )
        else:
            cross_check.append(
                {
                    "variable": variable,
                    "code": row["code_value"],
                    "codebook_label": row["label"],
                    "warehouse_label": None,
                    "status": "REFERENCE_ONLY",
                }
            )

    status_counts = {}

    for item in cross_check:
        status_counts[item["status"]] = (
            status_counts.get(item["status"], 0) + 1
        )

    hacohort_needs_review = any(
        item["status"] in ("REVIEW", "MISSING_IN_DIM")
        for item in cross_check
        if item["variable"] == "HACOHORT"
    )

    review_format = (
        "# CODEBOOK LABEL CROSS-CHECK — HUMAN REVIEW\n\n"
        f"Use case: {use_case}\n"
        f"Codebook version: {version}\n"
        f"Categorical variables: {', '.join(categorical)}\n"
        f"Comparison source: {dim_source}\n\n"
        "## Status legend\n"
        "- MATCH: label text identical after normalization\n"
        "- CONSISTENT: one label abbreviates the other (e.g. the "
        "curated '0-HRS/AHEAD' vs. the Codebook 'Hrs/Ahead ovrlap')\n"
        "- REVIEW: labels differ materially — the model owner decides "
        "which is authoritative\n"
        "- MISSING_IN_DIM: the Codebook code has no dim_cohort row\n"
        "- REFERENCE_ONLY: variable is stored as numeric codes in the "
        "CDM; labels are reference data for display layers\n\n"
        "## Cross-check results\n"
        + "\n".join(
            f"- {item['variable']} code {item['code']}: "
            f"[{item['status']}] Codebook "
            f"'{item['codebook_label']}'"
            + (
                f" vs warehouse '{item['warehouse_label']}'"
                if item["warehouse_label"] is not None
                else ""
            )
            for item in cross_check
        )
        + "\n\n"
        "## Generator notes\n"
        + "\n".join(
            [f"- {note}" for note in notes]
            + [
                "- "
                + (
                    "Some HACOHORT labels need review — see the "
                    "cross_check statuses."
                    if hacohort_needs_review
                    else "All HACOHORT labels align with the warehouse "
                    "dimensions."
                )
            ]
        )
        + "\n\n"
        "## After review\n"
        "Label corrections belong in sql/dml/load_hrs_cohort_data.sql "
        "(curated CASE labels) — the CDM dimensions own label storage; "
        "no new reference table is created."
    )

    return {
        "ok": True,
        "status": "CROSS_CHECK_REPORT",
        "variables": categorical,
        "comparison_source": dim_source,
        "label_rows": deduped_rows,
        "cross_check": cross_check,
        "status_counts": status_counts,
        "notes": notes,
        "review_format": review_format,
    }


# ---------------------------------------------------------------------------
# Human review display (copy-and-paste process)
# ---------------------------------------------------------------------------


@mlflow.trace(span_type="TOOL")
def display_draft_artifacts(
    use_case_name=None,
    target_layer="silver",
    catalog=None,
):
    """Render artifact output in a copy-paste-ready review format.

    Returns either a COVERAGE REPORT (all approved variables already
    live in the Silver CDM — nothing to copy) or DRAFT gap DDL/DML for
    variables with no CDM home.

    Review process: the agent displays the draft SQL with a review
    checklist; a human reviews it and copies the approved SQL into the
    bundle's sql/ folders (sql/ddl/, sql/dml/, sql/gold_ddl/,
    sql/gold_dml/), then commits through the normal Git + CI workflow.
    The agent never writes files and never executes SQL.
    """

    artifacts = generate_warehouse_artifacts(
        use_case_name=use_case_name,
        target_layer=target_layer,
        catalog=catalog,
    )

    if artifacts.get("status") == "COVERAGE_REPORT":
        routing_lines = []

        for item in artifacts.get("routed", []):
            name = item.get("variable_pattern") or item.get("variable")
            target_column = (
                item.get("measure_stem") or name.lower()
            )
            routing_lines.append(
                f"- {name} -> {item['cdm_table']}.{target_column} "
                f"({item['table_role']})"
            )

        for item in artifacts.get("report_only", []):
            routing_lines.append(
                f"- {item['variable']} -> covered by equivalent "
                f"({item['note']})"
            )

        script_lines = [
            f"- {table}: {script}"
            for table, script in artifacts.get("load_scripts", {}).items()
        ]

        review_format = (
            "# COVERAGE REPORT — NO NEW SQL REQUIRED\n\n"
            "The Silver CDM already stores every approved variable for "
            f"use case {artifacts.get('use_case_name')}.\n"
            f"Data model: {artifacts.get('data_model')}\n\n"
            "## Variable routing\n"
            + "\n".join(routing_lines)
            + "\n\n"
            "## Repo load scripts that already move this data\n"
            + ("\n".join(script_lines) if script_lines else "- (none)")
            + "\n\n"
            "## Review checklist\n"
            + "\n".join(
                f"- [ ] {item}"
                for item in [
                    "Confirm the routed tables and columns match the "
                    "use case intent.",
                    "Confirm the listed load scripts are part of the "
                    "orchestration job.",
                    "Run generate_codebook_label_dimension to "
                    "cross-check cohort labels before publishing "
                    "decoded reports.",
                ]
            )
            + "\n\n"
            "## Generator notes\n"
            + "\n".join(
                f"- {note}" for note in artifacts.get("notes", [])
            )
        )

        return {
            "ok": True,
            "status": "COVERAGE_REPORT",
            "target_layer": target_layer,
            "use_case_name": artifacts.get("use_case_name"),
            "review_format": review_format,
        }

    if target_layer == "silver":
        destination = (
            "hrs_dbx_repo/sql/ddl/ (DDL) and hrs_dbx_repo/sql/dml/ (DML)"
        )
    else:
        destination = (
            "hrs_dbx_repo/sql/gold_ddl/ (DDL) and "
            "hrs_dbx_repo/sql/gold_dml/ (DML)"
        )

    checklist = [
        "Gap variables genuinely have no home in the 5-entity Silver "
        "CDM (dim_cohort, hub_respondent, dim_wave, fact_demographics, "
        "fact_health) — the routing report lists what already routed.",
        "Table name and placement follow the repo convention "
        "(fact_<section>; this is an extension like fact_leave_behind).",
        "DDL matches the create_hrs_* template: identity surrogate key, "
        "hub_respondent / dim_wave FK constraints, audit columns, "
        "UNIQUE (respondent_id, wave_id).",
        "DML matches the load_hrs_* template: one-pass multi-value "
        "UNPIVOT from bronze, TRY_CAST types, INNER-JOIN FK resolution "
        "to hub_respondent and dim_wave, insert-only after TRUNCATE.",
        "Types follow the whole-number scan (TINYINT for categorical "
        "codes, DECIMAL(10, 2) for continuous measures) — see notes.",
        "Wave coverage: verify the UNPIVOT wave list against cohort "
        "coverage results; dim_wave also holds 'A' and 'E' reference "
        "rows that will never match a wave alias.",
    ]

    if target_layer == "gold":
        checklist.append(
            "Gold star pattern: cohort_id / wave_id FKs to "
            "dim_hrs_cohort / dim_hrs_wave, aggregates via "
            "vw_dim_wave / vw_dim_cohort with active = TRUE filters "
            "(see load_fact_hrs_bmi_stats_data.sql)."
        )

    notes = artifacts.get("notes") or []

    review_format = (
        f"# DRAFT {target_layer.upper()} GAP ARTIFACTS — HUMAN REVIEW REQUIRED\n\n"
        f"Status: DRAFT_REVIEW_REQUIRED — not executed, not saved to disk.\n"
        f"Target table: {artifacts.get('table_name')}\n\n"
        "## Review checklist (complete before copying)\n"
        + "\n".join(f"- [ ] {item}" for item in checklist)
        + "\n\n"
        "## DDL — copy below after review\n"
        f"```sql\n{artifacts['ddl']}\n```\n\n"
        "## DML — copy below after review\n"
        f"```sql\n{artifacts['dml']}\n```\n\n"
        "## Generator notes\n"
        + "\n".join(f"- {note}" for note in notes)
        + "\n\n"
        "## After review\n"
        f"Copy the reviewed SQL into {destination} in the repo, then "
        "commit through the normal Git + CI workflow. Execution happens "
        "only through the deployed bundle's orchestration job."
    )

    return {
        "ok": True,
        "status": "DRAFT_REVIEW_REQUIRED",
        "target_layer": target_layer,
        "table_name": artifacts.get("table_name"),
        "review_format": review_format,
    }


# ---------------------------------------------------------------------------
# Visualization and dashboard recommendations
# ---------------------------------------------------------------------------


@mlflow.trace(span_type="TOOL")
def recommend_visualizations(
    use_case_name=None,
    codebook_version=None,
):
    """Recommend visualizations grounded in approved-variable roles.

    Rules of thumb applied:
    - Wave-specific measures -> trends over waves, distributions, and
      demographic segment comparisons.
    - Invariant categoricals -> grouping and segmentation.
    - Coverage metadata -> data-availability heatmaps.
    """

    profile = get_variable_longitudinal_profile(
        use_case_name=use_case_name,
        codebook_version=codebook_version,
    )

    families = profile["families"]
    invariant = profile["invariant_variables"]

    invariant_names = {
        entry["variable_name"]: entry for entry in invariant
    }

    recommendations = []

    for family in families:
        stem = family["measure_stem"]
        label = family.get("variable_label") or stem

        recommendations.extend(
            [
                {
                    "title": f"Mean {stem} trend by wave",
                    "chart_type": "line",
                    "x": "wave (survey year)",
                    "y": f"avg_{stem.lower()}",
                    "group_by": None,
                    "rationale": (
                        f"{stem} is wave-specific "
                        f"({family['naming_pattern']}, waves "
                        f"{family['wave_start']}-{family['wave_end']}), so "
                        "a longitudinal trend is the primary story."
                    ),
                    "suggested_source": "gold fact table",
                },
                {
                    "title": f"Mean {stem} trend by race and gender",
                    "chart_type": "line",
                    "x": "wave (survey year)",
                    "y": f"avg_{stem.lower()}",
                    "group_by": "raracem, ragender",
                    "rationale": (
                        "Approved invariant dimensions (RARACEM, RAGENDER) "
                        "segment the longitudinal trend."
                    ),
                    "suggested_source": "gold fact table",
                },
                {
                    "title": f"{stem} distribution by wave",
                    "chart_type": "box",
                    "x": "wave",
                    "y": f"{stem.lower()}",
                    "group_by": "hacohort (small multiples)",
                    "rationale": (
                        "Distribution plots reveal cohort composition "
                        "shifts across waves beyond the mean."
                    ),
                    "suggested_source": "silver person-wave table",
                },
            ]
        )

    if "HACOHORT" in invariant_names:
        recommendations.append(
            {
                "title": f"Respondents per wave by cohort",
                "chart_type": "stacked_bar",
                "x": "wave",
                "y": "respondent_count",
                "group_by": "hacohort",
                "rationale": (
                    "Cohort composition of the sample changes across "
                    "waves; useful context for any trend chart."
                ),
                "suggested_source": "gold fact table",
            }
        )

    if families:
        recommendations.append(
            {
                "title": "Variable coverage heatmap",
                "chart_type": "heatmap",
                "x": "wave_number",
                "y": "variable_name",
                "group_by": "coverage (cohorts with data)",
                "rationale": (
                    "Coverage metadata shows where data exists before "
                    "interpreting trends as population change."
                ),
                "suggested_source": (
                    "hrs_use_case_approved_cohort_coverage metadata table"
                ),
            }
        )

    dashboard = {
        "suggested_layout": [
            "KPI row: latest-wave mean measure, respondent count, "
            "cohort count",
            "Primary trend: mean measure by wave",
            "Segmentation: trend by race and gender",
            "Distribution: box plot by wave",
            "Context: cohort composition stacked bar and coverage heatmap",
        ],
        "recommended_tooling": (
            "AI/BI dashboard on the gold fact table; Genie space on "
            "silver/gold tables for conversational follow-ups."
        ),
    }

    return {
        "ok": True,
        "use_case_name": profile.get("use_case_name"),
        "recommendations": recommendations,
        "dashboard_guidance": dashboard,
    }
