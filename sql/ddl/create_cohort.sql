CREATE TABLE cohort (
    cohort_id INT PRIMARY KEY,
    cohort_name STRING,
    cohort_description string,
    start_date DATE,
    end_date DATE,
    active BOOLEAN
)
USING DELTA
COMMENT 'Cohort tracking table';