-- HRS Silver CDM DDL: Demographics v2
-- Generated from the SLV DDL prompt and HRS DDL master template.

DROP TABLE IF EXISTS dev_catalog.slv_cdm_hrs.fact_demographics_v2;

CREATE TABLE dev_catalog.slv_cdm_hrs.fact_demographics_v2 (
    fact_demographics_v2_id BIGINT GENERATED ALWAYS AS IDENTITY COMMENT 'System-generated surrogate primary key',
    respondent_id BIGINT NOT NULL COMMENT 'Foreign key to hub_respondent.respondent_id',
    wave_id BIGINT NOT NULL COMMENT 'Foreign key to dim_wave.wave_id',
    HHIDPN DOUBLE NOT NULL COMMENT 'RAND HRS natural respondent identifier',
    wave_number STRING NOT NULL COMMENT 'RAND HRS natural survey wave identifier',
    agey_e DECIMAL(10, 2) COMMENT 'Respondent age',
    cenreg TINYINT COMMENT 'Census region',
    mstat TINYINT COMMENT 'Marital status',
    raracem TINYINT COMMENT 'RAND HRS race classification',
    rahispan TINYINT COMMENT 'RAND HRS Hispanic classification',
    raedyrs TINYINT COMMENT 'Years of education',
    rarelig TINYINT COMMENT 'Religion',
    ravetrn TINYINT COMMENT 'Veteran status',
    create_date DATE NOT NULL COMMENT 'Record creation date',
    update_date DATE NOT NULL COMMENT 'Date the record was last updated',
    active BOOLEAN NOT NULL COMMENT 'Indicates whether the record is active',
    CONSTRAINT pk_fact_demographics_v2 PRIMARY KEY (fact_demographics_v2_id),
    CONSTRAINT fk_fact_demographics_v2_hub_respondent FOREIGN KEY (respondent_id)
        REFERENCES dev_catalog.slv_cdm_hrs.hub_respondent (respondent_id),
    CONSTRAINT fk_fact_demographics_v2_dim_wave FOREIGN KEY (wave_id)
        REFERENCES dev_catalog.slv_cdm_hrs.dim_wave (wave_id)
)
USING DELTA
COMMENT 'RAND HRS demographics fact table.';