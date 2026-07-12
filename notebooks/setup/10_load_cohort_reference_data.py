# Databricks notebook source
# /// script
# [tool.databricks.environment]
# environment_version = "5"
# ///
# DBTITLE 1,Overview
# MAGIC %md
# MAGIC # Load Cohort Reference Data
# MAGIC
# MAGIC **Purpose:** Extract distinct HACOHORT values from the RAND longitudinal data and populate the cohort reference table.
# MAGIC
# MAGIC **Source Table:** `dev_catalog.brz_raw_hrs.randhrs1992_2022v1`  
# MAGIC **Target Table:** `dev_catalog.slv_cdm_hrs.cohort`
# MAGIC
# MAGIC **Process:**
# MAGIC 1. Extract distinct HACOHORT values from source data
# MAGIC 2. Transform to match cohort table schema
# MAGIC 3. Load into reference table (cohort_id is auto-generated)

# COMMAND ----------

# DBTITLE 1,Extract distinct HACOHORT values
# MAGIC %sql
# MAGIC -- Step 1: Explore distinct HACOHORT values from source table
# MAGIC
# MAGIC SELECT 
# MAGIC     HACOHORT,
# MAGIC     COUNT(*) as record_count
# MAGIC FROM dev_catalog.brz_raw_hrs.randhrs1992_2022v1
# MAGIC GROUP BY HACOHORT
# MAGIC ORDER BY HACOHORT

# COMMAND ----------

# DBTITLE 1,Clear existing cohort data (optional)
# Clear existing cohort data if needed (use with caution)
# Uncomment the line below to truncate the table before loading

# spark.sql("TRUNCATE TABLE dev_catalog.slv_cdm_hrs.cohort")
# print("✓ Cohort table truncated")

# COMMAND ----------

# DBTITLE 1,Load distinct HACOHORT values into cohort table
# Step 2: Load cohort reference data from SQL file

import sys
#sys.path.append("/Workspace/Users/peteperez.lv@gmail.com/hrs_dbx_repo/src")
#from common.sql_utils import execute_sql_file
from src.common.sql_utils import execute_sql_file

print("Loading cohort reference data...")
execute_sql_file(
    spark,
    "../../sql/dml/load_cohort_reference_data.sql"
)
print("✓ Cohort reference data loaded successfully")

# COMMAND ----------

# DBTITLE 1,Verify loaded cohort data
# Step 3: Verify the cohort reference table

df = spark.sql("""
    SELECT 
        cohort_id,
        cohort_name,
        cohort_description,
        start_date,
        end_date,
        active
    FROM dev_catalog.slv_cdm_hrs.cohort
    ORDER BY cohort_name
""")

display(df)

# COMMAND ----------

# DBTITLE 1,Summary statistics
# Display summary statistics

source_count = spark.sql("""
    SELECT COUNT(DISTINCT HACOHORT) as distinct_cohorts
    FROM dev_catalog.brz_raw_hrs.randhrs1992_2022v1
    WHERE HACOHORT IS NOT NULL
""").collect()[0][0]

target_count = spark.sql("""
    SELECT COUNT(*) as cohort_count
    FROM dev_catalog.slv_cdm_hrs.cohort
""").collect()[0][0]

print("=" * 60)
print("COHORT REFERENCE DATA LOAD SUMMARY")
print("=" * 60)
print(f"Distinct HACOHORT values in source: {source_count}")
print(f"Total records in cohort table:      {target_count}")
print("=" * 60)

if source_count == target_count:
    print("✓ SUCCESS: All distinct cohorts loaded")
else:
    print(f"⚠ WARNING: Mismatch detected. Please review.")

# COMMAND ----------


