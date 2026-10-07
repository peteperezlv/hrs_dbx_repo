DROP TABLE IF EXISTS dev_catalog.slv_cdm_hrs.hub_respondent;

CREATE TABLE dev_catalog.slv_cdm_hrs.hub_respondent
(
    respondent_id BIGINT GENERATED ALWAYS AS IDENTITY
        COMMENT 'System-generated surrogate primary key',
    cohort_id BIGINT
        COMMENT 'Foreign key to dim_cohort.cohort_id',
    hhidpn DOUBLE
        COMMENT 'RAND HRS natural respondent identifier (HHIDPN)',
    create_date DATE NOT NULL
        COMMENT 'Record creation date',
    update_date DATE NOT NULL
        COMMENT 'Date the record was last updated',
    active BOOLEAN NOT NULL
        COMMENT 'Indicates whether the record is active',
    CONSTRAINT pk_hub_respondent PRIMARY KEY (respondent_id),
    CONSTRAINT fk_hub_respondent_dim_cohort
        FOREIGN KEY (cohort_id)
        REFERENCES dev_catalog.slv_cdm_hrs.dim_cohort (cohort_id)
)
USING DELTA
COMMENT 'Stores RAND HRS respondents';
