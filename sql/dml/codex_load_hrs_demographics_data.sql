-- Load one RAND HRS demographic observation per respondent and wave.
-- Run after the cohort, wave, and respondent loads.
-- Wave-invariant source attributes RARACEM, RAGENDER, and RAHISPAN are
-- associated with every respondent-wave observation; age is wave-specific.
WITH source_base AS
(
    SELECT HHIDPN,
        RARACEM,
        RAGENDER,
        RAHISPAN,
        R1AGEY_E,
        R2AGEY_E,
        R3AGEY_E,
        R4AGEY_E,
        R5AGEY_E,
        R6AGEY_E,
        R7AGEY_E,
        R8AGEY_E,
        R9AGEY_E,
        R10AGEY_E,
        R11AGEY_E,
        R12AGEY_E,
        R13AGEY_E,
        R14AGEY_E,
        R15AGEY_E,
        R16AGEY_E
    FROM dev_catalog.brz_raw_hrs.randhrs1992_2022v1
),
wave_observations AS
(
    SELECT HHIDPN,
        wave_number,
        TRY_CAST(agey_e AS TINYINT) AS agey_e
    FROM source_base
    UNPIVOT INCLUDE NULLS
    (
        agey_e FOR wave_number IN
        (
        R1AGEY_E AS `1`,
        R2AGEY_E AS `2`,
        R3AGEY_E AS `3`,
        R4AGEY_E AS `4`,
        R5AGEY_E AS `5`,
        R6AGEY_E AS `6`,
        R7AGEY_E AS `7`,
        R8AGEY_E AS `8`,
        R9AGEY_E AS `9`,
        R10AGEY_E AS `10`,
        R11AGEY_E AS `11`,
        R12AGEY_E AS `12`,
        R13AGEY_E AS `13`,
        R14AGEY_E AS `14`,
        R15AGEY_E AS `15`,
        R16AGEY_E AS `16`
        )
    )
),
resolved_observations AS
(
    SELECT r.respondent_id,
        w.wave_id,
        TRY_CAST(o.agey_e AS TINYINT) AS agey_e,
        TRY_CAST(s.RARACEM AS TINYINT) AS raracem,
        TRY_CAST(s.RAGENDER AS TINYINT) AS ragender,
        TRY_CAST(s.RAHISPAN AS TINYINT) AS rahispan
    FROM wave_observations o
    JOIN source_base s
        ON o.HHIDPN = s.HHIDPN
    LEFT JOIN dev_catalog.slv_cdm_hrs.codex_hub_respondent r
        ON o.HHIDPN = r.hhidpn
    LEFT JOIN dev_catalog.slv_cdm_hrs.codex_dim_wave w
        ON o.wave_number = w.wave_number
),
deduplicated_observations AS
(
    SELECT DISTINCT *
    FROM resolved_observations
),
unique_business_keys AS
(
    SELECT respondent_id,
        wave_id
    FROM deduplicated_observations
    WHERE respondent_id IS NOT NULL AND wave_id IS NOT NULL
    GROUP BY respondent_id, wave_id
    HAVING COUNT(*) = 1
)
SELECT respondent_id,
    wave_id
FROM resolved_observations
WHERE respondent_id IS NULL OR wave_id IS NULL;

WITH source_base AS
(
    SELECT HHIDPN,
        RARACEM,
        RAGENDER,
        RAHISPAN,
        R1AGEY_E,
        R2AGEY_E,
        R3AGEY_E,
        R4AGEY_E,
        R5AGEY_E,
        R6AGEY_E,
        R7AGEY_E,
        R8AGEY_E,
        R9AGEY_E,
        R10AGEY_E,
        R11AGEY_E,
        R12AGEY_E,
        R13AGEY_E,
        R14AGEY_E,
        R15AGEY_E,
        R16AGEY_E
    FROM dev_catalog.brz_raw_hrs.randhrs1992_2022v1
),
wave_observations AS
(
    SELECT HHIDPN,
        wave_number,
        TRY_CAST(agey_e AS TINYINT) AS agey_e
    FROM source_base
    UNPIVOT INCLUDE NULLS
    (
        agey_e FOR wave_number IN
        (
        R1AGEY_E AS `1`,
        R2AGEY_E AS `2`,
        R3AGEY_E AS `3`,
        R4AGEY_E AS `4`,
        R5AGEY_E AS `5`,
        R6AGEY_E AS `6`,
        R7AGEY_E AS `7`,
        R8AGEY_E AS `8`,
        R9AGEY_E AS `9`,
        R10AGEY_E AS `10`,
        R11AGEY_E AS `11`,
        R12AGEY_E AS `12`,
        R13AGEY_E AS `13`,
        R14AGEY_E AS `14`,
        R15AGEY_E AS `15`,
        R16AGEY_E AS `16`
        )
    )
),
resolved_observations AS
(
    SELECT r.respondent_id,
        w.wave_id,
        TRY_CAST(o.agey_e AS TINYINT) AS agey_e,
        TRY_CAST(s.RARACEM AS TINYINT) AS raracem,
        TRY_CAST(s.RAGENDER AS TINYINT) AS ragender,
        TRY_CAST(s.RAHISPAN AS TINYINT) AS rahispan
    FROM wave_observations o
    JOIN source_base s
        ON o.HHIDPN = s.HHIDPN
    LEFT JOIN dev_catalog.slv_cdm_hrs.codex_hub_respondent r
        ON o.HHIDPN = r.hhidpn
    LEFT JOIN dev_catalog.slv_cdm_hrs.codex_dim_wave w
        ON o.wave_number = w.wave_number
),
deduplicated_observations AS
(
    SELECT DISTINCT *
    FROM resolved_observations
),
unique_business_keys AS
(
    SELECT respondent_id,
        wave_id
    FROM deduplicated_observations
    WHERE respondent_id IS NOT NULL AND wave_id IS NOT NULL
    GROUP BY respondent_id, wave_id
    HAVING COUNT(*) = 1
)
SELECT respondent_id,
    wave_id,
    COUNT(*) AS record_count
