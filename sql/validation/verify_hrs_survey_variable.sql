-- Verify Survey Variable Data
-- Displays all survey variables with wave year information

SELECT 
    sv.hrs_survey_variable_id,
    sv.rhrs_survey_section_id,
    sv.hrs_wave_id,
    w.wave_number,
    w.wave_year,
    sv.survey_variable_name,
    sv.survey_variable_description,
    sv.survey_variable_type,
    sv.create_date,
    sv.update_date,
    sv.active
FROM dev_catalog.slv_cdm_hrs.hrs_survey_variable sv
INNER JOIN dev_catalog.slv_cdm_hrs.hrs_wave w ON sv.hrs_wave_id = w.hrs_wave_id
WHERE sv.survey_variable_name LIKE 'R%'
ORDER BY sv.survey_variable_name DESC;