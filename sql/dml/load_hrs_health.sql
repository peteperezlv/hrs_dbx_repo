-- ============================================================================
-- HRS Health ETL Load Script
-- ============================================================================
-- Section: Health
-- Description: RAND HRS Codebook – Health
-- Source: dev_catalog.brz_raw_hrs.randhrs1992_2022v1
-- Target: dev_catalog.slv_cdm_hrs.hrs_health
-- Load Type: Initial Load (Append Only)
-- ============================================================================

-- ============================================================================
-- Business Rules:
-- - Generate one target record per respondent
-- - Direct copy of all health columns
-- - Preserve NULL values
-- - Exclude records where respondent lookup fails
-- - Skip duplicate HHIDPN values already in target
-- ============================================================================

INSERT INTO dev_catalog.slv_cdm_hrs.hrs_health (
    hrs_survey_respondent_id,
    create_date,
    update_date,
    active,
    HHIDPN,
    RAGENDER,
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
    R16BMI
)
SELECT
    -- ========================================================================
    -- Foreign Key: Respondent Lookup
    -- Join source HHIDPN to hrs_survey_respondent to get respondent ID
    -- ========================================================================
    resp.hrs_survey_respondent_id,
    
    -- ========================================================================
    -- Audit Columns
    -- ========================================================================
    CURRENT_DATE() AS create_date,
    CURRENT_DATE() AS update_date,
    TRUE AS active,
    
    -- ========================================================================
    -- Direct Column Mapping: Health Attributes
    -- Preserve NULL values, no transformations
    -- Cast numeric columns to STRING to eliminate scientific notation
    -- ========================================================================
    CAST(CAST(src.HHIDPN AS BIGINT) AS STRING) AS HHIDPN,
    CAST(CAST(src.RAGENDER AS BIGINT) AS STRING) AS RAGENDER,
    CAST(CAST(src.R1BMI AS BIGINT) AS STRING) AS R1BMI,
    CAST(CAST(src.R2BMI AS BIGINT) AS STRING) AS R2BMI,
    CAST(CAST(src.R3BMI AS BIGINT) AS STRING) AS R3BMI,
    CAST(CAST(src.R4BMI AS BIGINT) AS STRING) AS R4BMI,
    CAST(CAST(src.R5BMI AS BIGINT) AS STRING) AS R5BMI,
    CAST(CAST(src.R6BMI AS BIGINT) AS STRING) AS R6BMI,
    CAST(CAST(src.R7BMI AS BIGINT) AS STRING) AS R7BMI,
    CAST(CAST(src.R8BMI AS BIGINT) AS STRING) AS R8BMI,
    CAST(CAST(src.R9BMI AS BIGINT) AS STRING) AS R9BMI,
    CAST(CAST(src.R10BMI AS BIGINT) AS STRING) AS R10BMI,
    CAST(CAST(src.R11BMI AS BIGINT) AS STRING) AS R11BMI,
    CAST(CAST(src.R12BMI AS BIGINT) AS STRING) AS R12BMI,
    CAST(CAST(src.R13BMI AS BIGINT) AS STRING) AS R13BMI,
    CAST(CAST(src.R14BMI AS BIGINT) AS STRING) AS R14BMI,
    CAST(CAST(src.R15BMI AS BIGINT) AS STRING) AS R15BMI,
    CAST(CAST(src.R16BMI AS BIGINT) AS STRING) AS R16BMI
FROM dev_catalog.brz_raw_hrs.randhrs1992_2022v1 src

-- ============================================================================
-- Respondent Lookup: INNER JOIN
-- Ensures every target record references a valid respondent
-- Excludes rows where respondent lookup fails
-- ============================================================================
INNER JOIN dev_catalog.slv_cdm_hrs.hrs_survey_respondent resp
    ON CAST(CAST(src.HHIDPN AS BIGINT) AS STRING) = resp.hhidpn

-- ============================================================================
-- Duplicate Handling: Skip Existing Records
-- Ensures restartability - do not insert duplicate HHIDPN values
-- ============================================================================
LEFT JOIN dev_catalog.slv_cdm_hrs.hrs_health tgt
    ON CAST(CAST(src.HHIDPN AS BIGINT) AS STRING) = tgt.HHIDPN
WHERE tgt.HHIDPN IS NULL;
