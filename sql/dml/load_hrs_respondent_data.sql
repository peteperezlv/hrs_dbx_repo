-- Load Survey Respondent Reference Data 
-- Target: dev_catalog.slv_cdm_hrs.hrs_survey_respondent
-- hrs_survey_respondent_id is auto-generated (IDENTITY column)
INSERT INTO dev_catalog.slv_cdm_hrs.hrs_survey_respondent (
        cohort_id,
        hhid,
        pn,
        hhidpn,
        hacohort_number,
        survey_respondent_description,
        create_date,
        update_date,
        active
    )
SELECT DISTINCT CAST(CAST(hhidpn AS BIGINT) AS STRING) as hhidpn,
    CAST(CAST(hhid AS BIGINT) AS STRING) as hhid,
    CAST(CAST(pn AS BIGINT) AS STRING) as pn,
    c.cohort_id,
    CAST(HACOHORT AS INT) as hacohort_number,
    NULL as survey_respondent_description,
    CURRENT_DATE() as create_date,
    CURRENT_DATE() as update_date,
    true as active
FROM dev_catalog.brz_raw_hrs.randhrs1992_2022v1 ra
    INNER JOIN dev_catalog.slv_cdm_hrs.hrs_cohort c ON CAST(ra.HACOHORT AS BIGINT) = c.hacohort_number