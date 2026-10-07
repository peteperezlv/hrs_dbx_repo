DROP TABLE IF EXISTS dev_catalog.slv_cdm_hrs.fact_demographics;

CREATE TABLE dev_catalog.slv_cdm_hrs.fact_demographics
(
    hrs_demographics_id BIGINT GENERATED ALWAYS AS IDENTITY
        COMMENT 'System-generated surrogate primary key',
    respondent_id BIGINT NOT NULL
        COMMENT 'Foreign key to hub_respondent.respondent_id',
    wave_id BIGINT NOT NULL
        COMMENT 'Foreign key to dim_wave.wave_id',
    agey_e TINYINT
        COMMENT 'Respondent age in years at interview end month (R{wave}AGEY_E)',
    raracem TINYINT
        COMMENT 'RAND HRS race-masked classification (RARACEM)',
    ragender TINYINT
        COMMENT 'RAND HRS respondent gender classification (RAGENDER)',
    rahispan TINYINT
        COMMENT 'RAND HRS Hispanic classification (RAHISPAN)',
    create_date DATE NOT NULL
        COMMENT 'Record creation date',
    update_date DATE NOT NULL
        COMMENT 'Date the record was last updated',
    active BOOLEAN NOT NULL
        COMMENT 'Indicates whether the record is active',
    CONSTRAINT pk_fact_demographics PRIMARY KEY (hrs_demographics_id),
    CONSTRAINT fk_fact_demographics_hub_respondent
        FOREIGN KEY (respondent_id)
        REFERENCES dev_catalog.slv_cdm_hrs.hub_respondent (respondent_id),
    CONSTRAINT fk_fact_demographics_dim_wave
        FOREIGN KEY (wave_id)
        REFERENCES dev_catalog.slv_cdm_hrs.dim_wave (wave_id)
)
USING DELTA
COMMENT 'Stores RAND HRS demographic observations';
