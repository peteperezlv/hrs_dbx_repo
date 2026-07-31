-- ============================================================================
-- HRS Demographics Table DDL
-- ============================================================================
-- Section: Demographics
-- Description: RAND HRS Codebook – Demographics
-- Table: dev_catalog.slv_cdm_hrs.hrs_demographics
-- Storage Format: Delta Lake
-- Table Type: Managed Table
-- Parent Table: dev_catalog.slv_cdm_hrs.hrs_respondent
-- Parent Table: dev_catalog.slv_cdm_hrs.hrs_wave
-- ============================================================================
DROP TABLE IF EXISTS dev_catalog.slv_cdm_hrs.hrs_demographics;
CREATE TABLE dev_catalog.slv_cdm_hrs.hrs_demographics (
    hrs_demographics_id BIGINT GENERATED ALWAYS AS IDENTITY COMMENT 'System-generated surrogate key',
    respondent_id BIGINT NOT NULL COMMENT 'FK to hrs_respondent.respondent_id',
    wave_id SMALLINT NOT NULL COMMENT 'FK to hrs_wave.wave_id',
    hhidpn INT COMMENT 'Household Respondent Identifier',
    wave_number SMALLINT NOT NULL COMMENT 'Wave Number',
    create_date DATE NOT NULL COMMENT 'Record creation date',
    update_date DATE NOT NULL COMMENT 'Last update date',
    active BOOLEAN NOT NULL COMMENT 'Active indicator',
    agey_e DECIMAL(10, 2) COMMENT 'Respondent Age (continuous, mapped across waves)',
    raracem TINYINT COMMENT 'RARACEM: R Race-masked',
    rahispan TINYINT COMMENT 'RAHISPAN: R Hispanic',
    cenreg TINYINT COMMENT 'Census Region (mapped across waves)',
    raedyrs TINYINT COMMENT 'RAEDYRS: R Years of Education',
    mstat TINYINT COMMENT 'R Marital Status (mapped across waves)',
    rarelig TINYINT COMMENT 'RARELIG: R Religion',
    ravetrn TINYINT COMMENT 'RAVETRN: R Veteran Status',
    CONSTRAINT pk_hrs_demographics PRIMARY KEY (hrs_demographics_id),
    CONSTRAINT fk_hrs_demographics_respondent FOREIGN KEY (respondent_id) REFERENCES dev_catalog.slv_cdm_hrs.hrs_respondent (respondent_id),
    CONSTRAINT fk_hrs_demographics_wave FOREIGN KEY (wave_id) REFERENCES dev_catalog.slv_cdm_hrs.hrs_wave (wave_id),
    CONSTRAINT uq_hrs_demographics_respondent_wave UNIQUE (respondent_id, wave_id)
) USING DELTA COMMENT 'Stores RAND HRS Demographic observations';