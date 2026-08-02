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
INSERT INTO dev_catalog.slv_cdm_hrs.hrs_health (
        respondent_id,
        wave_id,
        hhidpn,
        wave_number,
        shlt,
        bmi,
        hibpe,
        diabe,
        cancre,
        lunge,
        hearte,
        stroke,
        psyche,
        arthre,
        create_date,
        update_date,
        active
    ) WITH wave_unpivoted AS (
        SELECT HHIDPN,
            wave_number,
            TRY_CAST(shlt AS TINYINT) AS shlt,
            TRY_CAST(bmi AS DECIMAL(10, 2)) AS bmi,
            TRY_CAST(hibpe AS TINYINT) AS hibpe,
            TRY_CAST(diabe AS TINYINT) AS diabe,
            TRY_CAST(cancre AS TINYINT) AS cancre,
            TRY_CAST(lunge AS TINYINT) AS lunge,
            TRY_CAST(hearte AS TINYINT) AS hearte,
            TRY_CAST(stroke AS TINYINT) AS stroke,
            TRY_CAST(psyche AS TINYINT) AS psyche,
            TRY_CAST(arthre AS TINYINT) AS arthre
        FROM dev_catalog.brz_raw_hrs.randhrs1992_2022v1 UNPIVOT (
                (
                    shlt,
                    bmi,
                    hibpe,
                    diabe,
                    cancre,
                    lunge,
                    hearte,
                    stroke,
                    psyche,
                    arthre
                ) FOR wave_number IN (
                    (
                        R1SHLT,
                        R1BMI,
                        R1HIBPE,
                        R1DIABE,
                        R1CANCRE,
                        R1LUNGE,
                        R1HEARTE,
                        R1STROKE,
                        R1PSYCHE,
                        R1ARTHRE
                    ) AS `1`,
                    (
                        R2SHLT,
                        R2BMI,
                        R2HIBPE,
                        R2DIABE,
                        R2CANCRE,
                        R2LUNGE,
                        R2HEARTE,
                        R2STROKE,
                        R2PSYCHE,
                        R2ARTHRE
                    ) AS `2`,
                    (
                        R3SHLT,
                        R3BMI,
                        R3HIBPE,
                        R3DIABE,
                        R3CANCRE,
                        R3LUNGE,
                        R3HEARTE,
                        R3STROKE,
                        R3PSYCHE,
                        R3ARTHRE
                    ) AS `3`,
                    (
                        R4SHLT,
                        R4BMI,
                        R4HIBPE,
                        R4DIABE,
                        R4CANCRE,
                        R4LUNGE,
                        R4HEARTE,
                        R4STROKE,
                        R4PSYCHE,
                        R4ARTHRE
                    ) AS `4`,
                    (
                        R5SHLT,
                        R5BMI,
                        R5HIBPE,
                        R5DIABE,
                        R5CANCRE,
                        R5LUNGE,
                        R5HEARTE,
                        R5STROKE,
                        R5PSYCHE,
                        R5ARTHRE
                    ) AS `5`,
                    (
                        R6SHLT,
                        R6BMI,
                        R6HIBPE,
                        R6DIABE,
                        R6CANCRE,
                        R6LUNGE,
                        R6HEARTE,
                        R6STROKE,
                        R6PSYCHE,
                        R6ARTHRE
                    ) AS `6`,
                    (
                        R7SHLT,
                        R7BMI,
                        R7HIBPE,
                        R7DIABE,
                        R7CANCRE,
                        R7LUNGE,
                        R7HEARTE,
                        R7STROKE,
                        R7PSYCHE,
                        R7ARTHRE
                    ) AS `7`,
                    (
                        R8SHLT,
                        R8BMI,
                        R8HIBPE,
                        R8DIABE,
                        R8CANCRE,
                        R8LUNGE,
                        R8HEARTE,
                        R8STROKE,
                        R8PSYCHE,
                        R8ARTHRE
                    ) AS `8`,
                    (
                        R9SHLT,
                        R9BMI,
                        R9HIBPE,
                        R9DIABE,
                        R9CANCRE,
                        R9LUNGE,
                        R9HEARTE,
                        R9STROKE,
                        R9PSYCHE,
                        R9ARTHRE
                    ) AS `9`,
                    (
                        R10SHLT,
                        R10BMI,
                        R10HIBPE,
                        R10DIABE,
                        R10CANCRE,
                        R10LUNGE,
                        R10HEARTE,
                        R10STROKE,
                        R10PSYCHE,
                        R10ARTHRE
                    ) AS `10`,
                    (
                        R11SHLT,
                        R11BMI,
                        R11HIBPE,
                        R11DIABE,
                        R11CANCRE,
                        R11LUNGE,
                        R11HEARTE,
                        R11STROKE,
                        R11PSYCHE,
                        R11ARTHRE
                    ) AS `11`,
                    (
                        R12SHLT,
                        R12BMI,
                        R12HIBPE,
                        R12DIABE,
                        R12CANCRE,
                        R12LUNGE,
                        R12HEARTE,
                        R12STROKE,
                        R12PSYCHE,
                        R12ARTHRE
                    ) AS `12`,
                    (
                        R13SHLT,
                        R13BMI,
                        R13HIBPE,
                        R13DIABE,
                        R13CANCRE,
                        R13LUNGE,
                        R13HEARTE,
                        R13STROKE,
                        R13PSYCHE,
                        R13ARTHRE
                    ) AS `13`,
                    (
                        R14SHLT,
                        R14BMI,
                        R14HIBPE,
                        R14DIABE,
                        R14CANCRE,
                        R14LUNGE,
                        R14HEARTE,
                        R14STROKE,
                        R14PSYCHE,
                        R14ARTHRE
                    ) AS `14`,
                    (
                        R15SHLT,
                        R15BMI,
                        R15HIBPE,
                        R15DIABE,
                        R15CANCRE,
                        R15LUNGE,
                        R15HEARTE,
                        R15STROKE,
                        R15PSYCHE,
                        R15ARTHRE
                    ) AS `15`,
                    (
                        R16SHLT,
                        R16BMI,
                        R16HIBPE,
                        R16DIABE,
                        R16CANCRE,
                        R16LUNGE,
                        R16HEARTE,
                        R16STROKE,
                        R16PSYCHE,
                        R16ARTHRE
                    ) AS `16`
                )
            )
    )
SELECT r.respondent_id,
    w.wave_id,
    wu.HHIDPN AS hhidpn,
    wu.wave_number,
    wu.shlt,
    wu.bmi,
    wu.hibpe,
    wu.diabe,
    wu.cancre,
    wu.lunge,
    wu.hearte,
    wu.stroke,
    wu.psyche,
    wu.arthre,
    CURRENT_DATE() AS create_date,
    CURRENT_DATE() AS update_date,
    TRUE AS active
FROM wave_unpivoted wu
    JOIN dev_catalog.slv_cdm_hrs.hrs_respondent r ON wu.HHIDPN = r.HHIDPN
    JOIN dev_catalog.slv_cdm_hrs.hrs_wave w ON wu.wave_number = w.wave_number;