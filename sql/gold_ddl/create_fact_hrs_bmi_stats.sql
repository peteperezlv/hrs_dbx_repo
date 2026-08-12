-- =====================================================================
-- HRS GOLD Star Data Model DDL – Demographics Section
--
-- Target Table: dev_catalog.gld_sdm_hrs.hrs_bmi_stats
--
-- AI Assistant: Claude
--
-- Generated per Specification Document: /notebooks/DDL Specifications/hrs_deomographics_specification.ipynb
--
-- Databricks Runtime: 15.x | SQL Dialect: Spark SQL | Storage: Delta Lake
--
-- =====================================================================
DROP TABLE IF EXISTS IDENTIFIER(
    CONCAT(
        :catalog_name,
        '.',
        :schema_prefix,
        '.hrs_bmi_stats'
    )
);
--
CREATE TABLE IDENTIFIER(
    CONCAT(
        :catalog_name,
        '.',
        :schema_prefix,
        '.hrs_bmi_stats'
    )
) (
    -- ---------------------------------------------------------------
    -- Identity Column
    -- ---------------------------------------------------------------
    hrs_bmi_stats_id BIGINT GENERATED ALWAYS AS IDENTITY COMMENT 'System-generated surrogate key',
    --
    -- ---------------------------------------------------------------
    -- Foreign Keys
    -- ---------------------------------------------------------------
    cohort_id BIGINT NOT NULL COMMENT 'Foreign key to hrs_cohort_id',
    wave_id BIGINT NOT NULL COMMENT 'Foreign key to hrs_wave.wave_id',
    --
    -- ---------------------------------------------------------------
    -- Business Columns
    -- ---------------------------------------------------------------
    hacohort INT,
    bmi DECIMAL(10, 2) COMMENT 'BMI: Body Mass Index (RAND CONT variable), Nullable = yes',
    bmi_count int COMMENT 'Total number of records for a BMI value',
    bmi_mean int COMMENT '',
    bmi_sd int COMMENT '',
    bmi_min int COMMENT '',
    bmi_max int COMMENT '',
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
    CONSTRAINT pk_hrs_bmi_stats_id PRIMARY KEY (hrs_bmi_stats_id) --CONSTRAINT fk_hrs_bmi_stats_hrs_cohort FOREIGN KEY (cohort_id) REFERENCES dev_catalog.gld_sdm_hrs.hrs_cohort(cohort_id),
    --CONSTRAINT fk_hrs_bmi_stats_hrs_wave FOREIGN KEY (wave_id) REFERENCES dev_catalog.gld_sdm_hrs.hrs_wave (wave_id)
) USING DELTA COMMENT 'BMI descriptive statistics table.  Grouped by Cohort and wave';