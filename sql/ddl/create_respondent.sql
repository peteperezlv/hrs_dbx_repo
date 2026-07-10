CREATE TABLE respondent (
    respondent_id INT PRIMARY KEY,
    respondent_description STRING,
    gender STRING,
    respondent_type_id INT,
    cohort_id INT,
    start_date DATE,
    end_date DATE,
    active BOOLEAN,
    CONSTRAINT fk_respondent_type FOREIGN KEY (respondent_type_id) REFERENCES respondent_type(respondent_type_id),
    CONSTRAINT fk_cohort FOREIGN KEY (cohort_id) REFERENCES cohort(cohort_id)
)
USING DELTA
COMMENT 'Respondent tracking table';