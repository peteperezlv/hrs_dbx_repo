DROP TABLE IF EXISTS dev_catalog.slv_cdm_hrs.question;

CREATE TABLE dev_catalog.slv_cdm_hrs.question (
    question_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    question_name STRING,
    question_description STRING, 
    start_date DATE,
    end_date DATE,
    active BOOLEAN
)
USING DELTA
COMMENT 'Question tracking table';