-- =====================================================================
-- HRS Silver CDM Validation Script – Leave-Behind: Big 5 Personality Traits
-- Target Table: dev_catalog.slv_cdm_hrs.hrs_leave_behind
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
    AND table_name = 'hrs_leave_behind';
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
    AND table_name = 'hrs_leave_behind';
-- A3. Delta Format
SELECT 'A3_DELTA_FORMAT' AS test_name,
    CASE
        WHEN format = 'delta' THEN 'PASS'
        ELSE 'FAIL'
    END AS status,
    CONCAT('format = ', format) AS details
FROM (
        DESCRIBE DETAIL dev_catalog.slv_cdm_hrs.hrs_leave_behind
    );
-- A4. Managed Table
SELECT 'A4_MANAGED_TABLE' AS test_name,
    CASE
        WHEN table_type = 'MANAGED' THEN 'PASS'
        ELSE 'FAIL'
    END AS status,
    CONCAT('table_type = ', table_type) AS details
FROM (
        DESCRIBE DETAIL dev_catalog.slv_cdm_hrs.hrs_leave_behind
    );
-- A5. Identity Column Exists (hrs_leave_behind_id)
SELECT 'A5_IDENTITY_COLUMN_EXISTS' AS test_name,
    CASE
        WHEN COUNT(*) = 1 THEN 'PASS'
        ELSE 'FAIL'
    END AS status,
    CONCAT('Columns found: ', COUNT(*)) AS details
FROM dev_catalog.information_schema.columns
WHERE table_catalog = 'dev_catalog'
    AND table_schema = 'slv_cdm_hrs'
    AND table_name = 'hrs_leave_behind'
    AND column_name = 'hrs_leave_behind_id';
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
    AND table_name = 'hrs_leave_behind'
    AND constraint_name = 'fk_hrs_leave_behind_respondent'
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
    AND table_name = 'hrs_leave_behind'
    AND constraint_name = 'fk_hrs_leave_behind_wave'
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
    AND table_name = 'hrs_leave_behind'
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
    AND table_name = 'hrs_leave_behind'
    AND constraint_name = 'pk_hrs_leave_behind'
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
    AND table_name = 'hrs_leave_behind'
    AND constraint_name = 'uq_hrs_leave_behind_respondent_wave'
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
FROM dev_catalog.slv_cdm_hrs.hrs_leave_behind;
-- B2. respondent_id Exists in hrs_respondent (referential integrity)
SELECT 'B2_RESPONDENT_ID_REFERENTIAL_INTEGRITY' AS test_name,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status,
    CONCAT('Orphaned rows found: ', COUNT(*)) AS details
FROM dev_catalog.slv_cdm_hrs.hrs_leave_behind d
    LEFT JOIN dev_catalog.slv_cdm_hrs.hrs_respondent r ON d.respondent_id = r.respondent_id
WHERE r.respondent_id IS NULL;
-- B3. wave_id Exists in hrs_wave (referential integrity)
SELECT 'B3_WAVE_ID_REFERENTIAL_INTEGRITY' AS test_name,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status,
    CONCAT('Orphaned rows found: ', COUNT(*)) AS details
FROM dev_catalog.slv_cdm_hrs.hrs_leave_behind d
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
        FROM dev_catalog.slv_cdm_hrs.hrs_leave_behind
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
FROM dev_catalog.slv_cdm_hrs.hrs_leave_behind
WHERE respondent_id IS NULL
    OR wave_id IS NULL
    OR wave_number IS NULL
    OR create_date IS NULL
    OR update_date IS NULL
    OR active IS NULL;
-- B6. wave_number Is In Expected Range ('1'-'16' per RAND HRS, stored as STRING)
SELECT 'B6_WAVE_NUMBER_IN_RANGE' AS test_name,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status,
    CONCAT('Out-of-range rows found: ', COUNT(*)) AS details
FROM dev_catalog.slv_cdm_hrs.hrs_leave_behind
WHERE TRY_CAST(wave_number AS INT) IS NULL
    OR TRY_CAST(wave_number AS INT) NOT BETWEEN 1 AND 16;
-- B7. Big 5 Trait Scores Within Documented Domain (1.0-4.0) Where Non-NULL
SELECT 'B7_TRAIT_SCORES_IN_DOMAIN' AS test_name,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status,
    CONCAT(
        'Out-of-domain trait score rows found: ',
        COUNT(*)
    ) AS details
