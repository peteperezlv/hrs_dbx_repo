-- Load distinct RAND HRS cohort codes.
-- Run before codex_load_hrs_respondent_data.sql.
WITH source_cohorts AS
(
    SELECT DISTINCT TRY_CAST(HACOHORT AS TINYINT) AS hacohort
    FROM dev_catalog.brz_raw_hrs.randhrs1992_2022v1
    WHERE HACOHORT IS NOT NULL
)
INSERT INTO dev_catalog.slv_cdm_hrs.codex_dim_cohort
(
    hacohort,
    create_date,
    update_date,
    active
)
SELECT s.hacohort,
    CURRENT_DATE() AS create_date,
    CURRENT_DATE() AS update_date,
    TRUE AS active
FROM source_cohorts s
WHERE s.hacohort IS NOT NULL
    AND NOT EXISTS
    (
        SELECT 1
        FROM dev_catalog.slv_cdm_hrs.codex_dim_cohort t
        WHERE t.hacohort = s.hacohort
    );
