-- Verify HRS hrs respondent type Data
-- Displays all records in the hrs_respondent_type reference table
-- coment

SELECT 
    hrs_respondent_type_id,
    respondent_type_code,
    respondent_type_description,
    create_date,
    update_date,
    active
FROM dev_catalog.slv_cdm_hrs.hrs_respondent_type