-- =====================================================================
-- HRS Silver CDM INSERT...SELECT – Health Section
-- Target Table: dev_catalog.slv_cdm_hrs.fact_health
-- Load Pattern: Insert Only (Section 4)
-- Grain: One row per respondent per survey wave (Section 9)
--
-- SOURCE:  dev_catalog.brz_raw_hrs.randhrs1992_2022v1
--
-- CONFIRMED:
--   - hub_respondent join column: HHIDPN
--   - dim_wave join column: wave_number (STRING)
--   - Section 12 'Wave' column = wave_number inserted into target
--
-- METHOD: Multi-value UNPIVOT (Databricks Runtime 12.2 LTS+)
--   All 10 wave-varying business columns are unpivoted in a single
--   UNPIVOT operation against source_base, producing wave_number and
--   all 10 metrics together in one pass. This is the most efficient
--   pattern available for this shape of source data:
--     - ONE scan of source_base (vs. 16 for a UNION ALL-per-wave
--       approach, or 10 for a single-value-UNPIVOT-per-column
--       approach that then has to be re-joined back together)
--     - ZERO joins required to reassemble the wide row per wave
--       (a single-value-UNPIVOT-per-column approach would otherwise
--       need a 9-way LEFT JOIN chain across the 10 unpivoted CTEs)
--
-- All 10 business columns in this section are wave-varying:
--   shlt, bmi, hibpe, diabe, cancre, lunge, hearte, stroke, psyche, arthre
-- (R{n}SHLT, R{n}BMI, R{n}HIBPE, R{n}DIABE, R{n}CANCRE, R{n}LUNGE,
--  R{n}HEARTE, R{n}STROKE, R{n}PSYCHE, R{n}ARTHRE for n = 1..16)
-- There are no wave-invariant business columns in this section.
--
-- wave_number is STRING on both fact_health and dim_wave, and the
-- multi-value UNPIVOT column aliases (`1`...`16`) naturally resolve
-- to STRING, so no explicit cast is required on the join key.
--
-- NOTE: Every respondent x wave (1-16) combination is inserted
-- unconditionally (INCLUDE NULLS). No NOT NULL filter is applied on
-- the business columns, since any one of them may legitimately be
-- NULL for a given respondent/wave without invalidating the row.
-- This is not a spec requirement -- rows are excluded only when they
-- fail the required respondent_id / wave_id FK resolution below.
-- =====================================================================
TRUNCATE TABLE dev_catalog.slv_cdm_hrs.fact_health;
--
INSERT INTO
INSERT INTO dev_catalog.slv_cdm_hrs.fact_health (
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
    ) WITH source_base AS (
        SELECT HHIDPN,
            R1SHLT,
            R2SHLT,
            R3SHLT,
            R4SHLT,
            R5SHLT,
            R6SHLT,
            R7SHLT,
            R8SHLT,
            R9SHLT,
            R10SHLT,
            R11SHLT,
            R12SHLT,
            R13SHLT,
            R14SHLT,
            R15SHLT,
            R16SHLT,
            R1BMI,
            R2BMI,
            R3BMI,
            R4BMI,
            R5BMI,
            R6BMI,
            R7BMI,
            R8BMI,
            R9BMI,
            R10BMI,
            R11BMI,
            R12BMI,
            R13BMI,
            R14BMI,
            R15BMI,
            R16BMI,
            R1HIBPE,
            R2HIBPE,
            R3HIBPE,
            R4HIBPE,
            R5HIBPE,
            R6HIBPE,
            R7HIBPE,
            R8HIBPE,
            R9HIBPE,
            R10HIBPE,
            R11HIBPE,
            R12HIBPE,
            R13HIBPE,
            R14HIBPE,
            R15HIBPE,
            R16HIBPE,
            R1DIABE,
            R2DIABE,
            R3DIABE,
            R4DIABE,
            R5DIABE,
            R6DIABE,
            R7DIABE,
            R8DIABE,
            R9DIABE,
            R10DIABE,
            R11DIABE,
            R12DIABE,
            R13DIABE,
            R14DIABE,
            R15DIABE,
            R16DIABE,
            R1CANCRE,
            R2CANCRE,
            R3CANCRE,
            R4CANCRE,
            R5CANCRE,
            R6CANCRE,
            R7CANCRE,
            R8CANCRE,
            R9CANCRE,
            R10CANCRE,
            R11CANCRE,
            R12CANCRE,
            R13CANCRE,
            R14CANCRE,
            R15CANCRE,
            R16CANCRE,
            R1LUNGE,
            R2LUNGE,
            R3LUNGE,
            R4LUNGE,
            R5LUNGE,
            R6LUNGE,
            R7LUNGE,
            R8LUNGE,
            R9LUNGE,
            R10LUNGE,
            R11LUNGE,
            R12LUNGE,
            R13LUNGE,
            R14LUNGE,
            R15LUNGE,
            R16LUNGE,
            R1HEARTE,
            R2HEARTE,
            R3HEARTE,
            R4HEARTE,
            R5HEARTE,
            R6HEARTE,
            R7HEARTE,
            R8HEARTE,
            R9HEARTE,
            R10HEARTE,
            R11HEARTE,
            R12HEARTE,
            R13HEARTE,
            R14HEARTE,
            R15HEARTE,
            R16HEARTE,
            R1STROKE,
            R2STROKE,
            R3STROKE,
            R4STROKE,
            R5STROKE,
            R6STROKE,
            R7STROKE,
            R8STROKE,
            R9STROKE,
            R10STROKE,
            R11STROKE,
            R12STROKE,
            R13STROKE,
            R14STROKE,
            R15STROKE,
            R16STROKE,
            R1PSYCHE,
            R2PSYCHE,
            R3PSYCHE,
            R4PSYCHE,
            R5PSYCHE,
            R6PSYCHE,
            R7PSYCHE,
            R8PSYCHE,
            R9PSYCHE,
            R10PSYCHE,
            R11PSYCHE,
            R12PSYCHE,
            R13PSYCHE,
            R14PSYCHE,
            R15PSYCHE,
            R16PSYCHE,
            R1ARTHRE,
            R2ARTHRE,
            R3ARTHRE,
            R4ARTHRE,
            R5ARTHRE,
            R6ARTHRE,
            R7ARTHRE,
            R8ARTHRE,
            R9ARTHRE,
            R10ARTHRE,
            R11ARTHRE,
            R12ARTHRE,
            R13ARTHRE,
            R14ARTHRE,
            R15ARTHRE,
            R16ARTHRE
        FROM dev_catalog.brz_raw_hrs.randhrs1992_2022v1
    ),
    wave_unpivoted_raw AS (
        SELECT HHIDPN,
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
            arthre
        FROM source_base UNPIVOT INCLUDE NULLS (
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
    ),
    wave_unpivoted AS (
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
        FROM wave_unpivoted_raw
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
    JOIN dev_catalog.slv_cdm_hrs.hub_respondent r ON wu.HHIDPN = r.HHIDPN
    JOIN dev_catalog.slv_cdm_hrs.dim_wave w ON wu.wave_number = w.wave_number