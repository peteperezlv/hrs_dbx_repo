DROP TABLE IF EXISTS dev_catalog.slv_cdm_hrs.hrs_survey_respondent;

CREATE TABLE dev_catalog.slv_cdm_hrs.hrs_survey_respondent (
    hrs_survey_respondent_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    hhid STRING,
    pn STRING,
    hhidpn STRING,
    survey_respondent_description STRING,
    create_date DATE,
    update_date DATE,
    active BOOLEAN
)
USING DELTA
COMMENT 'HRS Survey Respondent tracking table';