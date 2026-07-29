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
    --------------------------------------------------------------------
    -- Identity Key
    --------------------------------------------------------------------
    hrs_demographics_id BIGINT GENERATED ALWAYS AS IDENTITY COMMENT 'System-generated surrogate key',
    --------------------------------------------------------------------
    -- Foreign Keys
    --------------------------------------------------------------------
    respondent_id BIGINT NOT NULL COMMENT 'References hrs_survey_respondent.respondent_id',
    wave_id BIGINT NOT NULL COMMENT 'References hrs_survey_wave.wave_id',
    --------------------------------------------------------------------
    -- Audit Columns
    --------------------------------------------------------------------
    create_date DATE NOT NULL COMMENT 'Record creation date',
    update_date DATE NOT NULL COMMENT 'Record last update date',
    active BOOLEAN NOT NULL COMMENT 'Active record indicator',
    --------------------------------------------------------------------
    -- Identifier Columns
    --------------------------------------------------------------------
    HHIDPN STRING COMMENT 'Household Respondent Identifier',
    RAGENDER STRING COMMENT 'Respondent Gender',
    --------------------------------------------------------------------
    -- Age Variables
    --------------------------------------------------------------------
    R1AGEY_E DECIMAL(4, 2) COMMENT 'Respondent Age - Wave 1',
    R2AGEY_E DECIMAL(4, 2) COMMENT 'Respondent Age - Wave 2',
    R3AGEY_E DECIMAL(4, 2) COMMENT 'Respondent Age - Wave 3',
    R4AGEY_E DECIMAL(4, 2) COMMENT 'Respondent Age - Wave 4',
    R5AGEY_E DECIMAL(4, 2) COMMENT 'Respondent Age - Wave 5',
    R6AGEY_E DECIMAL(4, 2) COMMENT 'Respondent Age - Wave 6',
    R7AGEY_E DECIMAL(4, 2) COMMENT 'Respondent Age - Wave 7',
    R8AGEY_E DECIMAL(4, 2) COMMENT 'Respondent Age - Wave 8',
    R9AGEY_E DECIMAL(4, 2) COMMENT 'Respondent Age - Wave 9',
    R10AGEY_E DECIMAL(4, 2) COMMENT 'Respondent Age - Wave 10',
    R11AGEY_E DECIMAL(4, 2) COMMENT 'Respondent Age - Wave 11',
    R12AGEY_E DECIMAL(4, 2) COMMENT 'Respondent Age - Wave 12',
    R13AGEY_E DECIMAL(4, 2) COMMENT 'Respondent Age - Wave 13',
    R14AGEY_E DECIMAL(4, 2) COMMENT 'Respondent Age - Wave 14',
    R15AGEY_E DECIMAL(4, 2) COMMENT 'Respondent Age - Wave 15',
    R16AGEY_E DECIMAL(4, 2) COMMENT 'Respondent Age - Wave 16',
    --------------------------------------------------------------------
    -- Constraints
    --------------------------------------------------------------------
    CONSTRAINT hrs_demographics_pk PRIMARY KEY (hrs_demographics_id),
    CONSTRAINT hrs_demographics_respondent_fk FOREIGN KEY (respondent_id) REFERENCES dev_catalog.slv_cdm_hrs.hrs_survey_respondent (respondent_id),
    CONSTRAINT hrs_demographics_wave_fk FOREIGN KEY (wave_id) REFERENCES dev_catalog.slv_cdm_hrs.hrs_survey_wave (wave_id)
) USING DELTA COMMENT 'Stores RAND HRS Demographics survey observations in the Silver Common Data Model.';