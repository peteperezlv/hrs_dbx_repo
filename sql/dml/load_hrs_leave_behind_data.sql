-- =====================================================================
-- HRS Silver CDM INSERT...SELECT – Leave-Behind: Big 5 Personality Traits
-- Target Table: dev_catalog.slv_cdm_hrs.hrs_leave_behind
-- Load Pattern: Insert Only (Section 4)
-- Grain: One row per respondent per survey wave, Waves 1-16 (Section 9)
--
-- SOURCE:  dev_catalog.brz_raw_hrs.randhrs1992_2022v1
--
-- CONFIRMED:
--   - hrs_respondent join column: HHIDPN
--   - hrs_wave join column: wave_number (STRING)
--   - Section 12 'Wave' column = wave_number inserted into target
--
-- IMPORTANT: This section's source columns (R8LBNEUR...R16LBNEUR, and the
-- equivalent for LBEXT/LBOPEN/LBAGR/LBCON5) only exist for Waves 8-16 --
-- there are NO R1LB*...R7LB* columns in the source table at all (not a
-- NULL-value gap, a column-existence gap). Because Section 9 requires the
-- full 1-16 wave universe for grain consistency across every Silver CDM
-- section, this DML is built as:
--   (a) a real multi-value UNPIVOT over Waves 8-16, where source columns
--       genuinely exist, and
--   (b) a synthetic NULL "scaffold" for Waves 1-7, cross-joining every
--       distinct HHIDPN against literal wave numbers 1-7 with all 5
--       business columns hardcoded NULL,
-- combined via UNION ALL.
--
-- Spouse-variant columns (S{w}LB{TRAIT}) exist in source but are 
-- explicitly out of scope for this table per Section 9's business
-- decision -- not selected into source_base.
--
-- wave_number is STRING on both hrs_leave_behind and hrs_wave. the
-- UNPIVOT column aliases (`8`...`16`) and the scaffold's literal wave
-- numbers are both cast to STRING to match on join without coercion.
--
-- NOTE: Every respondent x wave (1-16) combination is inserted
-- unconditionally. No NOT NULL filter is applied on the business columns.
-- Rows are excluded only when respondent_id / wave_id cannot be resolved
-- via the required FK joins below.
-- =====================================================================
TRUNCATE TABLE IDENTIFIER(
    CONCAT(
        :catalog_name,
        '.',
        :schema_prefix,
        '.fact_leave_behind'
    )
);
--
INSERT INTO IDENTIFIER(
        CONCAT(
            :catalog_name,
            '.',
            :schema_prefix,
            '.fact_leave_behind'
        )
    ) (
        respondent_id,
        wave_id,
        hhidpn,
        wave_number,
        lbneur,
        lbext,
        lbopen,
        lbagr,
        lbcon5,
        create_date,
        update_date,
        active
    ) WITH source_base AS (
        SELECT HHIDPN,
            R8LBNEUR,
            R9LBNEUR,
            R10LBNEUR,
            R11LBNEUR,
            R12LBNEUR,
            R13LBNEUR,
            R14LBNEUR,
            R15LBNEUR,
            R16LBNEUR,
            R8LBEXT,
            R9LBEXT,
            R10LBEXT,
            R11LBEXT,
            R12LBEXT,
            R13LBEXT,
            R14LBEXT,
            R15LBEXT,
            R16LBEXT,
            R8LBOPEN,
            R9LBOPEN,
            R10LBOPEN,
            R11LBOPEN,
            R12LBOPEN,
            R13LBOPEN,
            R14LBOPEN,
            R15LBOPEN,
            R16LBOPEN,
            R8LBAGR,
            R9LBAGR,
            R10LBAGR,
            R11LBAGR,
            R12LBAGR,
            R13LBAGR,
            R14LBAGR,
            R15LBAGR,
            R16LBAGR,
            R8LBCON5,
            R9LBCON5,
            R10LBCON5,
            R11LBCON5,
            R12LBCON5,
            R13LBCON5,
            R14LBCON5,
            R15LBCON5,
            R16LBCON5 -- NOTE: S{w}LB{TRAIT} spouse-variant columns intentionally
            -- NOT selected -- out of scope per Section 9
        FROM dev_catalog.brz_raw_hrs.randhrs1992_2022v1
    ),
    -- =====================================================================
    -- Branch (a): Waves 8-16 -- real UNPIVOT against actual source columns
    -- =====================================================================
    wave_unpivoted_raw AS (
        SELECT HHIDPN,
            wave_number,
            lbneur,
            lbext,
            lbopen,
            lbagr,
            lbcon5
        FROM source_base UNPIVOT INCLUDE NULLS (
                (lbneur, lbext, lbopen, lbagr, lbcon5) FOR wave_number IN (
                    (
                        R8LBNEUR,
                        R8LBEXT,
                        R8LBOPEN,
                        R8LBAGR,
                        R8LBCON5
                    ) AS `8`,
                    (
                        R9LBNEUR,
                        R9LBEXT,
                        R9LBOPEN,
                        R9LBAGR,
                        R9LBCON5
                    ) AS `9`,
                    (
                        R10LBNEUR,
                        R10LBEXT,
                        R10LBOPEN,
                        R10LBAGR,
                        R10LBCON5
                    ) AS `10`,
                    (
                        R11LBNEUR,
                        R11LBEXT,
                        R11LBOPEN,
                        R11LBAGR,
                        R11LBCON5
                    ) AS `11`,
                    (
                        R12LBNEUR,
                        R12LBEXT,
                        R12LBOPEN,
                        R12LBAGR,
                        R12LBCON5
                    ) AS `12`,
                    (
                        R13LBNEUR,
                        R13LBEXT,
                        R13LBOPEN,
                        R13LBAGR,
                        R13LBCON5
                    ) AS `13`,
                    (
                        R14LBNEUR,
                        R14LBEXT,
                        R14LBOPEN,
                        R14LBAGR,
                        R14LBCON5
                    ) AS `14`,
                    (
                        R15LBNEUR,
                        R15LBEXT,
                        R15LBOPEN,
                        R15LBAGR,
                        R15LBCON5
                    ) AS `15`,
                    (
                        R16LBNEUR,
                        R16LBEXT,
                        R16LBOPEN,
                        R16LBAGR,
                        R16LBCON5
                    ) AS `16`
                )
            )
    ),
    wave_8_16 AS (
        SELECT HHIDPN,
            wave_number,
            TRY_CAST(lbneur AS DECIMAL(10, 2)) AS lbneur,
            TRY_CAST(lbext AS DECIMAL(10, 2)) AS lbext,
            TRY_CAST(lbopen AS DECIMAL(10, 2)) AS lbopen,
            TRY_CAST(lbagr AS DECIMAL(10, 2)) AS lbagr,
            TRY_CAST(lbcon5 AS DECIMAL(10, 2)) AS lbcon5
        FROM wave_unpivoted_raw
    ),
    -- =====================================================================
    -- Branch (b): Waves 1-7 -- synthetic NULL scaffold (no source columns
    -- exist for these waves. this is a column-existence gap, not a null-
    -- value gap, so UNPIVOT cannot reference them at all)
    -- =====================================================================
    distinct_respondents AS (
        SELECT DISTINCT HHIDPN
        FROM source_base
    ),
    wave_1_7_scaffold AS (
        SELECT wave_number
        FROM
        VALUES ('1'),
            ('2'),
            ('3'),
            ('4'),
            ('5'),
            ('6'),
            ('7') AS w(wave_number)
    ),
    wave_1_7 AS (
        SELECT dr.HHIDPN,
            s.wave_number,
            CAST(NULL AS DECIMAL(10, 2)) AS lbneur,
            CAST(NULL AS DECIMAL(10, 2)) AS lbext,
            CAST(NULL AS DECIMAL(10, 2)) AS lbopen,
            CAST(NULL AS DECIMAL(10, 2)) AS lbagr,
            CAST(NULL AS DECIMAL(10, 2)) AS lbcon5
        FROM distinct_respondents dr
            CROSS JOIN wave_1_7_scaffold s
    ),
    -- =====================================================================
    -- Combine both branches into the full Wave 1-16 universe
    -- =====================================================================
    wave_unpivoted AS (
        SELECT *
        FROM wave_1_7
        UNION ALL
        SELECT *
        FROM wave_8_16
    )
SELECT r.respondent_id,
    w.wave_id,
    wu.HHIDPN AS hhidpn,
    wu.wave_number,
    wu.lbneur,
    wu.lbext,
    wu.lbopen,
    wu.lbagr,
    wu.lbcon5,
    CURRENT_DATE() AS create_date,
    CURRENT_DATE() AS update_date,
    TRUE AS active
FROM wave_unpivoted wu
    JOIN dev_catalog.slv_cdm_hrs.hub_respondent r ON wu.HHIDPN = r.HHIDPN
    JOIN dev_catalog.slv_cdm_hrs.dim_wave w ON wu.wave_number = w.wave_number;