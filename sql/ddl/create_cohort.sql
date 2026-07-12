DROP TABLE IF EXISTS dev_catalog.slv_cdm_hrs.cohort;

CREATE TABLE dev_catalog.slv_cdm_hrs.cohort (
    cohort_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    hacohort DOUBLE,
    cohort_label STRING,
    cohort_description STRING,
    create_date DATE,
    update_date DATE,
    active BOOLEAN,
    wave_id BIGINT,
     CONSTRAINT fk_wave_lookup FOREIGN KEY (wave_id) REFERENCES dev_catalog.slv_cdm_hrs.wave(wave_id)
)
USING DELTA
COMMENT 'Cohort tracking table';