-- Load Resondent Type Reference Data
-- Target: dev_catalog.slv_cdm_hrs.hrs_respondent_type
-- hrs_respondent_type_id is auto-generated (IDENTITY column)

INSERT INTO dev_catalog.slv_cdm_hrs.hrs_respondent_type (
    respondent_type_code,
    respondent_type_description,
    create_date,
    update_date,
    active
)
VALUES
    ('R', 'Reference Person or head of household.', CURRENT_DATE(), CURRENT_DATE(), true),
    ('S', 'Spouse', CURRENT_DATE(), CURRENT_DATE(), true),
    ('H', 'Household Information provided by ether the Reference Person or head of household or a Spouse', CURRENT_DATE(), CURRENT_DATE(), true);