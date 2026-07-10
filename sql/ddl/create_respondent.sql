CREATE TABLE respondent (
    respondent_id INT PRIMARY KEY,
    respondent_description STRING,
    gender STRING,
    start_date DATE,
    end_date DATE,
    active BOOLEAN
)
USING DELTA
COMMENT 'Respondent tracking table';