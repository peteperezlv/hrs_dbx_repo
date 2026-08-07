# HRS Databricks Data Warehouse Deployment

## Overview

This repository contains the Databricks Asset Bundle used to deploy
the HRS data warehouse development environment.

## Deployment Flow

                GitHub (feature branch)
                         │
                         ▼
                GitHub Actions (CI)
                         │
      ┌──────────────────┴──────────────────┐
      │                                     │
      │ Validate repository                 │
      │ Check Python syntax                 │
      │ Validate Asset Bundle               │
      └──────────────────┬──────────────────┘
                         │
                         ▼
                GitHub Actions (CD)
                         │
                         ▼
            Databricks Asset Bundle Deploy
                         │
                         ▼
            Databricks Workflow (hrs_etl_job)
                         │
           ┌─────────────┴─────────────┐
           ▼                           ▼

Create HRS Tables Load Reference Data
│ │
└─────────────┬─────────────┘
▼
Unity Catalog
dev_catalog.slv_cdm_hrs

## Local Deployment

Local deployment works works with OAuth by using the hrs-dev profile.

Initiate OAuth to connect to local databricks workspace. This will take you to the google authentication method.

- databricks auth login --host https://dbc-17f8770d-ed78.cloud.databricks.com

Show the Databricks Config: you should see a config for "[hrs-dev] wtih Auth Type = databricks-cli (after you Initiate the OAuth to connect)". The path is c:/users/pete/.databrickscfg.

- databricks auth profiles or
- cat ~./databrickscfg or
- type $HOME\.databrickscfg

Validate:

- databricks bundle validate --profile hrs-dev

Run deployment commands in PowerShell.

- databricks bundle deploy --profile hrs-dev

Run a bundle resource like /resources/hrs_etl_job

- databricks bundle run hrs_etl_job --profile hrs-dev

## GitHub Deployment

GitHub deployment requires additional Workspace APIs, including writing files under: /Workspace/Users/.../.bundle/
For this reason, we must setup a Personal Access Token (PAT) with sufficient permissions.

## Workflow

Checkout Repository
│
▼
Install Databricks CLI
│
▼
Connect to Databricks
│
▼
Bundle Deploy
│
▼
Run HRS ETL Job
│
▼
Success

---

# Create a Personal Access Token in Databricks

Databricks User -> Settings -> Developer -> Access Tokens -> Manage -> Generate New Token

# Name the Token

GitHub Actions CI/CD

Copy the Databricks Access Token

# Update GitHub

repository -> Settings -> Secrets and variables -> Actions ->

Create or Update DATABRICKS_TOKEN with Databricks PAT

# Run GitHub Action (this should now work by using the DATABRICKS_TOKEN credentials)

GitHub -> Repository -> Actions -> Run workflow

## Check Auth Profile:

- databricks auth profiles or
- cat ~./databrickscfg or
- type $HOME\.databrickscfg

Validate:

- databricks bundle validate --profile hrs-dev

Deploy:

- databricks bundle deploy --profile hrs-dev

Run a bunder resource

- databricks bundle run hrs_etl_job --profile hrs-dev

## Relationship between the bundle and the data lifecycle

GitHub
|
| deploys
v
Databricks Asset Bundle
|
| creates
v
Workflow
|
| runs
v
Notebooks
|
| execute
v
SQL Files
|
| create/load
v
Delta Tables
