DROP TABLE IF EXISTS dev_catalog.slv_cdm_hrs.hrs_wave;

CREATE TABLE dev_catalog.slv_cdm_hrs.hrs_survey_wave (
    hrs_survey_wave_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    wave_number STRING,
    wave_year STRING,
    wave_description STRING, 
    create_date DATE,
    update_date DATE,
    active BOOLEAN
)
USING DELTA
COMMENT 'Wave tracking table';