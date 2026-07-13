-- Load RHRS Survey Section Reference Data
-- Target: dev_catalog.slv_cdm_hrs.rhrs_survey_section
-- rhrs_survey_section_id is auto-generated (IDENTITY column)

INSERT INTO dev_catalog.slv_cdm_hrs.rhrs_survey_section (
    rhrs_survey_section_name,
    rhrs_survey_section_description,
    create_date,
    update_date,
    active
)
VALUES
    ('Section A', 'Section A: Demographics,Identifiers,andWeights 59', CURRENT_DATE(), CURRENT_DATE(), true),
    ('Section B', 'Section B: Health 246', CURRENT_DATE(), CURRENT_DATE(), true),
    ('Section C', 'Section C: FunctionalLimitationsandHelpers 853', CURRENT_DATE(), CURRENT_DATE(), true),
    ('Section D', 'Section D: FinancialandHousingWealth 1149', CURRENT_DATE(), CURRENT_DATE(), true),
    ('Section E', 'Section E: Income 1246', CURRENT_DATE(), CURRENT_DATE(), true),
    ('Section F', 'Section F: SocialSecurity 1386', CURRENT_DATE(), CURRENT_DATE(), true),
    ('Section G', 'Section G: Pensions 1486', CURRENT_DATE(), CURRENT_DATE(), true),
    ('Section H', 'Section H: HealthInsurance 1613', CURRENT_DATE(), CURRENT_DATE(), true),
    ('Section I', 'Section I: FamilyStructure 1761', CURRENT_DATE(), CURRENT_DATE(), true),
    ('Section J', 'Section J: RetirementPlans,Expectations 1777', CURRENT_DATE(), CURRENT_DATE(), true),
    ('Section K', 'Section K: EmploymentHistory 1877', CURRENT_DATE(), CURRENT_DATE(), true),
    ('Section L', 'Section L: LeaveBehindPsycho-SocialQuestionnair', CURRENT_DATE(), CURRENT_DATE(), true);