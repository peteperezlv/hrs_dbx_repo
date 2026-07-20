-- ============================================================================
-- HRS Demographics Table DDL
-- ============================================================================
-- Section: Demographics
-- Description: RAND HRS Codebook – Demographics
-- Table: dev_catalog.slv_cdm_hrs.hrs_demographics
-- Storage Format: Delta Lake
-- Table Type: Managed Table
-- Parent Table: dev_catalog.slv_cdm_hrs.hrs_survey_respondent
-- ============================================================================

DROP TABLE IF EXISTS dev_catalog.slv_cdm_hrs.hrs_demographics;

CREATE TABLE dev_catalog.slv_cdm_hrs.hrs_demographics (
    -- Identity Column: System-generated surrogate key
    hrs_demographics_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY COMMENT 'System-generated surrogate key',
    
    -- Foreign Key Column: References parent respondent table
    hrs_survey_respondent_id BIGINT NOT NULL COMMENT 'References hrs_survey_respondent table',
    
    -- Audit Columns: Record lifecycle tracking
    create_date DATE NOT NULL COMMENT 'Record creation date',
    update_date DATE NOT NULL COMMENT 'Last update date',
    active BOOLEAN NOT NULL COMMENT 'Active indicator',
    
    -- Identifier Columns: Respondent identifiers
    HHIDPN STRING COMMENT 'Household Respondent Identifier',
    RAGENDER STRING COMMENT 'Respondent Gender',
    
    -- Age Columns: Age at each survey wave
    R1AGEY_E STRING COMMENT 'Age at Wave 1',
    R2AGEY_E STRING COMMENT 'Age at Wave 2',
    R3AGEY_E STRING COMMENT 'Age at Wave 3',
    R4AGEY_E STRING COMMENT 'Age at Wave 4',
    R5AGEY_E STRING COMMENT 'Age at Wave 5',
    R6AGEY_E STRING COMMENT 'Age at Wave 6',
    R7AGEY_E STRING COMMENT 'Age at Wave 7',
    R8AGEY_E STRING COMMENT 'Age at Wave 8',
    R9AGEY_E STRING COMMENT 'Age at Wave 9',
    R10AGEY_E STRING COMMENT 'Age at Wave 10',
    R11AGEY_E STRING COMMENT 'Age at Wave 11',
    R12AGEY_E STRING COMMENT 'Age at Wave 12',
    R13AGEY_E STRING COMMENT 'Age at Wave 13',
    R14AGEY_E STRING COMMENT 'Age at Wave 14',
    R15AGEY_E STRING COMMENT 'Age at Wave 15',
    R16AGEY_E STRING COMMENT 'Age at Wave 16',
    
    -- BMI Columns: Body Mass Index at each survey wave
    R1BMI STRING COMMENT 'BMI at Wave 1',
    R2BMI STRING COMMENT 'BMI at Wave 2',
    R3BMI STRING COMMENT 'BMI at Wave 3',
    R4BMI STRING COMMENT 'BMI at Wave 4',
    R5BMI STRING COMMENT 'BMI at Wave 5',
    R6BMI STRING COMMENT 'BMI at Wave 6',
    R7BMI STRING COMMENT 'BMI at Wave 7',
    R8BMI STRING COMMENT 'BMI at Wave 8',
    R9BMI STRING COMMENT 'BMI at Wave 9',
    R10BMI STRING COMMENT 'BMI at Wave 10',
    R11BMI STRING COMMENT 'BMI at Wave 11',
    R12BMI STRING COMMENT 'BMI at Wave 12',
    R13BMI STRING COMMENT 'BMI at Wave 13',
    R14BMI STRING COMMENT 'BMI at Wave 14',
    R15BMI STRING COMMENT 'BMI at Wave 15',
    R16BMI STRING COMMENT 'BMI at Wave 16',
    
    -- Foreign Key Constraint: Enforce relationship to parent respondent table
    CONSTRAINT hrs_demographics_hrs_survey_respondent_fk 
        FOREIGN KEY (hrs_survey_respondent_id) 
        REFERENCES dev_catalog.slv_cdm_hrs.hrs_survey_respondent(hrs_survey_respondent_id)
)
USING DELTA
COMMENT 'Stores RAND HRS Demographics observations in the Silver Common Data Model.';
