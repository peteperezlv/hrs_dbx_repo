DROP TABLE IF EXISTS dev_catalog.slv_cdm_hrs.dim_cohort;
CREATE TABLE dev_catalog.slv_cdm_hrs.dim_cohort (
    cohort_id BIGINT GENERATED ALWAYS AS IDENTITY COMMENT 'System-generated surrogate primary key',
    hacohort TINYINT COMMENT 'RAND HRS respondent cohort code (HACOHORT)',
    create_date DATE NOT NULL COMMENT 'Record creation date',
    update_date DATE NOT NULL COMMENT 'Date the record was last updated',
    active BOOLEAN NOT NULL COMMENT 'Indicates whether the record is active',
    CONSTRAINT pk_dim_cohort PRIMARY KEY (cohort_id)
) USING DELTA COMMENT 'Stores RAND HRS cohort codes ';