-- =====================================================================
-- HRS Silver CDM INSERT...SELECT – Health Section
-- Target Table: dev_catalog.slv_cdm_hrs.hrs_health
-- Load Pattern: Insert Only (Section 4)
-- Grain: One row per respondent per survey wave (Section 9)
--
-- SOURCE:  dev_catalog.brz_raw_hrs.randhrs1992_2022v1
--
-- CONFIRMED:
--   - hrs_respondent join column: HHIDPN
--   - hrs_wave join column: wave_number (STRING)
--   - Section 12 'Wave' column = wave_number inserted into target
--
-- ASSUMPTION (carried forward from Demographics pattern):
--   Source is a wide table, one row per respondent (HHIDPN).
--   All 10 business columns in this section are wave-varying:
--     shlt, bmi, hibpe, diabe, cancre, lunge, hearte, stroke, psyche, arthre
--   (R{n}SHLT, R{n}BMI, R{n}HIBPE, R{n}DIABE, R{n}CANCRE, R{n}LUNGE,
--    R{n}HEARTE, R{n}STROKE, R{n}PSYCHE, R{n}ARTHRE for n = 1..16)
--   There are no wave-invariant business columns in this section, so
--   there is no separate "source_base" CTE like Demographics used —
--   everything is produced directly by the unpivot.
--
-- wave_number is STRING on both hrs_health and hrs_wave (per spec
-- change), so wave numbers are cast to STRING in the unpivot to
-- match on join without implicit coercion.
--
-- NOTE: Every respondent x wave (1-16) combination is inserted
-- unconditionally. No NOT NULL filter is applied on the business
-- columns, since any one of them (shlt, bmi, hibpe, diabe, cancre,
-- lunge, hearte, stroke, psyche, arthre) may legitimately be NULL
-- for a given respondent/wave without invalidating the row. This
-- is not a spec requirement -- rows are excluded only when they
-- fail the required respondent_id / wave_id FK resolution below.
--
-- Also, not that the UNPIVOT create the wave_number and the metric like shlt.
-- They are not derived from the source_base.
--
-- The UNPIVOT Syntax
-- UNPIVOT (
--   shlt FOR wave_number IN (  -- creates TWO new columns
--        R1SHLT `1`,            -- R1SHLT's value goes to shlt, '1' goes to wave_number
--        R2SHLT `2`,            -- R2SHLT's value goes to shlt, '2' goes to wave_number
--        ...
--    )
--)
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
    wave_shlt_unpivot AS (
        SELECT CAST(HHIDPN AS BIGINT) AS HHIDPN,
            wave_number,
            shlt
        FROM source_base UNPIVOT INCLUDE NULLS (
                shlt FOR wave_number IN (
                    R1SHLT `1`,
                    R2SHLT `2`,
                    R3SHLT `3`,
                    R4SHLT `4`,
                    R5SHLT `5`,
                    R6SHLT `6`,
                    R7SHLT `7`,
                    R8SHLT `8`,
                    R9SHLT `9`,
                    R10SHLT `10`,
                    R11SHLT `11`,
                    R12SHLT `12`,
                    R13SHLT `13`,
                    R14SHLT `14`,
                    R15SHLT `15`,
                    R16SHLT `16`
                )
            )
    ),
    wave_bmi_unpivot AS (
        SELECT HHIDPN,
            wave_number,
            bmi
        FROM source_base UNPIVOT INCLUDE NULLS (
                bmi FOR wave_number IN (
                    R1BMI `1`,
                    R2BMI `2`,
                    R3BMI `3`,
                    R4BMI `4`,
                    R5BMI `5`,
                    R6BMI `6`,
                    R7BMI `7`,
                    R8BMI `8`,
                    R9BMI `9`,
                    R10BMI `10`,
                    R11BMI `11`,
                    R12BMI `12`,
                    R13BMI `13`,
                    R14BMI `14`,
                    R15BMI `15`,
                    R16BMI `16`
                )
            )
    ),
    wave_hibpe_unpivot AS (
        SELECT HHIDPN,
            wave_number,
            hibpe
        FROM source_base UNPIVOT INCLUDE NULLS (
                hibpe FOR wave_number IN (
                    R1HIBPE `1`,
                    R2HIBPE `2`,
                    R3HIBPE `3`,
                    R4HIBPE `4`,
                    R5HIBPE `5`,
                    R6HIBPE `6`,
                    R7HIBPE `7`,
                    R8HIBPE `8`,
                    R9HIBPE `9`,
                    R10HIBPE `10`,
                    R11HIBPE `11`,
                    R12HIBPE `12`,
                    R13HIBPE `13`,
                    R14HIBPE `14`,
                    R15HIBPE `15`,
                    R16HIBPE `16`
                )
            )
    ),
    wave_diabe_unpivot AS (
        SELECT HHIDPN,
            wave_number,
            diabe
        FROM source_base UNPIVOT INCLUDE NULLS (
                diabe FOR wave_number IN (
                    R1DIABE `1`,
                    R2DIABE `2`,
                    R3DIABE `3`,
                    R4DIABE `4`,
                    R5DIABE `5`,
                    R6DIABE `6`,
                    R7DIABE `7`,
                    R8DIABE `8`,
                    R9DIABE `9`,
                    R10DIABE `10`,
                    R11DIABE `11`,
                    R12DIABE `12`,
                    R13DIABE `13`,
                    R14DIABE `14`,
                    R15DIABE `15`,
                    R16DIABE `16`
                )
            )
    ),
    wave_cancre_unpivot AS (
        SELECT HHIDPN,
            wave_number,
            cancre
        FROM source_base UNPIVOT INCLUDE NULLS (
                cancre FOR wave_number IN (
                    R1CANCRE `1`,
                    R2CANCRE `2`,
                    R3CANCRE `3`,
                    R4CANCRE `4`,
                    R5CANCRE `5`,
                    R6CANCRE `6`,
                    R7CANCRE `7`,
                    R8CANCRE `8`,
                    R9CANCRE `9`,
                    R10CANCRE `10`,
                    R11CANCRE `11`,
                    R12CANCRE `12`,
                    R13CANCRE `13`,
                    R14CANCRE `14`,
                    R15CANCRE `15`,
                    R16CANCRE `16`
                )
            )
    ),
    wave_lunge_unpivot AS (
        SELECT HHIDPN,
            wave_number,
            lunge
        FROM source_base UNPIVOT INCLUDE NULLS (
                lunge FOR wave_number IN (
                    R1LUNGE `1`,
                    R2LUNGE `2`,
                    R3LUNGE `3`,
                    R4LUNGE `4`,
                    R5LUNGE `5`,
                    R6LUNGE `6`,
                    R7LUNGE `7`,
                    R8LUNGE `8`,
                    R9LUNGE `9`,
                    R10LUNGE `10`,
                    R11LUNGE `11`,
                    R12LUNGE `12`,
                    R13LUNGE `13`,
                    R14LUNGE `14`,
                    R15LUNGE `15`,
                    R16LUNGE `16`
                )
            )
    ),
    wave_hearte_unpivot AS (
        SELECT HHIDPN,
            wave_number,
            hearte
        FROM source_base UNPIVOT INCLUDE NULLS (
                hearte FOR wave_number IN (
                    R1HEARTE `1`,
                    R2HEARTE `2`,
                    R3HEARTE `3`,
                    R4HEARTE `4`,
                    R5HEARTE `5`,
                    R6HEARTE `6`,
                    R7HEARTE `7`,
                    R8HEARTE `8`,
                    R9HEARTE `9`,
                    R10HEARTE `10`,
                    R11HEARTE `11`,
                    R12HEARTE `12`,
                    R13HEARTE `13`,
                    R14HEARTE `14`,
                    R15HEARTE `15`,
                    R16HEARTE `16`
                )
            )
    ),
    wave_stroke_unpivot AS (
        SELECT HHIDPN,
            wave_number,
            stroke
        FROM source_base UNPIVOT INCLUDE NULLS (
                stroke FOR wave_number IN (
                    R1STROKE `1`,
                    R2STROKE `2`,
                    R3STROKE `3`,
                    R4STROKE `4`,
                    R5STROKE `5`,
                    R6STROKE `6`,
                    R7STROKE `7`,
                    R8STROKE `8`,
                    R9STROKE `9`,
                    R10STROKE `10`,
                    R11STROKE `11`,
                    R12STROKE `12`,
                    R13STROKE `13`,
                    R14STROKE `14`,
                    R15STROKE `15`,
                    R16STROKE `16`
                )
            )
    ),
    wave_psyche_unpivot AS (
        SELECT HHIDPN,
            wave_number,
            psyche
        FROM source_base UNPIVOT INCLUDE NULLS (
                psyche FOR wave_number IN (
                    R1PSYCHE `1`,
                    R2PSYCHE `2`,
                    R3PSYCHE `3`,
                    R4PSYCHE `4`,
                    R5PSYCHE `5`,
                    R6PSYCHE `6`,
                    R7PSYCHE `7`,
                    R8PSYCHE `8`,
                    R9PSYCHE `9`,
                    R10PSYCHE `10`,
                    R11PSYCHE `11`,
                    R12PSYCHE `12`,
                    R13PSYCHE `13`,
                    R14PSYCHE `14`,
                    R15PSYCHE `15`,
                    R16PSYCHE `16`
                )
            )
    ),
    wave_arthre_unpivot AS (
        SELECT HHIDPN,
            wave_number,
            arthre
        FROM source_base UNPIVOT INCLUDE NULLS (
                arthre FOR wave_number IN (
                    R1ARTHRE `1`,
                    R2ARTHRE `2`,
                    R3ARTHRE `3`,
                    R4ARTHRE `4`,
                    R5ARTHRE `5`,
                    R6ARTHRE `6`,
                    R7ARTHRE `7`,
                    R8ARTHRE `8`,
                    R9ARTHRE `9`,
                    R10ARTHRE `10`,
                    R11ARTHRE `11`,
                    R12ARTHRE `12`,
                    R13ARTHRE `13`,
                    R14ARTHRE `14`,
                    R15ARTHRE `15`,
                    R16ARTHRE `16`
                )
            )
    ),
    wave_unpivoted AS (
        SELECT s.HHIDPN,
            s.wave_number,
            TRY_CAST(s.shlt AS TINYINT) AS shlt,
            TRY_CAST(b.bmi AS DECIMAL(10, 2)) AS bmi,
            TRY_CAST(h.hibpe AS TINYINT) AS hibpe,
            TRY_CAST(d.diabe AS TINYINT) AS diabe,
            TRY_CAST(c.cancre AS TINYINT) AS cancre,
            TRY_CAST(l.lunge AS TINYINT) AS lunge,
            TRY_CAST(he.hearte AS TINYINT) AS hearte,
            TRY_CAST(st.stroke AS TINYINT) AS stroke,
            TRY_CAST(p.psyche AS TINYINT) AS psyche,
            TRY_CAST(a.arthre AS TINYINT) AS arthre
        FROM wave_shlt_unpivot s
            LEFT JOIN wave_bmi_unpivot b ON s.HHIDPN = b.HHIDPN
            AND s.wave_number = b.wave_number
            LEFT JOIN wave_hibpe_unpivot h ON s.HHIDPN = h.HHIDPN
            AND s.wave_number = h.wave_number
            LEFT JOIN wave_diabe_unpivot d ON s.HHIDPN = d.HHIDPN
            AND s.wave_number = d.wave_number
            LEFT JOIN wave_cancre_unpivot c ON s.HHIDPN = c.HHIDPN
            AND s.wave_number = c.wave_number
            LEFT JOIN wave_lunge_unpivot l ON s.HHIDPN = l.HHIDPN
            AND s.wave_number = l.wave_number
            LEFT JOIN wave_hearte_unpivot he ON s.HHIDPN = he.HHIDPN
            AND s.wave_number = he.wave_number
            LEFT JOIN wave_stroke_unpivot st ON s.HHIDPN = st.HHIDPN
            AND s.wave_number = st.wave_number
            LEFT JOIN wave_psyche_unpivot p ON s.HHIDPN = p.HHIDPN
            AND s.wave_number = p.wave_number
            LEFT JOIN wave_arthre_unpivot a ON s.HHIDPN = a.HHIDPN
            AND s.wave_number = a.wave_number
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