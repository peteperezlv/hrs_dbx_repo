-- =====================================================================
-- HRS Silver CDM DDL – Leave-Behind: Big 5 Personality Traits
-- Target Table: dev_catalog.slv_cdm_hrs.hrs_leave_behind
-- Generated per: HRS Silver CDM DDL/DML Functional Specification v2.0
-- Databricks Runtime: 15.x | SQL Dialect: Spark SQL | Storage: Delta Lake
-- =====================================================================
DROP TABLE IF EXISTS dev_catalog.slv_cdm_hrs.hrs_leave_behind;
CREATE TABLE dev_catalog.slv_cdm_hrs.hrs_leave_behind (
    -- ---------------------------------------------------------------
    -- Identity Column
    -- ---------------------------------------------------------------
    hrs_leave_behind_id BIGINT GENERATED ALWAYS AS IDENTITY COMMENT 'System-generated surrogate key',
    -- ---------------------------------------------------------------
    -- Foreign Keys
    -- ---------------------------------------------------------------
    respondent_id BIGINT NOT NULL COMMENT 'Foreign key to hrs_respondent.respondent_id',
    wave_id BIGINT NOT NULL COMMENT 'Foreign key to hrs_wave.wave_id',
    -- ---------------------------------------------------------------
    -- Identifier Columns
    -- ---------------------------------------------------------------
    hhidpn INT COMMENT 'Household Respondent Identifier',
    wave_number STRING NOT NULL COMMENT 'Wave Number',
    -- ---------------------------------------------------------------
    -- Business Columns (from Source-to-Target Mapping Matrix, Section 12)
    -- All columns below are wave-varying, sourced only for Waves 8-16
    -- (Leave-Behind Big 5 items were not fielded before Wave 8); rows
    -- for Waves 1-7 carry NULL across all 5 business columns by design.
    -- ---------------------------------------------------------------
    lbneur DECIMAL(10, 2) COMMENT 'R#LBNEUR: Big 5 Neuroticism (RAND CONT variable, Waves 8-16 only), Nullable = yes',
    lbext DECIMAL(10, 2) COMMENT 'R#LBEXT: Big 5 Extroversion (RAND CONT variable, Waves 8-16 only), Nullable = yes',
    lbopen DECIMAL(10, 2) COMMENT 'R#LBOPEN: Big 5 Openness to Experience (RAND CONT variable, Waves 8-16 only), Nullable = yes',
    lbagr DECIMAL(10, 2) COMMENT 'R#LBAGR: Big 5 Agreeableness (RAND CONT variable, Waves 8-16 only), Nullable = yes',
    lbcon5 DECIMAL(10, 2) COMMENT 'R#LBCON5: Big 5 Conscientiousness, 5 Sub-items composite (RAND CONT variable, Waves 8-16 only), Nullable = yes',
    -- ---------------------------------------------------------------
    -- Audit Columns
    -- ---------------------------------------------------------------
    create_date DATE NOT NULL COMMENT 'Record creation date',
    update_date DATE NOT NULL COMMENT 'Last update date',
    active BOOLEAN NOT NULL COMMENT 'Active indicator',
    -- ---------------------------------------------------------------
    -- Constraints
    -- ---------------------------------------------------------------
    CONSTRAINT pk_hrs_leave_behind PRIMARY KEY (hrs_leave_behind_id),
    CONSTRAINT fk_hrs_leave_behind_respondent FOREIGN KEY (respondent_id) REFERENCES dev_catalog.slv_cdm_hrs.hrs_respondent (respondent_id),
    CONSTRAINT fk_hrs_leave_behind_wave FOREIGN KEY (wave_id) REFERENCES dev_catalog.slv_cdm_hrs.hrs_wave (wave_id),
    CONSTRAINT uq_hrs_leave_behind_respondent_wave UNIQUE (respondent_id, wave_id)
) USING DELTA COMMENT 'Stores RAND HRS Leave-Behind Big 5 Personality Trait observations';