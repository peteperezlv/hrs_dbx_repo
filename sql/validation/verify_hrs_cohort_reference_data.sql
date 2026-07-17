-- ========================Test 1 for Missing Cohorts============================
-- Source: dev_catalog.brz_raw_hrs.randhrs1992_2022v1
--
-- Target: dev_catalog.slv_cdm_hrs.hrs_cohort
--
-- Expected: Zero missing cohorts (all HACOHORT values exist in source and target.)
-- ===============================================================================

WITH source_cohorts AS (
    SELECT DISTINCT
        CAST(HACOHORT AS BIGINT) AS hacohort_number
    FROM dev_catalog.brz_raw_hrs.randhrs1992_2022v1
),
missing_cohorts AS (
    SELECT sc.hacohort_number
    FROM source_cohorts sc
    LEFT JOIN dev_catalog.slv_cdm_hrs.hrs_cohort c
        ON sc.hacohort_number = c.hacohort_number
    WHERE c.hacohort_number IS NULL
)
SELECT 
    'Test 5: Missing Cohorts' AS test_name,
    COUNT(*) AS missing_count,
    CASE 
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status
FROM missing_cohorts;-- Verify Wave Reference Data

-- =====================Test 2 for Display Sample Data============================
-- Target: dev_catalog.slv_cdm_hrs.hrs_cohort
-- ===============================================================================
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

