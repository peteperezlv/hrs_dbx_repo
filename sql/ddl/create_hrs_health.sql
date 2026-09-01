-- =====================================================================
-- HRS Silver CDM DDL – Health Section 
-- Target Table: dev_catalog.slv_cdm_hrs.hrs_health
-- Generated per: HRS Silver CDM DDL Functional Specification v1.0
-- Databricks Runtime: 15.x | SQL Dialect: Spark SQL | Storage: Delta Lake
-- =====================================================================
DROP TABLE IF EXISTS IDENTIFIER(
    CONCAT(
        :catalog_name,
        '.',
        :schema_prefix,
        '.fact_health'
    )
);
CREATE TABLE IDENTIFIER(
    CONCAT(
        :catalog_name,
        '.',
        :schema_prefix,
        '.fact_health'
    )
) (
    -- ---------------------------------------------------------------
    -- Identity Column
    -- ---------------------------------------------------------------
    hrs_health_id BIGINT GENERATED ALWAYS AS IDENTITY COMMENT 'System-generated surrogate key',
    -- ---------------------------------------------------------------
    -- Foreign Keys
    -- ---------------------------------------------------------------
    respondent_id BIGINT NOT NULL COMMENT 'Foreign key to hrs_respondent.respondent_id',
    wave_id BIGINT NOT NULL COMMENT 'Foreign key to hrs_wave.wave_id',
    -- ---------------------------------------------------------------
    -- Identifier Columns
    -- ---------------------------------------------------------------
    hhidpn BIGINT NOT NULL COMMENT 'Household Respondent Identifier',
    wave_number STRING NOT NULL COMMENT 'Wave Number',
    -- ---------------------------------------------------------------
    -- Business Columns (from Source-to-Target Mapping Matrix, Section 12)
    -- All columns below are wave-varying (RwXXXXX)
    -- ---------------------------------------------------------------
    shlt TINYINT COMMENT 'R#SHLT: Self-Rated Health (RAND CATEG variable), Nullable = yes',
    bmi DECIMAL(10, 2) COMMENT 'R#BMI: Body Mass Index (RAND CONT variable), Nullable = yes',
    hibpe TINYINT COMMENT 'R#HIBPE: Ever Diagnosed High Blood Pressure (RAND CATEG variable), Nullable = yes',
    diabe TINYINT COMMENT 'R#DIABE: Ever Diagnosed Diabetes (RAND CATEG variable), Nullable = yes',
    cancre TINYINT COMMENT 'R#CANCRE: Ever Diagnosed Cancer (RAND CATEG variable), Nullable = yes',
    lunge TINYINT COMMENT 'R#LUNGE: Ever Diagnosed Lung Disease (RAND CATEG variable), Nullable = yes',
    hearte TINYINT COMMENT 'R#HEARTE: Ever Diagnosed Heart Problems (RAND CATEG variable), Nullable = yes',
    stroke TINYINT COMMENT 'R#STROKE: Ever Diagnosed Stroke (RAND CATEG variable), Nullable = yes',
    psyche TINYINT COMMENT 'R#PSYCHE: Ever Diagnosed Psychiatric Problems (RAND CATEG variable), Nullable = yes',
    arthre TINYINT COMMENT 'R#ARTHRE: Ever Diagnosed Arthritis (RAND CATEG variable), Nullable = yes',
    -- ---------------------------------------------------------------
    -- Audit Columns
    -- ---------------------------------------------------------------
    create_date DATE NOT NULL COMMENT 'Record creation date',
    update_date DATE NOT NULL COMMENT 'Last update date',
    active BOOLEAN NOT NULL COMMENT 'Active indicator',
    -- ---------------------------------------------------------------
    -- Constraints
    -- ---------------------------------------------------------------
    CONSTRAINT pk_hrs_health PRIMARY KEY (hrs_health_id),
    CONSTRAINT fk_hrs_health_respondent FOREIGN KEY (respondent_id) REFERENCES dev_catalog.slv_cdm_hrs.hrs_respondent (respondent_id),
    CONSTRAINT fk_hrs_health_wave FOREIGN KEY (wave_id) REFERENCES dev_catalog.slv_cdm_hrs.hrs_wave (wave_id),
    CONSTRAINT uq_hrs_health_respondent_wave UNIQUE (respondent_id, wave_id)
) USING DELTA COMMENT 'Stores RAND HRS Health observations';