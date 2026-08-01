-- =====================================================================
-- HRS Silver CDM Validation Script – Demographics Section
-- Target Table: dev_catalog.slv_cdm_hrs.hrs_demographics
-- Purpose: Unit test suite for DDL structure + post-load data quality
-- Maps to: Section 15 (Validation Requirements) of the Functional Spec
--
-- Usage: Run each numbered block independently, or run the entire
--        script and inspect the final UNION ALL summary result set.
--        Every check returns STATUS = 'PASS' or 'FAIL'.
-- =====================================================================
-- =====================================================================
-- SECTION A: STRUCTURAL VALIDATIONS (run DDL, then these)
-- =====================================================================
--
-- A1. Table Exists
SELECT 'A1_TABLE_EXISTS' AS test_name,
    CASE
        WHEN COUNT(*) = 1 THEN 'PASS'
        ELSE 'FAIL'
    END AS status,
    CONCAT('Row count found: ', COUNT(*)) AS details
FROM dev_catalog.information_schema.tables
WHERE table_catalog = 'dev_catalog'
    AND table_schema = 'slv_cdm_hrs'
    AND table_name = 'hrs_demographics';
-- A2. Correct Schema (catalog.schema.table resolves)
SELECT 'A2_CORRECT_SCHEMA' AS test_name,
    CASE
        WHEN COUNT(*) = 1 THEN 'PASS'
        ELSE 'FAIL'
    END AS status,
    CONCAT('table_schema = ', MAX(table_schema)) AS details
FROM dev_catalog.information_schema.tables
WHERE table_catalog = 'dev_catalog'
    AND table_schema = 'slv_cdm_hrs'
    AND table_name = 'hrs_demographics';
-- A3. Delta Format
SELECT 'A3_DELTA_FORMAT' AS test_name,
    CASE
        WHEN format = 'delta' THEN 'PASS'
        ELSE 'FAIL'
    END AS status,
    CONCAT('format = ', format) AS details
FROM (
        DESCRIBE DETAIL dev_catalog.slv_cdm_hrs.hrs_demographics
    );
-- A4. Managed Table
SELECT 'A4_MANAGED_TABLE' AS test_name,
    CASE
        WHEN table_type = 'MANAGED' THEN 'PASS'
        ELSE 'FAIL'
    END AS status,
    CONCAT('table_type = ', table_type) AS details
FROM (
        DESCRIBE DETAIL dev_catalog.slv_cdm_hrs.hrs_demographics
    );
-- A5. Identity Column Exists (hrs_demographics_id)
SELECT 'A5_IDENTITY_COLUMN_EXISTS' AS test_name,
    CASE
        WHEN COUNT(*) = 1 THEN 'PASS'
        ELSE 'FAIL'
    END AS status,
    CONCAT('Columns found: ', COUNT(*)) AS details
FROM dev_catalog.information_schema.columns
WHERE table_catalog = 'dev_catalog'
    AND table_schema = 'slv_cdm_hrs'
    AND table_name = 'hrs_demographics'
    AND column_name = 'hrs_demographics_id';
-- A6. Respondent FK Exists (constraint level)
SELECT 'A6_RESPONDENT_FK_EXISTS' AS test_name,
    CASE
        WHEN COUNT(*) = 1 THEN 'PASS'
        ELSE 'FAIL'
    END AS status,
    CONCAT('Constraints found: ', COUNT(*)) AS details
FROM dev_catalog.information_schema.table_constraints
WHERE table_catalog = 'dev_catalog'
    AND table_schema = 'slv_cdm_hrs'
    AND table_name = 'hrs_demographics'
    AND constraint_name = 'fk_hrs_demographics_respondent'
    AND constraint_type = 'FOREIGN KEY';
-- A7. Wave FK Exists (constraint level)
SELECT 'A7_WAVE_FK_EXISTS' AS test_name,
    CASE
        WHEN COUNT(*) = 1 THEN 'PASS'
        ELSE 'FAIL'
    END AS status,
    CONCAT('Constraints found: ', COUNT(*)) AS details
FROM dev_catalog.information_schema.table_constraints
WHERE table_catalog = 'dev_catalog'
    AND table_schema = 'slv_cdm_hrs'
    AND table_name = 'hrs_demographics'
    AND constraint_name = 'fk_hrs_demographics_wave'
    AND constraint_type = 'FOREIGN KEY';
-- A8. Audit Columns Exist (create_date, update_date, active)
SELECT 'A8_AUDIT_COLUMNS_EXIST' AS test_name,
    CASE
        WHEN COUNT(*) = 3 THEN 'PASS'
        ELSE 'FAIL'
    END AS status,
    CONCAT('Audit columns found: ', COUNT(*), ' of 3') AS details
