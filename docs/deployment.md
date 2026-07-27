# HRS Databricks Data Warehouse Deployment

## Overview

This repository contains the Databricks Asset Bundle used to deploy
the HRS data warehouse development environment.

## Deployment Flow

Developer Branch
|
v
GitHub Pull Request
|
v
CI Validation
|
v
Production Merge
|
v
Databricks Bundle Deployment
|
v
Workflow Execution

## Local Deployment

Validate:

databricks bundle validate --profile hrs-dev

Deploy:

databricks bundle deploy --profile hrs-dev

Run:

databricks bundle run hrs_etl_job --profile hrs-dev

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
