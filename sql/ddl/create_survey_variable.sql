DROP TABLE IF EXISTS dev_catalog.slv_cdm_hrs.survey_variable;

CREATE TABLE dev_catalog.slv_cdm_hrs.survey_variable (
    survey_variable_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    rhrs_survey_section_id BIGINT,
    wave_id BIGINT,
    survey_variable_name STRING,
    survey_variable_description STRING,
    survey_variable_type STRING,
    create_date DATE,
    update_date DATE,
    active BOOLEAN,
    CONSTRAINT survey_variable_wave_fk FOREIGN KEY (wave_id) REFERENCES dev_catalog.slv_cdm_hrs.wave(wave_id),
    CONSTRAINT survey_variable_rhrs_survey_section_fk FOREIGN KEY (rhrs_survey_section_id) REFERENCES dev_catalog.slv_cdm_hrs.rhrs_survey_section(rhrs_survey_section_id)
)
USING DELTA
COMMENT 'Question tracking table';