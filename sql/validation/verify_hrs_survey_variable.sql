-- ============================================================================
-- Test 3: Missing Survey Variables
--
-- Source Table: dev_catalog.brz_raw_hrs.randhrs1992_2022v1
-- Target Table: hrs_survey_variable
-- ===========================================================================
-- Expected: Zero missing survey variables (R1AGEY_E through R16AGEY_E)

WITH expected_variables AS (
    SELECT explode(array(
        'R1AGEY_E', 'R2AGEY_E', 'R3AGEY_E', 'R4AGEY_E',
        'R5AGEY_E', 'R6AGEY_E', 'R7AGEY_E', 'R8AGEY_E',
        'R9AGEY_E', 'R10AGEY_E', 'R11AGEY_E', 'R12AGEY_E',
        'R13AGEY_E', 'R14AGEY_E', 'R15AGEY_E', 'R16AGEY_E'
    )) AS variable_name
),
missing_variables AS (
    SELECT ev.variable_name
    FROM expected_variables ev
    LEFT JOIN dev_catalog.slv_cdm_hrs.hrs_survey_variable sv
        ON ev.variable_name = sv.survey_variable_name
    WHERE sv.survey_variable_name IS NULL
)
SELECT 
    'Test 3: Missing Survey Variables' AS test_name,
    COUNT(*) AS missing_count,
    CASE 
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status
FROM missing_variables;

-- Verify Survey Variable Data
-- Displays all survey variables with wave year information

SELECT 
    sv.hrs_survey_variable_id,
    sv.rhrs_survey_section_id,
    sv.hrs_wave_id,
    w.wave_number,
    w.wave_year,
    sv.survey_variable_name,
    sv.survey_variable_description,
    sv.survey_variable_type,
    sv.create_date,
    sv.update_date,
    sv.active
FROM dev_catalog.slv_cdm_hrs.hrs_survey_variable sv
INNER JOIN dev_catalog.slv_cdm_hrs.hrs_wave w ON sv.hrs_wave_id = w.hrs_wave_id
WHERE sv.survey_variable_name LIKE 'R%'
ORDER BY sv.survey_variable_name DESC;