DROP TABLE IF EXISTS dev_catalog.slv_cdm_hrs.respondent;

CREATE TABLE dev_catalog.slv_cdm_hrs.respondent (
    respondent_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cohort_id BIGINT,
    respondent_description STRING,
    gender STRING,
    respondent_type STRING,
    create_date DATE,
    update_date DATE,
    active BOOLEAN,

    CONSTRAINT fk_cohort FOREIGN KEY (cohort_id) REFERENCES dev_catalog.slv_cdm_hrs.cohort(cohort_id)
)
USING DELTA
COMMENT 'Respondent tracking table';