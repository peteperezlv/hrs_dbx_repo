"""Log and deploy the HRS Agent to Model Serving.

Run this from a notebook whose working directory is the repo root
(hrs_dbx_repo) after smoke-testing the agent:

    import sys, os
    sys.path.insert(0, os.getcwd())
    %run ./src/agent/deploy_agent.py

Prerequisites
- A SQL warehouse ID in HRS_AGENT_WAREHOUSE_ID (serving-time queries
  use the Statement Execution API because Model Serving has no Spark).
- USE/SELECT on the hrs_agent_metadata tables for the deploying user.

Deployment (via the Mosaic AI agents SDK) creates the serving endpoint,
Review App, and AI Gateway inference logging. Deploying is a
workspace-level operation — review before running.
"""

import os
import sys

import mlflow

from databricks import agents

from src.agent.agent import HRSAgent


MODEL_NAME = "hrs_dbx_agent"
ENDPOINT_NAME = "hrs_dbx_agent_endpoint"
EXPERIMENT_NAME = "/Users/peteperez.lv@gmail.com/hrs_agent_development"


def log_and_deploy(model_version_note="initial HRS agent"):
    """Log the pyfunc agent model, register it, and deploy the endpoint."""

    mlflow.set_experiment(EXPERIMENT_NAME)

    with mlflow.start_run() as run:
        logged = mlflow.pyfunc.log_model(
            name="hrs_agent",
            python_model=HRSAgent(),
            pip_requirements=[
                "mlflow",
                "databricks-sdk",
            ],
        )

        mlflow.log_param("model_version_note", model_version_note)

        registered = mlflow.register_model(
            f"runs:/{run.info.run_id}/hrs_agent",
            MODEL_NAME,
        )

    deployment = agents.deploy(
        ENDPOINT_NAME,
        registered.version,
        environment_vars={
            "HRS_AGENT_WAREHOUSE_ID": os.environ.get(
                "HRS_AGENT_WAREHOUSE_ID", ""
            ),
            "MLFLOW_TRACKING_URI": "databricks",
        },
        tags={"use_case": "hrs_data_warehouse_assistant"},
    )

    return {
        "run_id": run.info.run_id,
        "model_version": registered.version,
        "endpoint_name": ENDPOINT_NAME,
        "deployment": deployment,
    }


if __name__ == "__main__" or "__file__" not in globals():
    # Notebook execution path (dbutils runs scripts as __main__ without
    # __file__). Deploy only when explicitly requested.
    if os.environ.get("HRS_AGENT_DEPLOY") == "1":
        result = log_and_deploy()
        print(result)
    else:
        print(
            "Import log_and_deploy() and call it explicitly to deploy. "
            "Set HRS_AGENT_WAREHOUSE_ID first."
        )
