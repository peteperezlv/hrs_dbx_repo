-- Verify RHRS Survey Section Reference Data
-- Displays all records in the rhrs_survey_section reference table

SELECT 
    rhrs_survey_section_id,
    rhrs_survey_section_name,
    rhrs_survey_section_description,
    create_date,
    update_date,
    active
FROM dev_catalog.slv_cdm_hrs.rhrs_survey_section
ORDER BY rhrs_survey_section_id;