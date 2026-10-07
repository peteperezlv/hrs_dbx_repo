DROP TABLE IF EXISTS dev_catalog.slv_cdm_hrs.fact_health;

CREATE TABLE dev_catalog.slv_cdm_hrs.fact_health
(
    hrs_health_id BIGINT GENERATED ALWAYS AS IDENTITY
        COMMENT 'System-generated surrogate primary key',
    respondent_id BIGINT NOT NULL
        COMMENT 'Foreign key to hub_respondent.respondent_id',
    wave_id BIGINT NOT NULL
        COMMENT 'Foreign key to dim_wave.wave_id',
    shlt TINYINT
        COMMENT 'Self-rated health (R{wave}SHLT)',
    bmi DOUBLE
        COMMENT 'Self-reported body mass index in kg/m2 (R{wave}BMI)',
    hibpe TINYINT
        COMMENT 'Ever diagnosed with high blood pressure (R{wave}HIBPE)',
    diabe TINYINT
        COMMENT 'Ever diagnosed with diabetes (R{wave}DIABE)',
    cancre TINYINT
        COMMENT 'Ever diagnosed with cancer (R{wave}CANCRE)',
    lunge TINYINT
        COMMENT 'Ever diagnosed with lung disease (R{wave}LUNGE)',
    hearte TINYINT
        COMMENT 'Ever diagnosed with heart problems (R{wave}HEARTE)',
    stroke TINYINT
        COMMENT 'Ever diagnosed with stroke (R{wave}STROKE)',
    psyche TINYINT
        COMMENT 'Ever diagnosed with psychiatric problems (R{wave}PSYCHE)',
    arthre TINYINT
        COMMENT 'Ever diagnosed with arthritis (R{wave}ARTHRE)',
    create_date DATE NOT NULL
        COMMENT 'Record creation date',
    update_date DATE NOT NULL
        COMMENT 'Date the record was last updated',
    active BOOLEAN NOT NULL
        COMMENT 'Indicates whether the record is active',
    CONSTRAINT pk_fact_health PRIMARY KEY (hrs_health_id),
    CONSTRAINT fk_fact_health_hub_respondent
        FOREIGN KEY (respondent_id)
        REFERENCES dev_catalog.slv_cdm_hrs.hub_respondent (respondent_id),
    CONSTRAINT fk_fact_health_dim_wave
        FOREIGN KEY (wave_id)
        REFERENCES dev_catalog.slv_cdm_hrs.dim_wave (wave_id)
)
USING DELTA
COMMENT 'Stores RAND HRS health observations';
