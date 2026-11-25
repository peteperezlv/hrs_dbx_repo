-- =====================================================================
-- HRS GOLD Star Data Model DDL – Cohort Dimension View
--
-- Target View: dev_catalog.gld_star_hrs.dim_hrs_cohort
--
-- Source Table: dev_catalog.slv_cdm_hrs.dim_cohort
--
-- Purpose: Gold-layer passthrough view over the Silver CDM cohort
--          dimension.  Provides the cohort dimension in the gold star
--          schema without duplicating silver data.
--
-- AI Assistant: Genie Code (Databricks)
--
-- Databricks Runtime: 15.x | SQL Dialect: Spark SQL | Storage: Delta Lake
--
-- =====================================================================
--
CREATE OR REPLACE VIEW dev_catalog.gld_star_hrs.vw_dim_hrs_cohort
COMMENT 'Gold view over Silver CDM cohort dimension (dev_catalog.slv_cdm_hrs.dim_cohort)'
AS SELECT
    cohort_id,
    hacohort_number,
    hacohort_label,
    hacohort_description,
    create_date,
    update_date,
    active
FROM dev_catalog.slv_cdm_hrs.dim_cohort;
