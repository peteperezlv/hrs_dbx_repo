SELECT 'A1_TABLE_EXISTS' AS test_name,
    CASE
        WHEN COUNT(*) = 1 THEN 'PASS'
        ELSE 'FAIL'
    END AS status,
    CONCAT('Row count found: ', COUNT(*)) AS details
FROM information_schema.tables
WHERE table_catalog = 'dev_catalog'
    AND table_schema = 'slv_cdm_hrs'
    AND table_name = 'hrs_demographics';