CREATE TABLE respondent (
    respondent_id INT PRIMARY KEY,
    respondent_name STRING,
    respondent_description STRING, 
    start_date DATE,
    end_date DATE,
    active BOOLEAN
)
USING DELTA
COMMENT 'Respondent tracking table';