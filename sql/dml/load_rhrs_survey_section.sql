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
    ('Section A: Demographics,Identifiers,andWeights 59', 'Section A: Demographics,Identifiers,andWeights 59', CURRENT_DATE(), CURRENT_DATE(), true),
    ('Section B: Health 246', 'Section B: Health 246', CURRENT_DATE(), CURRENT_DATE(), true),
    ('Section C: FunctionalLimitationsandHelpers 853', 'Section C: FunctionalLimitationsandHelpers 853', CURRENT_DATE(), CURRENT_DATE(), true),
    ('Section D: FinancialandHousingWealth 1149', 'Section D: FinancialandHousingWealth 1149', CURRENT_DATE(), CURRENT_DATE(), true),
    ('Section E: Income 1246', 'Section E: Income 1246', CURRENT_DATE(), CURRENT_DATE(), true),
    ('Section F: SocialSecurity 1386', 'Section F: SocialSecurity 1386', CURRENT_DATE(), CURRENT_DATE(), true),
    ('Section G: Pensions 1486', 'Section G: Pensions 1486', CURRENT_DATE(), CURRENT_DATE(), true),
    ('Section H: HealthInsurance 1613', 'Section H: HealthInsurance 1613', CURRENT_DATE(), CURRENT_DATE(), true),
    ('Section I: FamilyStructure 1761', 'Section I: FamilyStructure 1761', CURRENT_DATE(), CURRENT_DATE(), true),
    ('Section J: RetirementPlans,Expectations 1777', 'Section J: RetirementPlans,Expectations 1777', CURRENT_DATE(), CURRENT_DATE(), true),
    ('Section K: EmploymentHistory 1877', 'Section K: EmploymentHistory 1877', CURRENT_DATE(), CURRENT_DATE(), true),
    ('Section L: LeaveBehindPsycho-SocialQuestionnair', 'Section L: LeaveBehindPsycho-SocialQuestionnair', CURRENT_DATE(), CURRENT_DATE(), true);