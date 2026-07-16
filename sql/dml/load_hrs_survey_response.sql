-- Load HRS Survey Response Data for Age Variables (R*AGEY_E)
-- Target: dev_catalog.slv_cdm_hrs.hrs_survey_response
-- hrs_survey_response_id is auto-generated (IDENTITY column)
-- This script unpivots the R1AGEY_E through R16AGEY_E columns and creates one row per age value

INSERT INTO dev_catalog.slv_cdm_hrs.hrs_survey_response (
    hrs_survey_respondent_id,
    hrs_survey_variable_id,
    hrs_wave_id,
    hrs_cohort_id,
    hrs_survey_response_value,
    survey_response_description,
    create_date,
    update_date,
    active
)
WITH unpivoted_age_data AS (
    -- Unpivot R*AGEY_E columns into rows using STACK
    SELECT 
        hhidpn,
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
)
SELECT 
    1 as hrs_survey_respondent_id,
    sv.hrs_survey_variable_id,
    1 as hrs_wave_id,
    1 as hrs_cohort_id,
    CAST(CAST(ua.age_value AS BIGINT) AS STRING) as hrs_survey_response_value,
    NULL as survey_response_description,
    CURRENT_DATE() as create_date,
    CURRENT_DATE() as update_date,
    true as active
FROM unpivoted_age_data ua
INNER JOIN dev_catalog.slv_cdm_hrs.hrs_survey_variable sv 
    ON ua.survey_variable_name = sv.survey_variable_name
WHERE ua.age_value IS NOT NULL;