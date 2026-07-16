DROP TABLE IF EXISTS dev_catalog.slv_cdm_hrs.hrs_survey_response;

CREATE TABLE dev_catalog.slv_cdm_hrs.hrs_survey_response (
    hrs_survey_response_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    hrs_survey_respondent_id BIGINT,
    hrs_survey_variable_id BIGINT,
    hrs_wave_id BIGINT,
    hrs_cohort_id BIGINT,
    hrs_survey_response_value STRING,
    survey_response_description STRING,
    create_date DATE,
    update_date DATE,
    active BOOLEAN,
    CONSTRAINT hrs_survey_response_hrs_survey_resondent_fk FOREIGN KEY (hrs_survey_respondent_id) REFERENCES dev_catalog.slv_cdm_hrs.hrs_survey_respondent(hrs_survey_respondent_id),

    CONSTRAINT hrs_survey_response_hrs_survey_variable_fk FOREIGN KEY (hrs_survey_variable_id) REFERENCES dev_catalog.slv_cdm_hrs.hrs_survey_variable(hrs_survey_variable_id),

    CONSTRAINT hrs_survey_response_hrs_wave_fk FOREIGN KEY (hrs_wave_id) REFERENCES dev_catalog.slv_cdm_hrs.hrs_wave(hrs_wave_id),

    CONSTRAINT hrs_survey_response_hrs_cohort_fk FOREIGN KEY (hrs_cohort_id) REFERENCES dev_catalog.slv_cdm_hrs.hrs_cohort(hrs_cohort_id)
)
USING DELTA
COMMENT 'HRS Survey Response tracking table';