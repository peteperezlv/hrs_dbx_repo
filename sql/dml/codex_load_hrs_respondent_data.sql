-- Load one RAND HRS hub row per natural respondent identifier.
-- Run after codex_load_hrs_cohort_data.sql.
-- The diagnostic queries report conflicting respondent/cohort assignments
-- and non-null cohort codes that have no matching cohort dimension row.
WITH source_respondents AS
(
    SELECT DISTINCT HHIDPN,
        TRY_CAST(HACOHORT AS TINYINT) AS hacohort
    FROM dev_catalog.brz_raw_hrs.randhrs1992_2022v1
    WHERE HHIDPN IS NOT NULL
)
SELECT HHIDPN,
    COUNT(DISTINCT hacohort) AS cohort_assignment_count
FROM source_respondents
GROUP BY HHIDPN
HAVING COUNT(DISTINCT hacohort) > 1;

WITH source_respondents AS
(
    SELECT DISTINCT HHIDPN,
        TRY_CAST(HACOHORT AS TINYINT) AS hacohort
    FROM dev_catalog.brz_raw_hrs.randhrs1992_2022v1
    WHERE HHIDPN IS NOT NULL
)
SELECT DISTINCT s.HHIDPN,
    s.hacohort
FROM source_respondents s
LEFT JOIN dev_catalog.slv_cdm_hrs.codex_dim_cohort c
    ON s.hacohort = c.hacohort
WHERE s.hacohort IS NOT NULL
    AND c.cohort_id IS NULL;

WITH source_respondents AS
(
    SELECT DISTINCT HHIDPN,
        TRY_CAST(HACOHORT AS TINYINT) AS hacohort
    FROM dev_catalog.brz_raw_hrs.randhrs1992_2022v1
    WHERE HHIDPN IS NOT NULL
),
consistent_respondents AS
(
    SELECT HHIDPN,
        MAX(hacohort) AS hacohort
    FROM source_respondents
    GROUP BY HHIDPN
    HAVING COUNT(DISTINCT hacohort) <= 1
)
INSERT INTO dev_catalog.slv_cdm_hrs.codex_hub_respondent
(
    cohort_id,
    hhidpn,
    create_date,
    update_date,
    active
)
SELECT c.cohort_id,
    s.HHIDPN AS hhidpn,
    CURRENT_DATE() AS create_date,
    CURRENT_DATE() AS update_date,
    TRUE AS active
FROM consistent_respondents s
LEFT JOIN dev_catalog.slv_cdm_hrs.codex_dim_cohort c
    ON s.hacohort = c.hacohort
WHERE (s.hacohort IS NULL OR c.cohort_id IS NOT NULL)
    AND NOT EXISTS
    (
        SELECT 1
        FROM dev_catalog.slv_cdm_hrs.codex_hub_respondent t
        WHERE t.hhidpn = s.HHIDPN
    );
