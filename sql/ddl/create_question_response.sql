DROP TABLE IF EXISTS dev_catalog.slv_cdm_hrs.question_response;

CREATE TABLE dev_catalog.slv_cdm_hrs.question_response (
    question_response_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    question_response_description STRING,
    respondent_id BIGINT,
    question_id BIGINT,
    wave_id BIGINT,
    start_date DATE,
    end_date DATE,
    active BOOLEAN,
    CONSTRAINT fk_respondent FOREIGN KEY (respondent_id) REFERENCES dev_catalog.slv_cdm_hrs.respondent(respondent_id),
    CONSTRAINT fk_question FOREIGN KEY (question_id) REFERENCES dev_catalog.slv_cdm_hrs.question(question_id),
    CONSTRAINT fk_wave FOREIGN KEY (wave_id) REFERENCES dev_catalog.slv_cdm_hrs.wave(wave_id)
)
USING DELTA
COMMENT 'Question response tracking table';