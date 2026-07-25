DROP TABLE IF EXISTS dev_catalog.slv_cdm_hrs.hrs_cohort_hrs_wave;

CREATE TABLE dev_catalog.slv_cdm_hrs.hrs_cohort_hrs_wave (
    hrs_cohort_wave_id BIGINT GENERATED ALWAYS AS IDENTITY,
    hrs_cohort_id BIGINT NOT NULL,
    hrs_wave_id BIGINT NOT NULL,
    create_date DATE,
    update_date DATE,
    active BOOLEAN,
    PRIMARY KEY (hrs_cohort_wave_id),
    CONSTRAINT uk_cohort_wave UNIQUE (hrs_cohort_id, hrs_wave_id),
    CONSTRAINT fk_hrs_cohort_wave_hrs_cohort FOREIGN KEY (hrs_cohort_id) REFERENCES dev_catalog.slv_cdm_hrs.hrs_cohort(hrs_cohort_id),
    CONSTRAINT fk_hrs_cohort_wave_hrs_wave FOREIGN KEY (hrs_wave_id) REFERENCES dev_catalog.slv_cdm_hrs.hrs_wave(hrs_wave_id)
)
USING DELTA
COMMENT 'Many-to-many junction table linking cohorts to waves - tracks which cohorts participated in which interview waves';