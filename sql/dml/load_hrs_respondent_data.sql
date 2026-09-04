-- Load Survey Respondent Reference Data  
-- Target: dev_catalog.slv_cdm_hrs.hub_respondent
-- hub_survey_respondent_id is auto-generated (IDENTITY column)
TRUNCATE TABLE dev_catalog.slv_cdm_hrs.hub_respondent;
--
INSERT INTO dev_catalog.slv_cdm_hrs.hub_respondent (
        cohort_id,
        hhid,
        pn,
        hhidpn,
        hacohort,
        respondent_description,
        create_date,
        update_date,
        active
    )
SELECT DISTINCT c.cohort_id,
    CAST(CAST(hhid AS BIGINT) AS STRING) as hhid,
    CAST(CAST(pn AS BIGINT) AS STRING) as pn,
    CAST(hhidpn AS BIGINT) as hhidpn,
    CAST(HACOHORT AS INT) as hacohort,
    CONCAT(
        CASE
            WHEN ra.RARACEM = 1 THEN 'White'
            WHEN ra.RARACEM = 2 THEN 'Black'
            WHEN ra.RARACEM = 3 THEN 'Other'
            ELSE ' - '
        END,
        ', ',
        CASE
            WHEN ra.RAGENDER = 1 THEN 'Male'
            WHEN ra.RAGENDER = 2 THEN 'Female'
            ELSE ' - '
        END,
        ', ',
        CASE
            WHEN ra.RAVETRN = 1 THEN 'Veteran'
            ELSE 'Non-Veteran'
        END
    ) as respondent_description,
    CURRENT_DATE() as create_date,
    CURRENT_DATE() as update_date,
    true as active
FROM dev_catalog.brz_raw_hrs.randhrs1992_2022v1 ra
    INNER JOIN dev_catalog.slv_cdm_hrs.dim_cohort c ON CAST(ra.HACOHORT AS BIGINT) = c.hacohort_number