FROM dev_catalog.information_schema.columns
WHERE table_catalog = 'dev_catalog'
    AND table_schema = 'slv_cdm_hrs'
    AND table_name = 'hrs_demographics'
    AND column_name IN ('create_date', 'update_date', 'active');
-- A9. Primary Key Constraint Exists
SELECT 'A9_PRIMARY_KEY_EXISTS' AS test_name,
    CASE
        WHEN COUNT(*) = 1 THEN 'PASS'
        ELSE 'FAIL'
    END AS status,
    CONCAT('Constraints found: ', COUNT(*)) AS details
FROM dev_catalog.information_schema.table_constraints
WHERE table_catalog = 'dev_catalog'
    AND table_schema = 'slv_cdm_hrs'
    AND table_name = 'hrs_demographics'
    AND constraint_name = 'pk_hrs_demographics'
    AND constraint_type = 'PRIMARY KEY';
-- A10. Business Key Unique Constraint Exists
SELECT 'A10_UNIQUE_BUSINESS_KEY_EXISTS' AS test_name,
    CASE
        WHEN COUNT(*) = 1 THEN 'PASS'
        ELSE 'FAIL'
    END AS status,
    CONCAT('Constraints found: ', COUNT(*)) AS details
FROM dev_catalog.information_schema.table_constraints
WHERE table_catalog = 'dev_catalog'
    AND table_schema = 'slv_cdm_hrs'
    AND table_name = 'hrs_demographics'
    AND constraint_name = 'uq_hrs_demographics_respondent_wave'
    AND constraint_type = 'UNIQUE';
-- =====================================================================
-- SECTION B: DATA QUALITY VALIDATIONS (run AFTER INSERT...SELECT load)
-- =====================================================================
-- B1. Table Is Not Empty (sanity check the load produced rows)
SELECT 'B1_ROWS_LOADED' AS test_name,
    CASE
        WHEN COUNT(*) > 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status,
    CONCAT('Row count = ', COUNT(*)) AS details
FROM dev_catalog.slv_cdm_hrs.hrs_demographics;
-- B2. respondent_id Exists in hrs_respondent (referential integrity)
SELECT 'B2_RESPONDENT_ID_REFERENTIAL_INTEGRITY' AS test_name,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status,
    CONCAT('Orphaned rows found: ', COUNT(*)) AS details
FROM dev_catalog.slv_cdm_hrs.hrs_demographics d
    LEFT JOIN dev_catalog.slv_cdm_hrs.hrs_respondent r ON d.respondent_id = r.respondent_id
WHERE r.respondent_id IS NULL;
-- B3. wave_id Exists in hrs_wave (referential integrity)
SELECT 'B3_WAVE_ID_REFERENTIAL_INTEGRITY' AS test_name,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status,
    CONCAT('Orphaned rows found: ', COUNT(*)) AS details
FROM dev_catalog.slv_cdm_hrs.hrs_demographics d
    LEFT JOIN dev_catalog.slv_cdm_hrs.hrs_wave w ON d.wave_id = w.wave_id
WHERE w.wave_id IS NULL;
-- B4. No Duplicate respondent_id + wave_id
SELECT 'B4_NO_DUPLICATE_RESPONDENT_WAVE' AS test_name,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status,
    CONCAT('Duplicate combinations found: ', COUNT(*)) AS details
FROM (
        SELECT respondent_id,
            wave_id
        FROM dev_catalog.slv_cdm_hrs.hrs_demographics
        GROUP BY respondent_id,
            wave_id
        HAVING COUNT(*) > 1
    );
-- B5. No NULLs in Required (NOT NULL) Columns
SELECT 'B5_NOT_NULL_COLUMNS_ENFORCED' AS test_name,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status,
    CONCAT('Rows with NULL required fields: ', COUNT(*)) AS details
FROM dev_catalog.slv_cdm_hrs.hrs_demographics
WHERE respondent_id IS NULL
    OR wave_id IS NULL
    OR wave_number IS NULL
    OR create_date IS NULL
    OR update_date IS NULL
    OR active IS NULL;
-- B6. wave_number Is In Expected Range (1-16 per RAND HRS)
SELECT 'B6_WAVE_NUMBER_IN_RANGE' AS test_name,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status,
    CONCAT('Out-of-range rows found: ', COUNT(*)) AS details
FROM dev_catalog.slv_cdm_hrs.hrs_demographics
WHERE wave_number NOT BETWEEN 1 AND 16;
-- B7. agey_e Within Plausible Human Age Bounds (data sanity, not a hard constraint)
SELECT 'B7_AGEY_E_PLAUSIBLE_RANGE' AS test_name,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status,
    CONCAT('Implausible age rows found: ', COUNT(*)) AS details
