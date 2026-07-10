CREATE TABLE question (
    question_id INT PRIMARY KEY,
    question_name STRING,
    question_description STRING, 
    start_date DATE,
    end_date DATE,
    active BOOLEAN
)
USING DELTA
COMMENT 'Question tracking table';