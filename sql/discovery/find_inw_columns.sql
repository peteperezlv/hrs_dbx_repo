-- Find all column names starting with 'INW' in the RAND longitudinal dataset
-- This helps identify wave-related columns before loading to the wave reference table

SELECT 
    column_name,
    REGEXP_EXTRACT(column_name, '^INW([0-9]+)', 1) as wave_number,
    data_type,
    ordinal_position
FROM dev_catalog.information_schema.columns
WHERE table_catalog = 'dev_catalog'
  AND table_schema = 'brz_raw_hrs'
  AND table_name = 'randhrs1992_2022v1'
  AND UPPER(column_name) RLIKE '^INW[0-9]+'
ORDER BY 
    CAST(REGEXP_EXTRACT(column_name, '^INW([0-9]+)', 1) AS INT),
    column_name;