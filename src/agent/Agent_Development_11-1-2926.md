### What was built — src/agent/ (all Databricks-native patterns)
* config.py — all table locations, endpoints, limits; env-var overridable for staging/prod
* prompts.py — system prompt grounded in your approved-variable authority and REVIEW_ONLY execution policy
* hrs_tools.py — 8 tools covering all 6 features: longitudinal profile (variant/invariant), approved variables, Codebook keyword search + page retrieval, cohort coverage, bronze source validation, deterministic silver/gold DDL+DML generation (person-wave grain, HHIDPN + wave), visualization recommendations
* agent.py — MLflow-gateway tool-calling loop on databricks-gpt-oss-120b with MLflow tracing, plus a pyfunc wrapper for Model Serving
* deploy_agent.py — log_and_deploy() creates the serving endpoint, Review App, and inference logging via the agents SDK

Key design kept from your ChatGPT version: the model proposes, Python validates and controls — the LLM never supplies SQL; tools build SELECTs from validated args, and DDL/DML is DRAFT text only.

### Verified end-to-end
* Longitudinal profile correctly identifies R{wave}BMI (waves 1–16) vs. invariant RARACEM/RAGENDER/RABYEAR/HACOHORT
* All 20 approved variables match bronze columns; Codebook search finds the BMI definition (page 574)
* Two full agent runs: one answered the structure + dashboard question via 3 grounded tool calls; the second generated the silver DDL draft with review guidance. Traces logged to MLflow.

### Housekeeping
* Six stray blank files landed in /Workspace/Users/peteperez.lv@gmail.com/src/agent/ during creation (path mishap) — safe to delete that folder.
* Files aren't committed to Git yet, and the serving endpoint isn't deployed (deployment is a workspace-level operation — run log_and_deploy() with HRS_AGENT_WAREHOUSE_ID set when you're ready).

### Inputs
run_agent(user_message, context=None, max_tool_rounds=None) — a plain-text question, e.g. "Explain the longitudinal structure of my BMI variables and recommend visualizations."

* context — optional reference data injected into the prompt as read-only data
* Everything else comes from config.py: tables, endpoint (databricks-gpt-oss-120b), limits, EXECUTION_MODE = REVIEW_ONLY
* Environment variables (HRS_METADATA_CATALOG, HRS_BRONZE_TABLE, HRS_AGENT_LLM_ENDPOINT, HRS_AGENT_WAREHOUSE_ID) re-point it at staging/prod with zero code changes.

#### What the agent reads
| Location | Used by | Purpose |
|----------|---------|---------|
| `dev_catalog.hrs_agent_metadata.hrs_use_case_approved_variables` | approved vars, longitudinal profile, artifact generation, source validation | Authority for which variables may be used (20 rows) |
| `dev_catalog.hrs_agent_metadata.hrs_document_pages` | Codebook search + page retrieval | 2,133 pages of RAND HRS Codebook text |
| `dev_catalog.hrs_agent_metadata.hrs_use_case_approved_cohort_coverage` | cohort coverage tool | Variable coverage by wave × cohort (180 rows) |
| `dev_catalog.hrs_agent_metadata.hrs_variable_review` / `hrs_variable_candidates` / `hrs_document_chunks` / `hrs_document_processing_runs` | reserved | Not queried by the current tools (chunks table is empty) |
| `dev_catalog.information_schema.columns` | source validation | Confirms approved variables exist as bronze columns |
| `dev_catalog.brz_raw_hrs.randhrs1992_2022v1` | referenced in generated DML (not queried by tools) | ~19,880-column wide bronze source |
| `databricks-gpt-oss-120b` endpoint | agent loop | LLM via MLflow gateway |

### Processing
1. Prompt build (prompts.py) — the system prompt is rendered from config and enforces 9 rules: approved-variable authority, Codebook evidence, source validation, no invented definitions, no execution
2. Tool-calling loop (agent.py) — the message goes to the LLM through the MLflow gateway. The model returns either a final answer or tool calls
3. Allowlisted execution — each tool call is checked against TOOL_HANDLERS (8 registered tools, anything else rejected), arguments parsed as JSON, then executed. The LLM never supplies SQL — every query is built deterministically in hrs_tools.py, and only SELECTs are allowed
4. Loop — tool results are fed back as tool messages (max 8 rounds) until the model produces a grounded final answer. Every request and tool call is MLflow-traced

The 8 tools map to your features: longitudinal profile (variant/invariant classification via the R{wave}STEM regex), approved variables, Codebook search + page retrieval, cohort coverage, bronze source validation, silver/gold DDL/DML generation, and visualization recommendations.

### Outputs
A dict: answer (grounded text, e.g. the BMI family table + chart recommendations), model, usage (token counts), tool_calls (audit trail), execution_mode. DDL/DML comes back as DRAFT text with review notes — never executed by the agent.

Two run modes for the same code: SparkSession when run in a notebook (how we tested it), or the Statement Execution API on Model Serving once deployed — that path needs HRS_AGENT_WAREHOUSE_ID.

#### what the agent produces
* In-memory result dict — answer, model, usage, tool_calls audit, execution_mode. 
* Nothing is written to disk.
* DRAFT DDL/DML text (silver/gold) — returned in the answer; intended destination is your existing hrs_dbx_repo/sql/ddl/, sql/dml/, sql/gold_ddl/, sql/gold_dml/ folders after human review. The agent never writes there itself.
* MLflow traces — every request/tool call, viewable in the MLflow Traces UI.
* On deployment only (not yet run): MLflow model hrs_dbx_agent in experiment /Users/peteperez.lv@gmail.com/hrs_agent_development, plus serving endpoint hrs_dbx_agent_endpoint — created by log_and_deploy() in deploy_agent.py.