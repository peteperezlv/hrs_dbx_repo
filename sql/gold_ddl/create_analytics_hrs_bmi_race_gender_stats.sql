-- =========================================================================================================
-- HRS GOLD Star Data Model DDL – BMI Race and Gender Statistics
--
-- Author: Pete Perez
-- 
-- Last Updated: 2026-09-15
--
-- Target Table: dev_catalog.gld_star_hrs.analytic_hrs_bmi_race_gender_stats
--
-- AI Assistant: Claude
--
-- Generated per Specification Document: /notebooks/HRS Gold_Data_Model_Specifications/HRS Gold BMI Descriptive Stats.ipynb
--
-- Databricks Runtime: client.5.12 | Compute: Serverless | SQL Dialect: Spark SQL | Storage: Delta Lake
--
-- NOTE: The bmi column is intentionally excluded from this table. The table does not create a separate row
-- for each unique BMI value; it stores descriptive BMI statistics grouped by cohort/wave/race/gender only.
--
-- =========================================================================================================
--
DROP TABLE IF EXISTS dev_catalog.gld_star_hrs.analytic_hrs_bmi_race_gender_stats;
CREATE TABLE dev_catalog.gld_star_hrs.analytic_hrs_bmi_race_gender_stats (
    -- ---------------------------------------------------------------
    -- Identity Column
    -- ---------------------------------------------------------------
    analytic_hrs_bmi_race_gender_stats_id BIGINT GENERATED ALWAYS AS IDENTITY COMMENT 'System-generated surrogate key',
    --
    -- ---------------------------------------------------------------
    -- Foreign Keys
    -- ---------------------------------------------------------------
    cohort_id BIGINT NOT NULL COMMENT 'Foreign key to dim_hrs_cohort.cohort_id',
    wave_id BIGINT NOT NULL COMMENT 'Foreign key to dim_hrs_wave.wave_id',
    --
    -- ---------------------------------------------------------------
    -- Analytical Dimensions
    -- ---------------------------------------------------------------
    raracem INT COMMENT 'RAND HRS race category',
    ragender INT COMMENT 'RAND HRS gender category',
    --
    -- ---------------------------------------------------------------
    -- Business Attribute
    -- ---------------------------------------------------------------
    hacohort INT COMMENT 'HRS cohort identifier',
    --
    -- ---------------------------------------------------------------
    -- BMI Measures
    -- ---------------------------------------------------------------
    bmi_count INT COMMENT 'Number of records included in the BMI statistics',
    bmi_mean DOUBLE COMMENT 'Mean BMI for the analytical grouping',
    bmi_sd DOUBLE COMMENT 'Standard deviation of BMI for the analytical grouping',
    bmi_min INT COMMENT 'Minimum BMI value for the analytical grouping',
    bmi_max INT COMMENT 'Maximum BMI value for the analytical grouping',
    --
    -- ---------------------------------------------------------------
    -- Audit Columns
    -- ---------------------------------------------------------------
    create_date DATE NOT NULL COMMENT 'Record creation date',
    update_date DATE NOT NULL COMMENT 'Last update date',
    active BOOLEAN NOT NULL COMMENT 'Active indicator',
    --
    -- ---------------------------------------------------------------
    -- Constraints
    -- ---------------------------------------------------------------
    CONSTRAINT pk_analytic_hrs_bmi_race_gender_stats_id PRIMARY KEY (analytic_hrs_bmi_race_gender_stats_id),
    CONSTRAINT fk_analytic_hrs_bmi_race_gender_stats_dim_hrs_cohort FOREIGN KEY (cohort_id) REFERENCES dev_catalog.gld_star_hrs.dim_hrs_cohort (cohort_id),
    CONSTRAINT fk_analytic_hrs_bmi_race_gender_stats_dim_hrs_wave FOREIGN KEY (wave_id) REFERENCES dev_catalog.gld_star_hrs.dim_hrs_wave (wave_id)
) USING DELTA COMMENT 'BMI descriptive statistics table grouped by HRS cohort, wave, race, and gender.';