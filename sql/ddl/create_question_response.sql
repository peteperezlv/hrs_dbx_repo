CREATE TABLE question_response (
    question_response_id INT PRIMARY KEY,
    question_response_description STRING,
    respondent_id INT,
    question_id INT,
    wave_id INT,
    start_date DATE,
    end_date DATE,
    active BOOLEAN,
    CONSTRAINT fk_respondent FOREIGN KEY (respondent_id) REFERENCES respondent(respondent_id),
    CONSTRAINT fk_question FOREIGN KEY (question_id) REFERENCES question(question_id),
    CONSTRAINT fk_wave FOREIGN KEY (wave_id) REFERENCES wave(wave_id)
)
USING DELTA
COMMENT 'Question response tracking table';