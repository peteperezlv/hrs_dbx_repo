-- ============================================================================
-- Test 2: Target Record Count Matches Source
--
-- Source: dev_catalog.brz_raw_hrs.randhrs1992_2022v1
-- Target: dev_catalog.slv_cdm_hrs.hrs_survey_response
-- ============================================================================
-- Expected: Target count = Source count

WITH source_unpivoted AS (
    SELECT 
        CAST(CAST(hhidpn AS BIGINT) AS STRING) AS hhidpn,
        CAST(HACOHORT AS BIGINT) AS hacohort,
        stack(16,
            'R1AGEY_E', R1AGEY_E,
            'R2AGEY_E', R2AGEY_E,
            'R3AGEY_E', R3AGEY_E,
            'R4AGEY_E', R4AGEY_E,
            'R5AGEY_E', R5AGEY_E,
            'R6AGEY_E', R6AGEY_E,
            'R7AGEY_E', R7AGEY_E,
            'R8AGEY_E', R8AGEY_E,
            'R9AGEY_E', R9AGEY_E,
            'R10AGEY_E', R10AGEY_E,
            'R11AGEY_E', R11AGEY_E,
            'R12AGEY_E', R12AGEY_E,
            'R13AGEY_E', R13AGEY_E,
            'R14AGEY_E', R14AGEY_E,
            'R15AGEY_E', R15AGEY_E,
            'R16AGEY_E', R16AGEY_E
        ) AS (survey_variable_name, age_value)
    FROM dev_catalog.brz_raw_hrs.randhrs1992_2022v1
),
source_count AS (
    SELECT COUNT(*) AS cnt
    FROM source_unpivoted
    WHERE age_value IS NOT NULL
),
target_count AS (
    SELECT COUNT(*) AS cnt
    FROM dev_catalog.slv_cdm_hrs.hrs_survey_response sr
    INNER JOIN dev_catalog.slv_cdm_hrs.hrs_survey_variable sv
        ON sr.hrs_survey_variable_id = sv.hrs_survey_variable_id
    WHERE sv.survey_variable_name LIKE 'R%AGEY_E'
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
-- Test 7: NULL Value Validation
-- ============================================================================
-- Expected: Zero rows with NULL in critical columns in the target table, dev_catalog.slv_cdm_hrs.hrs_survey_response 

WITH null_check AS (
    SELECT 
        hrs_survey_response_id
    FROM dev_catalog.slv_cdm_hrs.hrs_survey_response
    WHERE hrs_survey_response_value IS NULL
       OR hrs_survey_variable_id IS NULL
       OR hrs_survey_respondent_id IS NULL
       OR hrs_wave_id IS NULL
       OR hrs_cohort_id IS NULL
)
SELECT 
    'Test 7: NULL Value Validation' AS test_name,
    COUNT(*) AS null_count,
    CASE 
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status
FROM null_check;

-- ============================================================================
-- Test 8: Data Type Validation (No Scientific Notation, No Decimals)
-- ============================================================================
-- Expected: All age values are whole numbers without scientific notation

WITH invalid_values AS (
    SELECT 
        hrs_survey_response_id,
        hrs_survey_response_value
    FROM dev_catalog.slv_cdm_hrs.hrs_survey_response sr
    INNER JOIN dev_catalog.slv_cdm_hrs.hrs_survey_variable sv
        ON sr.hrs_survey_variable_id = sv.hrs_survey_variable_id
    WHERE sv.survey_variable_name LIKE 'R%AGEY_E'
      AND (
          hrs_survey_response_value LIKE '%E%'  -- Scientific notation
          OR hrs_survey_response_value LIKE '%.%'  -- Decimal values
          OR hrs_survey_response_value RLIKE '[^0-9]'  -- Non-numeric characters
      )
)
SELECT 
    'Test 8: Data Type Validation' AS test_name,
    COUNT(*) AS invalid_count,
    CASE 
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status
FROM invalid_values;

-- ============================================================================
-- Test 9: Referential Integrity
-- ============================================================================
-- Expected: Zero orphan records (all foreign keys reference existing parents)

WITH orphan_check AS (
    -- Check hrs_survey_variable_id
    SELECT 'hrs_survey_variable_id' AS fk_column, COUNT(*) AS orphan_count
    FROM dev_catalog.slv_cdm_hrs.hrs_survey_response sr
    LEFT JOIN dev_catalog.slv_cdm_hrs.hrs_survey_variable sv
        ON sr.hrs_survey_variable_id = sv.hrs_survey_variable_id
    WHERE sv.hrs_survey_variable_id IS NULL
    
    UNION ALL
    
    -- Check hrs_survey_respondent_id
    SELECT 'hrs_survey_respondent_id' AS fk_column, COUNT(*) AS orphan_count
    FROM dev_catalog.slv_cdm_hrs.hrs_survey_response sr
    LEFT JOIN dev_catalog.slv_cdm_hrs.hrs_survey_respondent resp
        ON sr.hrs_survey_respondent_id = resp.hrs_survey_respondent_id
    WHERE resp.hrs_survey_respondent_id IS NULL
    
    UNION ALL
    
    -- Check hrs_wave_id
    SELECT 'hrs_wave_id' AS fk_column, COUNT(*) AS orphan_count
    FROM dev_catalog.slv_cdm_hrs.hrs_survey_response sr
    LEFT JOIN dev_catalog.slv_cdm_hrs.hrs_wave w
        ON sr.hrs_wave_id = w.hrs_wave_id
    WHERE w.hrs_wave_id IS NULL
    
    UNION ALL
    
    -- Check hrs_cohort_id
    SELECT 'hrs_cohort_id' AS fk_column, COUNT(*) AS orphan_count
    FROM dev_catalog.slv_cdm_hrs.hrs_survey_response sr
    LEFT JOIN dev_catalog.slv_cdm_hrs.hrs_cohort c
        ON sr.hrs_cohort_id = c.hrs_cohort_id
    WHERE c.hrs_cohort_id IS NULL
)
SELECT 
    'Test 9: Referential Integrity' AS test_name,
    SUM(orphan_count) AS total_orphan_count,
    CASE 
        WHEN SUM(orphan_count) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status
FROM orphan_check;


-- ============================================================================
-- Test 10: Sample Data Validation (Manual Inspection)
-- ============================================================================
-- Returns 25 sample rows for manual review

SELECT 
    resp.hhidpn,
    sv.survey_variable_name,
    w.wave_number,
    w.wave_year,
    sr.hrs_survey_response_value AS age,
    c.hacohort_number,
    c.hacohort_label
FROM dev_catalog.slv_cdm_hrs.hrs_survey_response sr
INNER JOIN dev_catalog.slv_cdm_hrs.hrs_survey_variable sv
    ON sr.hrs_survey_variable_id = sv.hrs_survey_variable_id
INNER JOIN dev_catalog.slv_cdm_hrs.hrs_survey_respondent resp
    ON sr.hrs_survey_respondent_id = resp.hrs_survey_respondent_id
INNER JOIN dev_catalog.slv_cdm_hrs.hrs_wave w
    ON sr.hrs_wave_id = w.hrs_wave_id
INNER JOIN dev_catalog.slv_cdm_hrs.hrs_cohort c
    ON sr.hrs_cohort_id = c.hrs_cohort_id
WHERE sv.survey_variable_name LIKE 'R%AGEY_E'
ORDER BY resp.hhidpn, sv.survey_variable_name
LIMIT 25;