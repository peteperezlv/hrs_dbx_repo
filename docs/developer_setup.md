## Path Conventions

| Context                                               | Path base                 | Example                                  |
| ----------------------------------------------------- | ------------------------- | ---------------------------------------- |
| GitHub Actions (`ci.yml`, `cd.yml`)                   | Repository root           | `sql/ddl/create_hrs_cohort.sql`          |
| Databricks Asset Bundle (`resources/hrs_etl_job.yml`) | Location of the YAML file | `../notebooks/setup/...`                 |
| Python notebooks                                      | Location of the notebook  | `../../sql/dml/load_hrs_cohort_data.sql` |

---

## What I built with ChatGPT

# Over the course of this project, I've created:

- Project structure
- GitHub repository
- Databricks Repo
- VS Code integration
- Reusable folder structure

# Reusable framework

- SQL DDL scripts
- SQL DML scripts
- Validation SQL
- sql_utils.py
- Notebook orchestration

# Asset Bundle

- databricks.yml
- hrs_etl_job.yml
- Bundle validation
- Bundle deployment

# GitHub Actions

# CI

- Repository validation
- SQL validation
- Notebook validation
- Python syntax validation
- Databricks connectivity
- Bundle validation

# CD

- Deploy Asset Bundle
- Execute Databricks Workflow
- Build Silver tables

That is a professional foundation.
