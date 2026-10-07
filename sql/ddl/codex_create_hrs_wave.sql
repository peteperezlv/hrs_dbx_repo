DROP TABLE IF EXISTS dev_catalog.slv_cdm_hrs.dim_wave;

CREATE TABLE dev_catalog.slv_cdm_hrs.dim_wave
(
    wave_id BIGINT GENERATED ALWAYS AS IDENTITY
        COMMENT 'System-generated surrogate primary key',
    wave_number STRING
        COMMENT 'RAND HRS survey wave identifier',
    create_date DATE NOT NULL
        COMMENT 'Record creation date',
    update_date DATE NOT NULL
        COMMENT 'Date the record was last updated',
    active BOOLEAN NOT NULL
        COMMENT 'Indicates whether the record is active',
    CONSTRAINT pk_dim_wave PRIMARY KEY (wave_id)
)
USING DELTA
COMMENT 'Stores RAND HRS survey waves';
