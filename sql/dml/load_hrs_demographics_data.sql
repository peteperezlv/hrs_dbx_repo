-- =====================================================================
-- AI Assistant Used: Claude and Genie
--
-- Objective:
--   Load dev_catalog.slv_cdm_hrs.hrs_demographics from
--   dev_catalog.brz_raw_hrs.randhrs1992_2022v1 using:
--     - Wide → long wave expansion (1 row per respondent per wave)
--     - FK resolution via hrs_respondent (hhidpn) and hrs_wave (wave_number)
--     - RAND type transformations (CONT, CATEG, CHAR)
--     - Insert-only load pattern
-- Generated per Specification Document: /notebooks/DDL Specifications/hrs_deomographics_specification.ipynb
--     - Load Pattern: Insert Only (Section 4)
--     - Grain: One row per respondent per survey wave (Section 9)
--     - Section 12 'Wave' column = wave_number inserted into target
--
-- ASSUMPTION (carried forward):
--   Source is a wide table, one row per respondent (HHIDPN).
--   Wave-varying: R{n}AGEY_E, R{n}CENREG, R{n}MSTAT (n = 1..16)
--   Wave-invariant (replicated across all 16 wave rows):
--     RARACEM, RAHISPN, RAEDYRS, RARELIG, RAVETRN
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
-- =====================================================================
TRUNCATE TABLE dev_catalog.slv_cdm_hrs.hrs_demographics;
--
INSERT INTO dev_catalog.slv_cdm_hrs.hrs_demographics (
        respondent_id,
        wave_id,
        hhidpn,
        wave_number,
        agey_e,
        raracem,
        rahispan,
        cenreg,
        raedyrs,
        mstat,
        rarelig,
        ravetrn,
        create_date,
        update_date,
        active
    ) WITH source_base AS (
        SELECT HHIDPN,
            TRY_CAST(RARACEM AS TINYINT) AS raracem,
            TRY_CAST(RAHISPAN AS TINYINT) AS rahispan,
            TRY_CAST(RAEDYRS AS TINYINT) AS raedyrs,
            TRY_CAST(RARELIG AS TINYINT) AS rarelig,
            TRY_CAST(RAVETRN AS TINYINT) AS ravetrn,
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
            R16AGEY_E,
            R1CENREG,
            R2CENREG,
            R3CENREG,
            R4CENREG,
            R5CENREG,
            R6CENREG,
            R7CENREG,
            R8CENREG,
            R9CENREG,
            R10CENREG,
            R11CENREG,
            R12CENREG,
            R13CENREG,
            R14CENREG,
            R15CENREG,
            R16CENREG,
            R1MSTAT,
            R2MSTAT,
            R3MSTAT,
            R4MSTAT,
            R5MSTAT,
            R6MSTAT,
            R7MSTAT,
            R8MSTAT,
            R9MSTAT,
            R10MSTAT,
            R11MSTAT,
            R12MSTAT,
            R13MSTAT,
            R14MSTAT,
            R15MSTAT,
            R16MSTAT
        FROM dev_catalog.brz_raw_hrs.randhrs1992_2022v1
    ),
    wave_unpivoted AS (
        --wave 1
        SELECT HHIDPN,
            CAST(1 AS STRING) AS wave_number,
            TRY_CAST(R1AGEY_E AS DECIMAL(10, 2)) AS agey_e,
            TRY_CAST(R1CENREG AS TINYINT) AS cenreg,
            TRY_CAST(R1MSTAT AS TINYINT) AS mstat
        FROM source_base
        UNION ALL
        --wave 2
        SELECT HHIDPN,
            CAST(2 AS STRING) AS wave_number,
            TRY_CAST(R2AGEY_E AS DECIMAL(10, 2)),
            TRY_CAST(R2CENREG AS TINYINT),
            TRY_CAST(R2MSTAT AS TINYINT)
        FROM source_base
        UNION ALL
        -- Wave 3
        SELECT HHIDPN,
            CAST(3 AS STRING) AS wave_number,
            TRY_CAST(R3AGEY_E AS DECIMAL(10, 2)),
            TRY_CAST(R3CENREG AS TINYINT),
            TRY_CAST(R3MSTAT AS TINYINT)
        FROM source_base
        UNION ALL
        -- Wave 4
        SELECT HHIDPN,
            CAST(4 AS STRING) AS wave_number,
            TRY_CAST(R4AGEY_E AS DECIMAL(10, 2)),
            TRY_CAST(R4CENREG AS TINYINT),
            TRY_CAST(R4MSTAT AS TINYINT)
        FROM source_base
        UNION ALL
        -- Wave 5
        SELECT HHIDPN,
            CAST(5 AS STRING) AS wave_number,
            TRY_CAST(R5AGEY_E AS DECIMAL(10, 2)),
            TRY_CAST(R5CENREG AS TINYINT),
            TRY_CAST(R5MSTAT AS TINYINT)
        FROM source_base
        UNION ALL
        -- Wave 6
        SELECT HHIDPN,
            CAST(6 AS STRING) AS wave_number,
            TRY_CAST(R6AGEY_E AS DECIMAL(10, 2)),
            TRY_CAST(R6CENREG AS TINYINT),
            TRY_CAST(R6MSTAT AS TINYINT)
        FROM source_base
        UNION ALL
        -- Wave 7
        SELECT HHIDPN,
            CAST(7 AS STRING) AS wave_number,
            TRY_CAST(R7AGEY_E AS DECIMAL(10, 2)),
            TRY_CAST(R7CENREG AS TINYINT),
            TRY_CAST(R7MSTAT AS TINYINT)
        FROM source_base
        UNION ALL
        -- Wave 8
        SELECT HHIDPN,
            CAST(8 AS STRING) AS wave_number,
            TRY_CAST(R8AGEY_E AS DECIMAL(10, 2)),
            TRY_CAST(R8CENREG AS TINYINT),
            TRY_CAST(R8MSTAT AS TINYINT)
        FROM source_base
        UNION ALL
        -- Wave 9
        SELECT HHIDPN,
            CAST(9 AS STRING) AS wave_number,
            TRY_CAST(R9AGEY_E AS DECIMAL(10, 2)),
            TRY_CAST(R9CENREG AS TINYINT),
            TRY_CAST(R9MSTAT AS TINYINT)
        FROM source_base
        UNION ALL
        -- Wave 10
        SELECT HHIDPN,
            CAST(10 AS STRING) AS wave_number,
            TRY_CAST(R10AGEY_E AS DECIMAL(10, 2)),
            TRY_CAST(R10CENREG AS TINYINT),
            TRY_CAST(R10MSTAT AS TINYINT)
        FROM source_base
        UNION ALL
        -- Wave 11
        SELECT HHIDPN,
            CAST(11 AS STRING) AS wave_number,
            TRY_CAST(R11AGEY_E AS DECIMAL(10, 2)),
            TRY_CAST(R11CENREG AS TINYINT),
            TRY_CAST(R11MSTAT AS TINYINT)
        FROM source_base
        UNION ALL
        -- Wave 12
        SELECT HHIDPN,
            CAST(12 AS STRING) AS wave_number,
            TRY_CAST(R12AGEY_E AS DECIMAL(10, 2)),
            TRY_CAST(R12CENREG AS TINYINT),
            TRY_CAST(R12MSTAT AS TINYINT)
        FROM source_base
        UNION ALL
        -- Wave 13
        SELECT HHIDPN,
            CAST(13 AS STRING) AS wave_number,
            TRY_CAST(R13AGEY_E AS DECIMAL(10, 2)),
            TRY_CAST(R13CENREG AS TINYINT),
            TRY_CAST(R13MSTAT AS TINYINT)
        FROM source_base
        UNION ALL
        -- Wave 14
        SELECT HHIDPN,
            CAST(14 AS STRING) AS wave_number,
            TRY_CAST(R14AGEY_E AS DECIMAL(10, 2)),
            TRY_CAST(R14CENREG AS TINYINT),
            TRY_CAST(R14MSTAT AS TINYINT)
        FROM source_base
        UNION ALL
        -- Wave 15
        SELECT HHIDPN,
            CAST(15 AS STRING) AS wave_number,
            TRY_CAST(R15AGEY_E AS DECIMAL(10, 2)),
            TRY_CAST(R15CENREG AS TINYINT),
            TRY_CAST(R15MSTAT AS TINYINT)
        FROM source_base
        UNION ALL
        -- Wave 16
        SELECT HHIDPN,
            CAST(16 AS STRING) AS wave_number,
            TRY_CAST(R16AGEY_E AS DECIMAL(10, 2)),
            TRY_CAST(R16CENREG AS TINYINT),
            TRY_CAST(R16MSTAT AS TINYINT)
        FROM source_base
    )
SELECT r.respondent_id,
    w.wave_id,
    wu.HHIDPN AS hhidpn,
    wu.wave_number,
    wu.agey_e,
    sb.raracem,
    sb.rahispan,
    wu.cenreg,
    sb.raedyrs,
    wu.mstat,
    sb.rarelig,
    sb.ravetrn,
    CURRENT_DATE() AS create_date,
    CURRENT_DATE() AS update_date,
    TRUE AS active
FROM wave_unpivoted wu
    JOIN source_base sb ON wu.HHIDPN = sb.HHIDPN
    JOIN dev_catalog.slv_cdm_hrs.hrs_respondent r ON wu.HHIDPN = r.HHIDPN
    JOIN dev_catalog.slv_cdm_hrs.hrs_wave w ON wu.wave_number = w.wave_number