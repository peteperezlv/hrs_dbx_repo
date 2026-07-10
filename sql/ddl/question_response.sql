CREATE TABLE question_response (
    question_response_id INT PRIMARY KEY,
    question_response_description STRING,
    start_date DATE,
    end_date DATE,
    active BOOLEAN
)
USING DELTA
COMMENT 'Respondent tracking table';