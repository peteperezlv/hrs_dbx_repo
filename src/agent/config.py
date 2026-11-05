"""Central configuration for the HRS Databricks Agent.

All table locations, model endpoints, and behavioral limits are defined
here so the agent can be re-pointed at staging or prod catalogs without
code changes. Values can be overridden with environment variables.
"""

import os


# ---------------------------------------------------------------------------
# Unity Catalog locations
# ---------------------------------------------------------------------------

METADATA_CATALOG = os.environ.get("HRS_METADATA_CATALOG", "dev_catalog")
METADATA_SCHEMA = "hrs_agent_metadata"

# Approved-variable authority (which variables may be used, per use case)
APPROVED_VARIABLES_TABLE = (
    f"{METADATA_CATALOG}.{METADATA_SCHEMA}.hrs_use_case_approved_variables"
)

# Reviewable candidates extracted from the RAND HRS Codebook
VARIABLE_REVIEW_TABLE = (
    f"{METADATA_CATALOG}.{METADATA_SCHEMA}.hrs_variable_review"
)

# Codebook page store (2,133 pages of RAND HRS 1992-2022v1 text)
DOCUMENT_PAGES_TABLE = (
    f"{METADATA_CATALOG}.{METADATA_SCHEMA}.hrs_document_pages"
)

# Codebook chunks (reserved for semantic search; currently empty)
DOCUMENT_CHUNKS_TABLE = (
    f"{METADATA_CATALOG}.{METADATA_SCHEMA}.hrs_document_chunks"
)

# Computed variable coverage by wave and HRS cohort
COHORT_COVERAGE_TABLE = (
    f"{METADATA_CATALOG}.{METADATA_SCHEMA}."
    "hrs_use_case_approved_cohort_coverage"
)

# Wide longitudinal bronze source (~19,880 columns)
BRONZE_SOURCE_TABLE = os.environ.get(
    "HRS_BRONZE_TABLE",
    "dev_catalog.brz_raw_hrs.randhrs1992_2022v1",
)

# information_schema view used to validate bronze columns
BRONZE_COLUMNS_VIEW = f"{METADATA_CATALOG}.information_schema.columns"
BRONZE_SOURCE_SCHEMA = "brz_raw_hrs"
BRONZE_SOURCE_TABLE_NAME = "randhrs1992_2022v1"

# Warehouse used by the Statement Execution API when no SparkSession exists
# (required only when the agent runs on Model Serving).
SQL_WAREHOUSE_ID = os.environ.get("HRS_AGENT_WAREHOUSE_ID", "")


# ---------------------------------------------------------------------------
# Silver CDM / Gold star routing (the project's canonical data model)
# ---------------------------------------------------------------------------

SILVER_CDM_SCHEMA = "slv_cdm_hrs"
GOLD_STAR_SCHEMA = "gld_star_hrs"

# information_schema view used to route approved variables to CDM columns
CATALOG_COLUMNS_VIEW = f"{METADATA_CATALOG}.information_schema.columns"

# Canonical 5-entity Silver CDM (docs/Data Model/Silver_CDM_Data_Model.ipynb)
# plus the fact_leave_behind extension. Roles describe what each entity owns.
CDM_TABLE_ROLES = {
    "dim_cohort": "cohort reference (HACOHORT codes + curated labels)",
    "hub_respondent": (
        "respondent hub (invariant person identity and demographics keys)"
    ),
    "dim_wave": (
        "wave reference (curated wave_year; includes 'A'/'E' rows)"
    ),
    "fact_demographics": "person-wave demographic measures",
    "fact_health": "person-wave health measures (BMI, weight, height, ...)",
    "fact_leave_behind": "end-of-life extension (waves 8-16)",
}

# Repo load scripts that already populate each routed CDM table
CDM_LOAD_SCRIPTS = {
    "dim_cohort": "sql/dml/load_hrs_cohort_data.sql",
    "hub_respondent": "sql/dml/load_hrs_respondent_data.sql",
    "dim_wave": "sql/dml/load_hrs_wave_data.sql",
    "fact_demographics": "sql/dml/load_hrs_demographics_data.sql",
    "fact_health": "sql/dml/load_hrs_health_data.sql",
    "fact_leave_behind": "sql/dml/load_hrs_leave_behind_data.sql",
}

# Approved variables covered by an equivalent CDM column rather than their
# own name — reported in the coverage report, never drafted as new columns.
EQUIVALENT_COLUMN_NOTES = {
    "RABYEAR": (
        "covered by fact_health.agey_e (end-of-life age); RABYEAR itself "
        "is not stored as a separate CDM column"
    ),
}

# Curated HACOHORT labels from sql/dml/load_hrs_cohort_data.sql — the
# fallback when dim_cohort cannot be queried for the label cross-check.
DIM_COHORT_CURATED_LABELS = {
    0: "0-HRS/AHEAD",
    1: "1-HRS/AHEAD",
    2: "CODA",
    3: "HRS",
    4: "WB",
    5: "EBB",
    6: "MBB",
    7: "LBB",
    8: "EGENX",
}


# ---------------------------------------------------------------------------
# Project defaults
# ---------------------------------------------------------------------------

DEFAULT_USE_CASE_NAME = (
    "bmi_statistics_by_wave_race_gender_age_cohort"
)
DEFAULT_CODEBOOK_VERSION = "1992-2022v1"

# Use case this agent run targets. Override with the HRS_AGENT_USE_CASE
# environment variable when a new use case is approved — no code changes.
# Per-call tool arguments always take precedence over this value.
ACTIVE_USE_CASE_NAME = os.environ.get(
    "HRS_AGENT_USE_CASE", DEFAULT_USE_CASE_NAME
)
CODEBOOK_DOCUMENT_ID = "rand_hrs_longitudinal_codebook"

# Longitudinal grain columns
PERSON_KEY_COLUMN = "HHIDPN"
COHORT_COLUMN = "HACOHORT"
WAVE_COLUMN = "WAVE"

# RAND HRS longitudinal waves are biennial (wave 1 = 1992 ... wave 16 =
# 2022), but the wave-to-year mapping is curated in dim_wave.wave_year
# and must never be derived by formula.
MAX_WAVE_NUMBER = 16


# ---------------------------------------------------------------------------
# Model and loop limits
# ---------------------------------------------------------------------------

LLM_ENDPOINT = os.environ.get(
    "HRS_AGENT_LLM_ENDPOINT", "databricks-gpt-oss-120b"
)

MAX_TOOL_ROUNDS = int(os.environ.get("HRS_AGENT_MAX_TOOL_ROUNDS", "8"))
MAX_RESULT_ROWS = int(os.environ.get("HRS_AGENT_MAX_RESULT_ROWS", "100"))
MAX_CODEBOOK_PAGES = int(os.environ.get("HRS_AGENT_MAX_CODEBOOK_PAGES", "5"))
MAX_SEARCH_TERMS = 5
MAX_CODEBOOK_SNIPPET_CHARS = 1200

# The agent never executes generated DDL/DML. Artifacts are DRAFT output
# that a human must review and approve through the existing bundle workflow.
EXECUTION_MODE = "REVIEW_ONLY"