FROM dev_catalog.slv_cdm_hrs.hrs_leave_behind
WHERE (
        lbneur IS NOT NULL
        AND (
            lbneur < 1.0
            OR lbneur > 4.0
        )
    )
    OR (
        lbext IS NOT NULL
        AND (
            lbext < 1.0
            OR lbext > 4.0
        )
    )
    OR (
        lbopen IS NOT NULL
        AND (
            lbopen < 1.0
            OR lbopen > 4.0
        )
    )
    OR (
        lbagr IS NOT NULL
        AND (
            lbagr < 1.0
            OR lbagr > 4.0
        )
    )
    OR (
        lbcon5 IS NOT NULL
        AND (
            lbcon5 < 1.0
            OR lbcon5 > 4.0
        )
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
        FROM dev_catalog.slv_cdm_hrs.hrs_leave_behind
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
FROM dev_catalog.slv_cdm_hrs.hrs_leave_behind
WHERE active = FALSE;
-- B10. Waves 1-7 Scaffold Behaved As Designed
--      (Big 5 was not fielded before Wave 8 -- source has no columns at
--      all for these waves, so every respondent's Wave 1-7 rows should
--      have all 5 trait scores NULL. A non-NULL value here would mean
--      the scaffold logic broke, or the UNPIVOT accidentally picked up
--      real data it shouldn't have for these waves.)
SELECT 'B10_WAVES_1_7_SCAFFOLD_ALL_NULL' AS test_name,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status,
    CONCAT(
        'Wave 1-7 rows with unexpected non-NULL trait data: ',
        COUNT(*)
    ) AS details
FROM dev_catalog.slv_cdm_hrs.hrs_leave_behind
WHERE TRY_CAST(wave_number AS INT) BETWEEN 1 AND 7
    AND (
        lbneur IS NOT NULL
        OR lbext IS NOT NULL
        OR lbopen IS NOT NULL
        OR lbagr IS NOT NULL
        OR lbcon5 IS NOT NULL
    );
-- B11. Waves 8-16 Actually Contain Some Non-NULL Trait Data
--      (Sanity check that the UNPIVOT branch worked and did not
--      accidentally load only NULLs for the waves where real source
--      data exists.)
SELECT 'B11_WAVES_8_16_HAVE_DATA' AS test_name,
    CASE
        WHEN COUNT(*) > 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status,
    CONCAT(
        'Wave 8-16 rows with at least one non-NULL trait: ',
        COUNT(*)
    ) AS details
FROM dev_catalog.slv_cdm_hrs.hrs_leave_behind
WHERE TRY_CAST(wave_number AS INT) BETWEEN 8 AND 16
    AND (
        lbneur IS NOT NULL
        OR lbext IS NOT NULL
        OR lbopen IS NOT NULL
        OR lbagr IS NOT NULL
        OR lbcon5 IS NOT NULL
    );
-- B12. Every Respondent Has Exactly 16 Rows (Waves 1-16, per Section 9's
--      declared full-study-span grain)
SELECT 'B12_EVERY_RESPONDENT_HAS_16_WAVE_ROWS' AS test_name,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status,
    CONCAT(
        'respondent_id values without exactly 16 wave rows: ',
        COUNT(*)
    ) AS details
FROM (
        SELECT respondent_id
        FROM dev_catalog.slv_cdm_hrs.hrs_leave_behind
        GROUP BY respondent_id
        HAVING COUNT(*) <> 16
    );
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
            AND table_name = 'hrs_leave_behind'
        UNION ALL
        SELECT 'A3_DELTA_FORMAT',
            CASE
                WHEN format = 'delta' THEN 'PASS'
                ELSE 'FAIL'
            END
        FROM (
                DESCRIBE DETAIL dev_catalog.slv_cdm_hrs.hrs_leave_behind
            )
        UNION ALL
        SELECT 'A4_MANAGED_TABLE',
            CASE
                WHEN table_type = 'MANAGED' THEN 'PASS'
                ELSE 'FAIL'
            END
        FROM (
                DESCRIBE DETAIL dev_catalog.slv_cdm_hrs.hrs_leave_behind
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
            AND table_name = 'hrs_leave_behind'
            AND column_name = 'hrs_leave_behind_id'
        UNION ALL
        SELECT 'A6_RESPONDENT_FK_EXISTS',
            CASE
                WHEN COUNT(*) = 1 THEN 'PASS'
                ELSE 'FAIL'
            END
        FROM dev_catalog.information_schema.table_constraints
        WHERE table_catalog = 'dev_catalog'
            AND table_schema = 'slv_cdm_hrs'
            AND table_name = 'hrs_leave_behind'
            AND constraint_name = 'fk_hrs_leave_behind_respondent'
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
            AND table_name = 'hrs_leave_behind'
            AND constraint_name = 'fk_hrs_leave_behind_wave'
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
            AND table_name = 'hrs_leave_behind'
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
            AND table_name = 'hrs_leave_behind'
            AND constraint_name = 'pk_hrs_leave_behind'
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
            AND table_name = 'hrs_leave_behind'
            AND constraint_name = 'uq_hrs_leave_behind_respondent_wave'
            AND constraint_type = 'UNIQUE'
        UNION ALL
        SELECT 'B1_ROWS_LOADED',
            CASE
                WHEN COUNT(*) > 0 THEN 'PASS'
                ELSE 'FAIL'
            END
        FROM dev_catalog.slv_cdm_hrs.hrs_leave_behind
        UNION ALL
        SELECT 'B2_RESPONDENT_ID_REFERENTIAL_INTEGRITY',
            CASE
                WHEN COUNT(*) = 0 THEN 'PASS'
                ELSE 'FAIL'
            END
        FROM dev_catalog.slv_cdm_hrs.hrs_leave_behind d
            LEFT JOIN dev_catalog.slv_cdm_hrs.hrs_respondent r ON d.respondent_id = r.respondent_id
        WHERE r.respondent_id IS NULL
        UNION ALL
        SELECT 'B3_WAVE_ID_REFERENTIAL_INTEGRITY',
            CASE
                WHEN COUNT(*) = 0 THEN 'PASS'
                ELSE 'FAIL'
            END
        FROM dev_catalog.slv_cdm_hrs.hrs_leave_behind d
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
                FROM dev_catalog.slv_cdm_hrs.hrs_leave_behind
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
        FROM dev_catalog.slv_cdm_hrs.hrs_leave_behind
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
        FROM dev_catalog.slv_cdm_hrs.hrs_leave_behind
        WHERE TRY_CAST(wave_number AS INT) IS NULL
            OR TRY_CAST(wave_number AS INT) NOT BETWEEN 1 AND 16
        UNION ALL
        SELECT 'B7_TRAIT_SCORES_IN_DOMAIN',
            CASE
                WHEN COUNT(*) = 0 THEN 'PASS'
                ELSE 'FAIL'
            END
        FROM dev_catalog.slv_cdm_hrs.hrs_leave_behind
        WHERE (
                lbneur IS NOT NULL
                AND (
                    lbneur < 1.0
                    OR lbneur > 4.0
                )
            )
            OR (
                lbext IS NOT NULL
                AND (
                    lbext < 1.0
                    OR lbext > 4.0
                )
            )
            OR (
                lbopen IS NOT NULL
                AND (
                    lbopen < 1.0
                    OR lbopen > 4.0
                )
            )
            OR (
                lbagr IS NOT NULL
                AND (
                    lbagr < 1.0
                    OR lbagr > 4.0
                )
            )
            OR (
                lbcon5 IS NOT NULL
                AND (
                    lbcon5 < 1.0
                    OR lbcon5 > 4.0
                )
            )
        UNION ALL
        SELECT 'B8_HHIDPN_CONSISTENT_PER_RESPONDENT',
            CASE
                WHEN COUNT(*) = 0 THEN 'PASS'
                ELSE 'FAIL'
            END
        FROM (
                SELECT respondent_id
                FROM dev_catalog.slv_cdm_hrs.hrs_leave_behind
                GROUP BY respondent_id
                HAVING COUNT(DISTINCT hhidpn) > 1
            )
        UNION ALL
        SELECT 'B9_ACTIVE_FLAG_TRUE_ON_LOAD',
            CASE
                WHEN COUNT(*) = 0 THEN 'PASS'
                ELSE 'FAIL'
            END
        FROM dev_catalog.slv_cdm_hrs.hrs_leave_behind
        WHERE active = FALSE
        UNION ALL
        SELECT 'B10_WAVES_1_7_SCAFFOLD_ALL_NULL',
            CASE
                WHEN COUNT(*) = 0 THEN 'PASS'
                ELSE 'FAIL'
            END
        FROM dev_catalog.slv_cdm_hrs.hrs_leave_behind
        WHERE TRY_CAST(wave_number AS INT) BETWEEN 1 AND 7
            AND (
                lbneur IS NOT NULL
                OR lbext IS NOT NULL
                OR lbopen IS NOT NULL
                OR lbagr IS NOT NULL
                OR lbcon5 IS NOT NULL
            )
        UNION ALL
        SELECT 'B11_WAVES_8_16_HAVE_DATA',
            CASE
                WHEN COUNT(*) > 0 THEN 'PASS'
                ELSE 'FAIL'
            END
        FROM dev_catalog.slv_cdm_hrs.hrs_leave_behind
        WHERE TRY_CAST(wave_number AS INT) BETWEEN 8 AND 16
            AND (
                lbneur IS NOT NULL
                OR lbext IS NOT NULL
                OR lbopen IS NOT NULL
                OR lbagr IS NOT NULL
                OR lbcon5 IS NOT NULL
            )
        UNION ALL
        SELECT 'B12_EVERY_RESPONDENT_HAS_16_WAVE_ROWS',
            CASE
                WHEN COUNT(*) = 0 THEN 'PASS'
                ELSE 'FAIL'
            END
        FROM (
                SELECT respondent_id
                FROM dev_catalog.slv_cdm_hrs.hrs_leave_behind
                GROUP BY respondent_id
                HAVING COUNT(*) <> 16
            )
    )
ORDER BY test_name;