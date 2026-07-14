DROP TABLE IF EXISTS dev_catalog.slv_cdm_hrs.cohort;

CREATE TABLE dev_catalog.slv_cdm_hrs.cohort (
    hrs_cohort_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    hacohort_number INT,
    hacohort_label STRING,
    hacohort_description STRING,
    create_date DATE,
    update_date DATE,
    
    active BOOLEAN
)
USING DELTA
COMMENT 'Cohort tracking table';