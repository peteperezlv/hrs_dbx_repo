SELECT
    hrs_survey_respondent_id,
    hrs_survey_variable_id,
    hrs_wave_id,
    hrs_cohort_id,
    hrs_survey_response_value,
    survey_response_description,
    create_date,
    update_date,
    active
FROM dev_catalog.slv_cdm_hrs.hrs_survey_response
LIMIT 25