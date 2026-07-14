DROP TABLE IF EXISTS dev_catalog.slv_cdm_hrs.wave;

CREATE TABLE IF NOT EXISTS dev_catalog.slv_cdm_hrs.wave (
    wave_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    wave_number INT,
    wave_year STRING,
    wave_description STRING, 
    create_date DATE,
    update_date DATE,
    active BOOLEAN
)
USING DELTA
COMMENT 'Wave tracking table';