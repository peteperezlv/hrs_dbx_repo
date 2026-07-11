CREATE TABLE IF NOT EXISTS dev_catalog.slv_cdm_hrs.cohort (
    cohort_id INT PRIMARY KEY,
    cohort_name STRING,
    cohort_description STRING,
    start_date DATE,
    end_date DATE,
    active BOOLEAN
)
USING DELTA
COMMENT 'Cohort tracking table';