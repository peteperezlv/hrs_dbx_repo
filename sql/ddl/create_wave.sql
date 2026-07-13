DROP TABLE IF EXISTS dev_catalog.slv_cdm_hrs.wave;

CREATE TABLE IF NOT EXISTS dev_catalog.slv_cdm_hrs.wave (
    wave_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cohort_id BIGINT,
    wave_number INT,
    wave_year STRING,
    wave_description STRING, 
    create_date DATE,
    update_date DATE,
    active BOOLEAN,
    CONSTRAINT fk_cohort_lookup FOREIGN KEY (cohort_id) REFERENCES dev_catalog.slv_cdm_hrs.cohort(cohort_id)
)
USING DELTA
COMMENT 'Wave tracking table';