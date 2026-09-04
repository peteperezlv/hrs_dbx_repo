-- =====================================================================
-- HRS Silver CDM DDL – Demographics Section
--
-- Target Table: dev_catalog.slv_cdm_hrs.fact_demographics
--
-- AI Assistant: Claude
--
-- Generated per Specification Document: /notebooks/DDL Specifications/hrs_deomographics_specification.ipynb
--
-- Databricks Runtime: 15.x | SQL Dialect: Spark SQL | Storage: Delta Lake
--
-- =====================================================================
DROP TABLE IF EXISTS dev_catalog.slv_cdm_hrs.fact_demographics;
--
CREATE TABLE dev_catalog.slv_cdm_hrs.fact_demographics (
    -- ---------------------------------------------------------------
    -- Identity Column
    -- ---------------------------------------------------------------
    hrs_demographics_id BIGINT GENERATED ALWAYS AS IDENTITY COMMENT 'System-generated surrogate key',
    --
    -- ---------------------------------------------------------------
    -- Foreign Keys
    -- ---------------------------------------------------------------
    respondent_id BIGINT NOT NULL COMMENT 'Foreign key to hrs_respondent.respondent_id',
    wave_id BIGINT NOT NULL COMMENT 'Foreign key to hrs_wave.wave_id',
    --
    -- ---------------------------------------------------------------
    -- Identifier Columns
    -- ---------------------------------------------------------------
    hhidpn BIGINT NOT NULL COMMENT 'Household Respondent Identifier',
    wave_number STRING NOT NULL COMMENT 'Wave Number',
    --
    -- ---------------------------------------------------------------
    -- Business Columns
    -- ---------------------------------------------------------------
    agey_e DECIMAL(10, 2) COMMENT 'Respondent Age (RAND CONT variable, e.g. R#AGEY_E), Nullable = yes',
    raracem TINYINT COMMENT 'RARACEM: R Race-masked (RAND CATEG variable), Nullable = yes',
    ragender TINYINT COMMENT 'RAGENDER: R Gender-masked (RAND CATEG variable), Nullable = yes',
    rahispan TINYINT COMMENT 'RAHISPAN: R Hispanic (RAND CATEG variable), Nullable = yes',
    cenreg TINYINT COMMENT 'R#CENREG: Census Region by wave (RAND CATEG variable), Nullable = yes',
    raedyrs TINYINT COMMENT 'RAEDYRS: R Years of Education (RAND CATEG variable), Nullable = yes',
    mstat TINYINT COMMENT 'R#MSTAT: R Marital Status by wave (RAND CATEG variable), Nullable = yes',
    rarelig TINYINT COMMENT 'RARELIG: R Religion (RAND CATEG variable), Nullable = yes',
    ravetrn TINYINT COMMENT 'RAVETRN: R Veteran Status (RAND CATEG variable), Nullable = yes',
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
    CONSTRAINT pk_fact_demographics PRIMARY KEY (hrs_demographics_id),
    CONSTRAINT fk_fact_demographics_hub_respondent FOREIGN KEY (respondent_id) REFERENCES dev_catalog.slv_cdm_hrs.hub_respondent (respondent_id),
    CONSTRAINT fk_fact_demographics_dim_wave FOREIGN KEY (wave_id) REFERENCES dev_catalog.slv_cdm_hrs.dim_wave (wave_id)
) USING DELTA COMMENT 'Stores RAND HRS Demographic observations';