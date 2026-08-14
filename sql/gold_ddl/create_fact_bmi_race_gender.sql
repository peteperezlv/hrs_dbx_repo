-- =========================================================================================================
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
-- NOTE: Do not include the bmi column in the target table.  We do not want a separate group for each unique 
-- BMI value.  We just want to group by wave/cohort/race/gender combinations.
--
-- =========================================================================================================
DROP TABLE IF EXISTS IDENTIFIER(
    CONCAT(
        :catalog_name,
        '.',
        :schema_prefix,
        '.fact_hrs_bmi_race_gender_stats'
    )
);
--
CREATE TABLE IDENTIFIER(
    CONCAT(
        :catalog_name,
        '.',
        :schema_prefix,
        '.fact_hrs_bmi_race_gender_stats'
    )
) (
    -- ---------------------------------------------------------------
    -- Identity Column
    -- ---------------------------------------------------------------
    fact_hrs_bmi_race_gender_stats_id BIGINT GENERATED ALWAYS AS IDENTITY COMMENT 'System-generated surrogate key',
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
    raracem INT,
    ragender INT,
    hacohort INT,
    --bmi DECIMAL(10, 2) COMMENT 'BMI: Body Mass Index (RAND CONT variable), Nullable = yes',
    bmi_count INT COMMENT 'Total number of records for a BMI value',
    bmi_mean DOUBLE COMMENT '',
    bmi_sd DOUBLE COMMENT '',
    bmi_min INT COMMENT '',
    bmi_max INT COMMENT '',
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
    CONSTRAINT pk_hrs_fact_bmi_race_gender_stats_id PRIMARY KEY (fact_hrs_bmi_race_gender_stats_id),
    CONSTRAINT fk_hrs_fact_bmi_race_gender_stats_dim_hrs_cohort FOREIGN KEY (cohort_id) REFERENCES dev_catalog.gld_star_hrs.dim_hrs_cohort(cohort_id),
    CONSTRAINT fk_fact_hrs_bmi_race_gender_stats_dim_hrs_wave FOREIGN KEY (wave_id) REFERENCES dev_catalog.gld_star_hrs.dim_hrs_wave (wave_id)
) USING DELTA COMMENT 'BMI descriptive statistics table.  Grouped by Cohort and wave';