FROM dev_catalog.slv_cdm_hrs.hrs_demographics
WHERE agey_e IS NOT NULL
    AND (
        agey_e < 0
        OR agey_e > 120
    );
-- B8. hhidpn Consistency (respondent_id and hhidpn should correspond 1:1
--     across all wave rows for the same respondent)
SELECT 'B8_HHIDPN_CONSISTENT_PER_RESPONDENT' AS test_name,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status,
    CONCAT(
        'respondent_id values with >1 distinct hhidpn: ',
        COUNT(*)
    ) AS details
FROM (
        SELECT respondent_id
        FROM dev_catalog.slv_cdm_hrs.hrs_demographics
        GROUP BY respondent_id
        HAVING COUNT(DISTINCT hhidpn) > 1
    );
-- B9. active Flag Populated as TRUE on Initial Load
--     (Insert-Only pattern per Section 4 — no soft-deletes expected yet)
SELECT 'B9_ACTIVE_FLAG_TRUE_ON_LOAD' AS test_name,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status,
    CONCAT('Rows with active = FALSE: ', COUNT(*)) AS details
FROM dev_catalog.slv_cdm_hrs.hrs_demographics
WHERE active = FALSE;
-- =====================================================================
-- SECTION C: CONSOLIDATED TEST SUMMARY
-- Combine every check above into a single pass/fail result set.
-- Run this block last for a one-glance pass/fail report.
-- =====================================================================
SELECT *
FROM (
        SELECT 'A1_TABLE_EXISTS' AS test_name,
            CASE
                WHEN COUNT(*) = 1 THEN 'PASS'
                ELSE 'FAIL'
            END AS status
        FROM dev_catalog.information_schema.tables
        WHERE table_catalog = 'dev_catalog'
            AND table_schema = 'slv_cdm_hrs'
            AND table_name = 'hrs_demographics'
        UNION ALL
        SELECT 'A3_DELTA_FORMAT',
            CASE
                WHEN format = 'delta' THEN 'PASS'
                ELSE 'FAIL'
            END
        FROM (
                DESCRIBE DETAIL dev_catalog.slv_cdm_hrs.hrs_demographics
            )
        UNION ALL
        SELECT 'A4_MANAGED_TABLE',
            CASE
                WHEN table_type = 'MANAGED' THEN 'PASS'
                ELSE 'FAIL'
            END
        FROM (
                DESCRIBE DETAIL dev_catalog.slv_cdm_hrs.hrs_demographics
            )
        UNION ALL
        SELECT 'A5_IDENTITY_COLUMN_EXISTS',
            CASE
                WHEN COUNT(*) = 1 THEN 'PASS'
                ELSE 'FAIL'
            END
        FROM dev_catalog.information_schema.columns
        WHERE table_catalog = 'dev_catalog'
            AND table_schema = 'slv_cdm_hrs'
            AND table_name = 'hrs_demographics'
            AND column_name = 'hrs_demographics_id'
        UNION ALL
        SELECT 'A6_RESPONDENT_FK_EXISTS',
            CASE
                WHEN COUNT(*) = 1 THEN 'PASS'
                ELSE 'FAIL'
            END
        FROM dev_catalog.information_schema.table_constraints
        WHERE table_catalog = 'dev_catalog'
            AND table_schema = 'slv_cdm_hrs'
            AND table_name = 'hrs_demographics'
            AND constraint_name = 'fk_hrs_demographics_respondent'
            AND constraint_type = 'FOREIGN KEY'
        UNION ALL
        SELECT 'A7_WAVE_FK_EXISTS',
            CASE
                WHEN COUNT(*) = 1 THEN 'PASS'
                ELSE 'FAIL'
            END
        FROM dev_catalog.information_schema.table_constraints
        WHERE table_catalog = 'dev_catalog'
            AND table_schema = 'slv_cdm_hrs'
            AND table_name = 'hrs_demographics'
            AND constraint_name = 'fk_hrs_demographics_wave'
            AND constraint_type = 'FOREIGN KEY'
        UNION ALL
        SELECT 'A8_AUDIT_COLUMNS_EXIST',
            CASE
                WHEN COUNT(*) = 3 THEN 'PASS'
                ELSE 'FAIL'
            END
        FROM dev_catalog.information_schema.columns
        WHERE table_catalog = 'dev_catalog'
            AND table_schema = 'slv_cdm_hrs'
            AND table_name = 'hrs_demographics'
            AND column_name IN ('create_date', 'update_date', 'active')
        UNION ALL
        SELECT 'A9_PRIMARY_KEY_EXISTS',
            CASE
                WHEN COUNT(*) = 1 THEN 'PASS'
                ELSE 'FAIL'
            END
        FROM dev_catalog.information_schema.table_constraints
        WHERE table_catalog = 'dev_catalog'
            AND table_schema = 'slv_cdm_hrs'
            AND table_name = 'hrs_demographics'
            AND constraint_name = 'pk_hrs_demographics'
            AND constraint_type = 'PRIMARY KEY'
        UNION ALL
        SELECT 'A10_UNIQUE_BUSINESS_KEY_EXISTS',
            CASE
                WHEN COUNT(*) = 1 THEN 'PASS'
                ELSE 'FAIL'
            END
        FROM dev_catalog.information_schema.table_constraints
        WHERE table_catalog = 'dev_catalog'
            AND table_schema = 'slv_cdm_hrs'
            AND table_name = 'hrs_demographics'
            AND constraint_name = 'uq_hrs_demographics_respondent_wave'
            AND constraint_type = 'UNIQUE'
        UNION ALL
        SELECT 'B1_ROWS_LOADED',
            CASE
                WHEN COUNT(*) > 0 THEN 'PASS'
                ELSE 'FAIL'
            END
        FROM dev_catalog.slv_cdm_hrs.hrs_demographics
        UNION ALL
        SELECT 'B2_RESPONDENT_ID_REFERENTIAL_INTEGRITY',
            CASE
                WHEN COUNT(*) = 0 THEN 'PASS'
                ELSE 'FAIL'
            END
        FROM dev_catalog.slv_cdm_hrs.hrs_demographics d
            LEFT JOIN dev_catalog.slv_cdm_hrs.hrs_respondent r ON d.respondent_id = r.respondent_id
        WHERE r.respondent_id IS NULL
        UNION ALL
        SELECT 'B3_WAVE_ID_REFERENTIAL_INTEGRITY',
            CASE
                WHEN COUNT(*) = 0 THEN 'PASS'
                ELSE 'FAIL'
            END
        FROM dev_catalog.slv_cdm_hrs.hrs_demographics d
            LEFT JOIN dev_catalog.slv_cdm_hrs.hrs_wave w ON d.wave_id = w.wave_id
        WHERE w.wave_id IS NULL
        UNION ALL
        SELECT 'B4_NO_DUPLICATE_RESPONDENT_WAVE',
            CASE
                WHEN COUNT(*) = 0 THEN 'PASS'
                ELSE 'FAIL'
            END
        FROM (
                SELECT respondent_id,
                    wave_id
                FROM dev_catalog.slv_cdm_hrs.hrs_demographics
                GROUP BY respondent_id,
                    wave_id
                HAVING COUNT(*) > 1
            )
        UNION ALL
        SELECT 'B5_NOT_NULL_COLUMNS_ENFORCED',
            CASE
                WHEN COUNT(*) = 0 THEN 'PASS'
                ELSE 'FAIL'
            END
        FROM dev_catalog.slv_cdm_hrs.hrs_demographics
        WHERE respondent_id IS NULL
            OR wave_id IS NULL
            OR wave_number IS NULL
            OR create_date IS NULL
            OR update_date IS NULL
            OR active IS NULL
        UNION ALL
        SELECT 'B6_WAVE_NUMBER_IN_RANGE',
            CASE
                WHEN COUNT(*) = 0 THEN 'PASS'
                ELSE 'FAIL'
            END
        FROM dev_catalog.slv_cdm_hrs.hrs_demographics
        WHERE wave_number NOT BETWEEN 1 AND 16
        UNION ALL
        SELECT 'B7_AGEY_E_PLAUSIBLE_RANGE',
            CASE
                WHEN COUNT(*) = 0 THEN 'PASS'
                ELSE 'FAIL'
            END
        FROM dev_catalog.slv_cdm_hrs.hrs_demographics
        WHERE agey_e IS NOT NULL
            AND (
                agey_e < 0
                OR agey_e > 120
            )
        UNION ALL
        SELECT 'B8_HHIDPN_CONSISTENT_PER_RESPONDENT',
            CASE
                WHEN COUNT(*) = 0 THEN 'PASS'
                ELSE 'FAIL'
            END
        FROM (
                SELECT respondent_id
                FROM dev_catalog.slv_cdm_hrs.hrs_demographics
                GROUP BY respondent_id
                HAVING COUNT(DISTINCT hhidpn) > 1
            )
        UNION ALL
        SELECT 'B9_ACTIVE_FLAG_TRUE_ON_LOAD',
            CASE
                WHEN COUNT(*) = 0 THEN 'PASS'
                ELSE 'FAIL'
            END
        FROM dev_catalog.slv_cdm_hrs.hrs_demographics
        WHERE active = FALSE
    )
ORDER BY test_name;