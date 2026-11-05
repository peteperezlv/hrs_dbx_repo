DROP TABLE IF EXISTS dev_catalog.gld_star_hrs.analytic_hrs_bmi_stats;

CREATE TABLE dev_catalog.gld_star_hrs.analytic_hrs_bmi_stats (
    analytic_hrs_bmi_stats_id BIGINT GENERATED ALWAYS AS IDENTITY NOT NULL COMMENT 'System-generated surrogate key',
    wave_id BIGINT NOT NULL COMMENT 'Foreign key to dim_wave',
    cohort_id BIGINT NOT NULL COMMENT 'Foreign key to dim_cohort',
    wave_number INT COMMENT 'HRS Wave Number identifier',
    hacohort INT COMMENT 'HRS cohort identifier',
    raracem INT COMMENT 'RAND HRS race category',
    ragender INT COMMENT 'RAND HRS gender category',
    agey_e INT COMMENT 'RAND HRS age category',
    bmi_count INT COMMENT 'Number of records included in the BMI statistics',
    bmi_mean DOUBLE COMMENT 'Mean BMI',
    bmi_min DOUBLE COMMENT 'Minimum BMI',
    bmi_max DOUBLE COMMENT 'Maximum BMI',
    bmi_sd DOUBLE COMMENT 'Standard deviation of BMI',
    create_date DATE NOT NULL COMMENT 'Record creation date',
    update_date DATE NOT NULL COMMENT 'Last update date',
    active BOOLEAN NOT NULL COMMENT 'Active indicator',
    CONSTRAINT pk_analytic_hrs_bmi_stats PRIMARY KEY (analytic_hrs_bmi_stats_id) NOT ENFORCED,
    CONSTRAINT fk_analytic_hrs_bmi_stats_dim_wave FOREIGN KEY (wave_id)
        REFERENCES dev_catalog.slv_cdm_hrs.dim_wave (wave_id) NOT ENFORCED,
    CONSTRAINT fk_analytic_hrs_bmi_stats_dim_cohort FOREIGN KEY (cohort_id)
        REFERENCES dev_catalog.slv_cdm_hrs.dim_cohort (cohort_id) NOT ENFORCED
)
USING DELTA
COMMENT 'Descriptive BMI statistics by cohort, wave, race, and gender';
