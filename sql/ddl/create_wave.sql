CREATE TABLE IF NOT EXISTS dev_catalog.slv_cdm_hrs.wave (
    wave_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    wave_name STRING,
    wave_description STRING, 
    start_date DATE,
    end_date DATE,
    active BOOLEAN
)
USING DELTA
COMMENT 'Wave tracking table';