DROP TABLE IF EXISTS dev_catalog.slv_cdm_hrs.rhrs_survey_section;

CREATE TABLE dev_catalog.slv_cdm_hrs.rhrs_survey_section (
    rhrs_survey_section_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    rhrs_survey_section_name STRING,
    rhrs_survey_section_description STRING, 
    create_date DATE,
    update_date DATE,
    active BOOLEAN
)
USING DELTA
COMMENT 'rhrs_survey_section tracking table';