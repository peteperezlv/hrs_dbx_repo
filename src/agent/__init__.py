"""HRS Databricks Agent package.

Usage (from a notebook attached to this repo folder):

    from src.agent.agent import run_agent

    result = run_agent(
        "Explain the longitudinal structure of the approved BMI "
        "variables and recommend visualizations."
    )
    print(result["answer"])
"""