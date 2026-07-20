-- Load Survey Respondent Reference Data
-- Target: dev_catalog.slv_cdm_hrs.hrs_survey_respondent
-- hrs_survey_respondent_id is auto-generated (IDENTITY column)

INSERT INTO dev_catalog.slv_cdm_hrs.hrs_survey_respondent (
    hhid,
    pn,
    hhidpn,
    survey_respondent_description,
    create_date,
    update_date,
    active
)
SELECT DISTINCT
    CAST(CAST(hhid AS BIGINT) AS STRING) as hhid,
    CAST(CAST(pn AS BIGINT) AS STRING) as pn,
    CAST(CAST(hhidpn AS BIGINT) AS STRING) as hhidpn,
    NULL as survey_respondent_description,
    CURRENT_DATE() as create_date,
    CURRENT_DATE() as update_date,
    true as active
FROM dev_catalog.brz_raw_hrs.randhrs1992_2022v1;