-- Load Cohort Reference Data from RAND Longitudinal Dataset
-- Source: dev_catalog.brz_raw_hrs.randhrs1992_2022v1
-- Target: dev_catalog.slv_cdm_hrs.cohort
-- cohort_id is auto-generated (IDENTITY column)

INSERT INTO dev_catalog.slv_cdm_hrs.cohort (
    cohort_name,
    cohort_description,
    start_date,
    end_date,
    active
)
SELECT DISTINCT
    CAST(HACOHORT AS STRING) as cohort_name,
    CONCAT('HRS Cohort ', CAST(HACOHORT AS STRING)) as cohort_description,
    CURRENT_DATE() as start_date,
    CURRENT_DATE() as end_date,
    true as active
FROM dev_catalog.brz_raw_hrs.randhrs1992_2022v1
WHERE HACOHORT IS NOT NULL
ORDER BY cohort_name;