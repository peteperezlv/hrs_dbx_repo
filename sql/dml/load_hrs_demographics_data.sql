-- =====================================================================
-- HRS Silver CDM DML Functional Specification (Wave Expansion Rule)
-- =====================================================================
-- Objective:
--   Load dev_catalog.slv_cdm_hrs.hrs_demographics from
--   dev_catalog.brz_raw_hrs.randhrs1992_2022v1 using:
--     - Wide → long wave expansion (1 row per respondent per wave)
--     - FK resolution via hrs_respondent (hhidpn) and hrs_wave (wave_number)
--     - RAND type transformations (CONT, CATEG, CHAR)
--     - Insert-only load pattern
--
-- Wave Expansion Rule:
--   For each multi-wave target column (agey_e, cenreg, mstat), generate
--   16 SELECT branches (waves 1–16) and UNION ALL them into an "expanded"
--   dataset with columns:
--     HHIDPN, wave_number, agey_e, cenreg, mstat, raracem, rahispan,
--     raedyrs, rarelig, ravetrn
--
-- FK Rules:
--   respondent_id: join hrs_respondent on hhidpn
--   wave_id      : join hrs_wave on wave_number
--
-- Business Key:
--   UNIQUE (respondent_id, wave_id)
--
-- =====================================================================
-- COMPLETE 16-WAVE DML (Demographics)
-- =====================================================================
WITH expanded AS (
    -- Wave 1
    SELECT src.HHIDPN AS hhidpn,
        1 AS wave_number,
        TRY_CAST(src.R1AGEY_E AS DECIMAL(10, 2)) AS agey_e,
        TRY_CAST(src.RARACEM AS INT) AS raracem,
        TRY_CAST(src.RAHISPN AS INT) AS rahispan,
        TRY_CAST(src.R1CENREG AS INT) AS cenreg,
        TRY_CAST(src.RAEDYRS AS INT) AS raedyrs,
        TRY_CAST(src.R1MSTAT AS INT) AS mstat,
        TRY_CAST(src.RARELIG AS INT) AS rarelig,
        TRY_CAST(src.RAVETRN AS INT) AS ravetrn
    FROM dev_catalog.brz_raw_hrs.randhrs1992_2022v1 src
    UNION ALL
    -- Wave 2
    SELECT src.HHIDPN,
        2,
        TRY_CAST(src.R2AGEY_E AS DECIMAL(10, 2)),
        TRY_CAST(src.RARACEM AS INT),
        TRY_CAST(src.RAHISPN AS INT),
        TRY_CAST(src.R2CENREG AS INT),
        TRY_CAST(src.RAEDYRS AS INT),
        TRY_CAST(src.R2MSTAT AS INT),
        TRY_CAST(src.RARELIG AS INT),
        TRY_CAST(src.RAVETRN AS INT)
    FROM dev_catalog.brz_raw_hrs.randhrs1992_2022v1 src
    UNION ALL
    -- Wave 3
    SELECT src.HHIDPN,
        3,
        TRY_CAST(src.R3AGEY_E AS DECIMAL(10, 2)),
        TRY_CAST(src.RARACEM AS INT),
        TRY_CAST(src.RAHISPAN AS INT),
        TRY_CAST(src.R3CENREG AS INT),
        TRY_CAST(src.RAEDYRS AS INT),
        TRY_CAST(src.R3MSTAT AS INT),
        TRY_CAST(src.RARELIG AS INT),
        TRY_CAST(src.RAVETRN AS INT)
    FROM dev_catalog.brz_raw_hrs.randhrs1992_2022v1 src
    UNION ALL
    -- Wave 4
    SELECT src.HHIDPN,
        4,
        TRY_CAST(src.R4AGEY_E AS DECIMAL(10, 2)),
        TRY_CAST(src.RARACEM AS INT),
        TRY_CAST(src.RAHISPAN AS INT),
        TRY_CAST(src.R4CENREG AS INT),
        TRY_CAST(src.RAEDYRS AS INT),
        TRY_CAST(src.R4MSTAT AS INT),
        TRY_CAST(src.RARELIG AS INT),
        TRY_CAST(src.RAVETRN AS INT)
    FROM dev_catalog.brz_raw_hrs.randhrs1992_2022v1 src
    UNION ALL
    -- Wave 5
    SELECT src.HHIDPN,
        5,
        TRY_CAST(src.R5AGEY_E AS DECIMAL(10, 2)),
        TRY_CAST(src.RARACEM AS INT),
        TRY_CAST(src.RAHISPAN AS INT),
        TRY_CAST(src.R5CENREG AS INT),
        TRY_CAST(src.RAEDYRS AS INT),
        TRY_CAST(src.R5MSTAT AS INT),
        TRY_CAST(src.RARELIG AS INT),
        TRY_CAST(src.RAVETRN AS INT)
    FROM dev_catalog.brz_raw_hrs.randhrs1992_2022v1 src
    UNION ALL
    -- Wave 6
    SELECT src.HHIDPN,
        6,
        TRY_CAST(src.R6AGEY_E AS DECIMAL(10, 2)),
        TRY_CAST(src.RARACEM AS INT),
        TRY_CAST(src.RAHISPAN AS INT),
        TRY_CAST(src.R6CENREG AS INT),
        TRY_CAST(src.RAEDYRS AS INT),
        TRY_CAST(src.R6MSTAT AS INT),
        TRY_CAST(src.RARELIG AS INT),
        TRY_CAST(src.RAVETRN AS INT)
    FROM dev_catalog.brz_raw_hrs.randhrs1992_2022v1 src
    UNION ALL
    -- Wave 7
    SELECT src.HHIDPN,
        7,
        TRY_CAST(src.R7AGEY_E AS DECIMAL(10, 2)),
        TRY_CAST(src.RARACEM AS INT),
        TRY_CAST(src.RAHISPAN AS INT),
        TRY_CAST(src.R7CENREG AS INT),
        TRY_CAST(src.RAEDYRS AS INT),
        TRY_CAST(src.R7MSTAT AS INT),
        TRY_CAST(src.RARELIG AS INT),
        TRY_CAST(src.RAVETRN AS INT)
    FROM dev_catalog.brz_raw_hrs.randhrs1992_2022v1 src
    UNION ALL
    -- Wave 8
    SELECT src.HHIDPN,
        8,
        TRY_CAST(src.R8AGEY_E AS DECIMAL(10, 2)),
        TRY_CAST(src.RARACEM AS INT),
        TRY_CAST(src.RAHISPAN AS INT),
        TRY_CAST(src.R8CENREG AS INT),
        TRY_CAST(src.RAEDYRS AS INT),
        TRY_CAST(src.R8MSTAT AS INT),
        TRY_CAST(src.RARELIG AS INT),
        TRY_CAST(src.RAVETRN AS INT)
    FROM dev_catalog.brz_raw_hrs.randhrs1992_2022v1 src
    UNION ALL
    -- Wave 9
    SELECT src.HHIDPN,
        9,
        TRY_CAST(src.R9AGEY_E AS DECIMAL(10, 2)),
        TRY_CAST(src.RARACEM AS INT),
        TRY_CAST(src.RAHISPAN AS INT),
        TRY_CAST(src.R9CENREG AS INT),
        TRY_CAST(src.RAEDYRS AS INT),
        TRY_CAST(src.R9MSTAT AS INT),
        TRY_CAST(src.RARELIG AS INT),
        TRY_CAST(src.RAVETRN AS INT)
    FROM dev_catalog.brz_raw_hrs.randhrs1992_2022v1 src
    UNION ALL
    -- Wave 10
    SELECT src.HHIDPN,
        10,
        TRY_CAST(src.R10AGEY_E AS DECIMAL(10, 2)),
        TRY_CAST(src.RARACEM AS INT),
        TRY_CAST(src.RAHISPAN AS INT),
        TRY_CAST(src.R10CENREG AS INT),
        TRY_CAST(src.RAEDYRS AS INT),
        TRY_CAST(src.R10MSTAT AS INT),
        TRY_CAST(src.RARELIG AS INT),
        TRY_CAST(src.RAVETRN AS INT)
    FROM dev_catalog.brz_raw_hrs.randhrs1992_2022v1 src
    UNION ALL
    -- Wave 11
    SELECT src.HHIDPN,
        11,
        TRY_CAST(src.R11AGEY_E AS DECIMAL(10, 2)),
        TRY_CAST(src.RARACEM AS INT),
        TRY_CAST(src.RAHISPAN AS INT),
        TRY_CAST(src.R11CENREG AS INT),
        TRY_CAST(src.RAEDYRS AS INT),
        TRY_CAST(src.R11MSTAT AS INT),
        TRY_CAST(src.RARELIG AS INT),
        TRY_CAST(src.RAVETRN AS INT)
    FROM dev_catalog.brz_raw_hrs.randhrs1992_2022v1 src
    UNION ALL
    -- Wave 12
    SELECT src.HHIDPN,
        12,
        TRY_CAST(src.R12AGEY_E AS DECIMAL(10, 2)),
        TRY_CAST(src.RARACEM AS INT),
        TRY_CAST(src.RAHISPAN AS INT),
        TRY_CAST(src.R12CENREG AS INT),
        TRY_CAST(src.RAEDYRS AS INT),
        TRY_CAST(src.R12MSTAT AS INT),
        TRY_CAST(src.RARELIG AS INT),
        TRY_CAST(src.RAVETRN AS INT)
    FROM dev_catalog.brz_raw_hrs.randhrs1992_2022v1 src
    UNION ALL
    -- Wave 13
    SELECT src.HHIDPN,
        13,
        TRY_CAST(src.R13AGEY_E AS DECIMAL(10, 2)),
        TRY_CAST(src.RARACEM AS INT),
        TRY_CAST(src.RAHISPAN AS INT),
        TRY_CAST(src.R13CENREG AS INT),
        TRY_CAST(src.RAEDYRS AS INT),
        TRY_CAST(src.R13MSTAT AS INT),
        TRY_CAST(src.RARELIG AS INT),
        TRY_CAST(src.RAVETRN AS INT)
    FROM dev_catalog.brz_raw_hrs.randhrs1992_2022v1 src
    UNION ALL
    -- Wave 14
    SELECT src.HHIDPN,
        14,
        TRY_CAST(src.R14AGEY_E AS DECIMAL(10, 2)),
        TRY_CAST(src.RARACEM AS INT),
        TRY_CAST(src.RAHISPAN AS INT),
        TRY_CAST(src.R14CENREG AS INT),
        TRY_CAST(src.RAEDYRS AS INT),
        TRY_CAST(src.R14MSTAT AS INT),
        TRY_CAST(src.RARELIG AS INT),
        TRY_CAST(src.RAVETRN AS INT)
    FROM dev_catalog.brz_raw_hrs.randhrs1992_2022v1 src
    UNION ALL
    -- Wave 15
    SELECT src.HHIDPN,
        15,
        TRY_CAST(src.R15AGEY_E AS DECIMAL(10, 2)),
        TRY_CAST(src.RARACEM AS INT),
        TRY_CAST(src.RAHISPAN AS INT),
        TRY_CAST(src.R15CENREG AS INT),
        TRY_CAST(src.RAEDYRS AS INT),
        TRY_CAST(src.R15MSTAT AS INT),
        TRY_CAST(src.RARELIG AS INT),
        TRY_CAST(src.RAVETRN AS INT)
    FROM dev_catalog.brz_raw_hrs.randhrs1992_2022v1 src
    UNION ALL
    -- Wave 16
    SELECT src.HHIDPN,
        16,
        TRY_CAST(src.R16AGEY_E AS DECIMAL(10, 2)),
        TRY_CAST(src.RARACEM AS INT),
        TRY_CAST(src.RAHISPAN AS INT),
        TRY_CAST(src.R16CENREG AS INT),
        TRY_CAST(src.RAEDYRS AS INT),
        TRY_CAST(src.R16MSTAT AS INT),
        TRY_CAST(src.RARELIG AS INT),
        TRY_CAST(src.RAVETRN AS INT)
    FROM dev_catalog.brz_raw_hrs.randhrs1992_2022v1 src
),
resolved AS (
    SELECT NULL AS hrs_demographics_id,
        r.respondent_id AS respondent_id,
        w.wave_id AS wave_id,
        e.hhidpn AS hhidpn,
        e.wave_number AS wave_number,
        CURRENT_DATE() AS create_date,
        CURRENT_DATE() AS update_date,
        TRUE AS active,
        e.agey_e AS agey_e,
        e.raracem AS raracem,
        e.rahispan AS rahispan,
        e.cenreg AS cenreg,
        e.raedyrs AS raedyrs,
        e.mstat AS mstat,
        e.rarelig AS rarelig,
        e.ravetrn AS ravetrn,
        ROW_NUMBER() OVER (
            PARTITION BY r.respondent_id,
            w.wave_id
            ORDER BY e.hhidpn
        ) AS rn
    FROM expanded e
        JOIN dev_catalog.slv_cdm_hrs.hrs_respondent r ON r.hhidpn = e.hhidpn
        JOIN dev_catalog.slv_cdm_hrs.hrs_wave w ON w.wave_number = e.wave_number
)
INSERT INTO dev_catalog.slv_cdm_hrs.hrs_demographics (
        hrs_demographics_id,
        respondent_id,
        wave_id,
        hhidpn,
        wave_number,
        create_date,
        update_date,
        active,
        agey_e,
        raracem,
        rahispan,
        cenreg,
        raedyrs,
        mstat,
        rarelig,
        ravetrn
    )
SELECT hrs_demographics_id,
    respondent_id,
    wave_id,
    hhidpn,
    wave_number,
    create_date,
    update_date,
    active,
    agey_e,
    raracem,
    rahispan,
    cenreg,
    raedyrs,
    mstat,
    rarelig,
    ravetrn
FROM resolved
WHERE rn = 1;