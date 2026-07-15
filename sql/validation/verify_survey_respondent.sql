-- Verify HRS hrs_survey_respondent Data
-- Displays all records in the hrs_survey_respondent reference table

SELECT 
    hrs_survey_respondent_id,
    hhid,
    pn,
    hhidpn,
    survey_respondent_description,
    create_date,
    update_date,
    active
FROM dev_catalog.slv_cdm_hrs.hrs_survey_respondent
ORDER BY hhid DESC
LIMIT 10