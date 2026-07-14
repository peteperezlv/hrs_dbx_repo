-- Verify Wave Reference Data
-- Displays all records in the wave reference table with cohort information

SELECT 
    hrs_cohort_id,
    hacohort_number,
    hacohort_label,
    hacohort_description,
    create_date,
    update_date,
    active
FROM dev_catalog.slv_cdm_hrs.hrs_cohort
ORDER BY hrs_cohort_id

