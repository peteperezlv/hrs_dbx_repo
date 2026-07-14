-- Load Survey Variable Age Reference Data
-- Target: dev_catalog.slv_cdm_hrs.survey_variable
-- survey_variable_id is auto-generated (IDENTITY column)
-- These are age-related variables (R*AGEY_E and S*AGEY_E) from Section A

INSERT INTO dev_catalog.slv_cdm_hrs.survey_variable (
    rhrs_survey_section_id,
    hrs_wave_id,
    survey_variable_name,
    survey_variable_description,
    survey_variable_type,
    create_date,
    update_date,
    active
)
WITH section_lookup AS (
    -- Get Section A ID
    SELECT rhrs_survey_section_id
    FROM dev_catalog.slv_cdm_hrs.rhrs_survey_section
    WHERE rhrs_survey_section_name = 'Section A'
),
survey_variable_mapping AS (
    -- Define all age variables with their wave numbers
    SELECT * FROM VALUES
        ('1', 'R1AGEY_E', 'R1AGEY_E:W1RAge(years)atIwEndMon Cont', 'Cont'),
        ('2', 'R2AGEY_E', 'R2AGEY_E:W2RAge(years)atIwEndMon Cont', 'Cont'),
        ('3', 'R3AGEY_E', 'R3AGEY_E:W3RAge(years)atIwEndMon Cont', 'Cont'),
        ('4', 'R4AGEY_E', 'R4AGEY_E:W4RAge(years)atIwEndMon Cont', 'Cont'),
        ('5', 'R5AGEY_E', 'R5AGEY_E:W5RAge(years)atIwEndMon Cont', 'Cont'),
        ('6', 'R6AGEY_E', 'R6AGEY_E:W6RAge(years)atIwEndMon Cont', 'Cont'),
        ('7', 'R7AGEY_E', 'R7AGEY_E:W7RAge(years)atIwEndMon Cont', 'Cont'),
        ('8', 'R8AGEY_E', 'R8AGEY_E:W8RAge(years)atIwEndMon Cont', 'Cont'),
        ('9', 'R9AGEY_E', 'R9AGEY_E:W9RAge(years)atIwEndMon Cont', 'Cont'),
        ('10', 'R10AGEY_E', 'R10AGEY_E:W10RAge(years)atIwEndMon Cont', 'Cont'),
        ('11', 'R11AGEY_E', 'R11AGEY_E:W11RAge(years)atIwEndMon Cont', 'Cont'),
        ('12', 'R12AGEY_E', 'R12AGEY_E:W12RAge(years)atIwEndMon Cont', 'Cont'),
        ('13', 'R13AGEY_E', 'R13AGEY_E:W13RAge(years)atIwEndMon Cont', 'Cont'),
        ('14', 'R14AGEY_E', 'R14AGEY_E:W14RAge(years)atIwEndMon Cont', 'Cont'),
        ('15', 'R15AGEY_E', 'R15AGEY_E:W15RAge(years)atIwEndMon Cont', 'Cont'),
        ('16', 'R16AGEY_E', 'R16AGEY_E:W16RAge(years)atIwEndMon Cont', 'Cont'),
        ('1', 'S1AGEY_E', 'S1AGEY_E:W1SAge(years)atIwEndMon Cont', 'Cont'),
        ('2', 'S2AGEY_E', 'S2AGEY_E:W2SAge(years)atIwEndMon Cont', 'Cont'),
        ('3', 'S3AGEY_E', 'S3AGEY_E:W3SAge(years)atIwEndMon Cont', 'Cont'),
        ('4', 'S4AGEY_E', 'S4AGEY_E:W4SAge(years)atIwEndMon Cont', 'Cont'),
        ('5', 'S5AGEY_E', 'S5AGEY_E:W5SAge(years)atIwEndMon Cont', 'Cont'),
        ('6', 'S6AGEY_E', 'S6AGEY_E:W6SAge(years)atIwEndMon Cont', 'Cont'),
        ('7', 'S7AGEY_E', 'S7AGEY_E:W7SAge(years)atIwEndMon Cont', 'Cont'),
        ('8', 'S8AGEY_E', 'S8AGEY_E:W8SAge(years)atIwEndMon Cont', 'Cont'),
        ('9', 'S9AGEY_E', 'S9AGEY_E:W9SAge(years)atIwEndMon Cont', 'Cont'),
        ('10', 'S10AGEY_E', 'S10AGEY_E:W10SAge(years)atIwEndMon Cont', 'Cont'),
        ('11', 'S11AGEY_E', 'S11AGEY_E:W11SAge(years)atIwEndMon Cont', 'Cont'),
        ('12', 'S12AGEY_E', 'S12AGEY_E:W12SAge(years)atIwEndMon Cont', 'Cont'),
        ('13', 'S13AGEY_E', 'S13AGEY_E:W13RAge(years)atIwEndMon Cont', 'Cont'),
        ('14', 'S14AGEY_E', 'S14AGEY_E:W14SAge(years)atIwEndMon Cont', 'Cont'),
        ('15', 'S15AGEY_E', 'S15AGEY_E:W15SAge(years)atIwEndMon Cont', 'Cont'),
        ('16', 'S16AGEY_E', 'S16AGEY_E:W16SAge(years)atIwEndMon Con', 'Con')
    AS t(wave_number, survey_variable_name, survey_variable_description, survey_variable_type)
)
SELECT 
    sl.rhrs_survey_section_id,
    w.hrs_wave_id,
    svm.survey_variable_name,
    svm.survey_variable_description,
    svm.survey_variable_type,
    CURRENT_DATE() as create_date,
    CURRENT_DATE() as update_date,
    true as active
FROM survey_variable_mapping svm
CROSS JOIN section_lookup sl
INNER JOIN dev_catalog.slv_cdm_hrs.hrs_wave w ON svm.wave_number = w.wave_number
ORDER BY svm.survey_variable_name;