FROM deduplicated_observations
WHERE respondent_id IS NOT NULL AND wave_id IS NOT NULL
GROUP BY respondent_id, wave_id
HAVING COUNT(*) > 1;

WITH source_base AS
(
    SELECT HHIDPN,
        RARACEM,
        RAGENDER,
        RAHISPAN,
        R1AGEY_E,
        R2AGEY_E,
        R3AGEY_E,
        R4AGEY_E,
        R5AGEY_E,
        R6AGEY_E,
        R7AGEY_E,
        R8AGEY_E,
        R9AGEY_E,
        R10AGEY_E,
        R11AGEY_E,
        R12AGEY_E,
        R13AGEY_E,
        R14AGEY_E,
        R15AGEY_E,
        R16AGEY_E
    FROM dev_catalog.brz_raw_hrs.randhrs1992_2022v1
),
wave_observations AS
(
    SELECT HHIDPN,
        wave_number,
        TRY_CAST(agey_e AS TINYINT) AS agey_e
    FROM source_base
    UNPIVOT INCLUDE NULLS
    (
        agey_e FOR wave_number IN
        (
        R1AGEY_E AS `1`,
        R2AGEY_E AS `2`,
        R3AGEY_E AS `3`,
        R4AGEY_E AS `4`,
        R5AGEY_E AS `5`,
        R6AGEY_E AS `6`,
        R7AGEY_E AS `7`,
        R8AGEY_E AS `8`,
        R9AGEY_E AS `9`,
        R10AGEY_E AS `10`,
        R11AGEY_E AS `11`,
        R12AGEY_E AS `12`,
        R13AGEY_E AS `13`,
        R14AGEY_E AS `14`,
        R15AGEY_E AS `15`,
        R16AGEY_E AS `16`
        )
    )
),
resolved_observations AS
(
    SELECT r.respondent_id,
        w.wave_id,
        TRY_CAST(o.agey_e AS TINYINT) AS agey_e,
        TRY_CAST(s.RARACEM AS TINYINT) AS raracem,
        TRY_CAST(s.RAGENDER AS TINYINT) AS ragender,
        TRY_CAST(s.RAHISPAN AS TINYINT) AS rahispan
    FROM wave_observations o
    JOIN source_base s
        ON o.HHIDPN = s.HHIDPN
    LEFT JOIN dev_catalog.slv_cdm_hrs.codex_hub_respondent r
        ON o.HHIDPN = r.hhidpn
    LEFT JOIN dev_catalog.slv_cdm_hrs.codex_dim_wave w
        ON o.wave_number = w.wave_number
),
deduplicated_observations AS
(
    SELECT DISTINCT *
    FROM resolved_observations
),
unique_business_keys AS
(
    SELECT respondent_id,
        wave_id
    FROM deduplicated_observations
    WHERE respondent_id IS NOT NULL AND wave_id IS NOT NULL
    GROUP BY respondent_id, wave_id
    HAVING COUNT(*) = 1
)
INSERT INTO dev_catalog.slv_cdm_hrs.codex_fact_demographics
(
    respondent_id,
    wave_id,
    agey_e,
    raracem,
    ragender,
    rahispan,
    create_date,
    update_date,
    active
)
SELECT s.respondent_id,
    s.wave_id,
    s.agey_e,
    s.raracem,
    s.ragender,
    s.rahispan,
    CURRENT_DATE() AS create_date,
    CURRENT_DATE() AS update_date,
    TRUE AS active
FROM deduplicated_observations s
JOIN unique_business_keys k
    ON s.respondent_id = k.respondent_id
    AND s.wave_id = k.wave_id
WHERE NOT EXISTS
    (
        SELECT 1
        FROM dev_catalog.slv_cdm_hrs.codex_fact_demographics t
        WHERE t.respondent_id = s.respondent_id
            AND t.wave_id = s.wave_id
    );
