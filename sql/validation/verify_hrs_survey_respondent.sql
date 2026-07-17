-- ============================================================================
--                      Test 1: Missing Respondents
--
-- Source Table: dev_catalog.brz_raw_hrs.randhrs1992_2022v1
--
-- Target Table: hrs_survey_respondent
-- ============================================================================
-- Expected: Zero missing respondents (all hhidpn values exist)

WITH source_respondents AS (
    SELECT DISTINCT
        CAST(CAST(hhidpn AS BIGINT) AS STRING) AS hhidpn
    FROM dev_catalog.brz_raw_hrs.randhrs1992_2022v1
),
missing_respondents AS (
    SELECT sr.hhidpn
    FROM source_respondents sr
    LEFT JOIN dev_catalog.slv_cdm_hrs.hrs_survey_respondent resp
        ON sr.hhidpn = resp.hhidpn
    WHERE resp.hhidpn IS NULL
)
SELECT 
    'Test 4: Missing Respondents' AS test_name,
    COUNT(*) AS missing_count,
    CASE 
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status
FROM missing_respondents;


-- ============================================================================
-- Test 2: Target Record Count Matches Source
-- ============================================================================
-- Expected: Target count = Source count

WITH source_count AS (
    SELECT COUNT(DISTINCT hhidpn) AS cnt
    FROM dev_catalog.brz_raw_hrs.randhrs1992_2022v1
    WHERE hhidpn IS NOT NULL
),
target_count AS (
    SELECT COUNT(DISTINCT hhidpn) AS cnt
    FROM dev_catalog.slv_cdm_hrs.hrs_survey_respondent sr
    WHERE hhidpn IS NOT NULL
)
SELECT 
    'Test 2: Target vs Source Count' AS test_name,
    sc.cnt AS source_count,
    tc.cnt AS target_count,
    CASE 
        WHEN sc.cnt = tc.cnt THEN 'PASS'
        ELSE 'FAIL'
    END AS status
FROM source_count sc
CROSS JOIN target_count tc;

-- ============================================================================
-- Test 3: Sample Respondents Data
-- ============================================================================
-- Displays 20 records in the hrs_survey_respondent reference table

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
LIMIT 20