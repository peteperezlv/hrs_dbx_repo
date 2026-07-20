DROP TABLE IF EXISTS dev_catalog.slv_cdm_hrs.hrs_survey_section;

CREATE TABLE dev_catalog.slv_cdm_hrs.hrs_survey_section (
    hrs_survey_section_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    hrs_survey_section_name STRING,
    hrs_survey_section_description STRING, 
    create_date DATE,
    update_date DATE,
    active BOOLEAN
)
USING DELTA
COMMENT 'hrs_survey_section tracking table';