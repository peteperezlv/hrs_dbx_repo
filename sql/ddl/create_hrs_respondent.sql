DROP TABLE IF EXISTS dev_catalog.slv_cdm_hrs.respondent;

CREATE TABLE dev_catalog.slv_cdm_hrs.respondent (
    respondent_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    hrs_cohort_id BIGINT,
    respondent_type_id BIGINT,
    hrs_wave_id BIGINT,
    respondent_description STRING,
    gender STRING,
    respondent_type STRING,
    create_date DATE,
    update_date DATE,
    active BOOLEAN,
    CONSTRAINT fk_respondent_type FOREIGN KEY (respondent_type_id) REFERENCES dev_catalog.slv_cdm_hrs.respondent_type(respondent_type_id),
    CONSTRAINT fk_cohort FOREIGN KEY (cohort_id) REFERENCES dev_catalog.slv_cdm_hrs.cohort(cohort_id),
    CONSTRAINT fk_wave_id FOREIGN KEY (wave_id) REFERENCES dev_catalog.slv_cdm_hrs.wave(wave_id)
)
USING DELTA
COMMENT 'Respondent tracking table';