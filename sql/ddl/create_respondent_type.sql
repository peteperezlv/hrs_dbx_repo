CREATE TABLE IF NOT EXISTS dev_catalog.slv_cdm_hrs.respondent_type (
    respondent_type_id INT PRIMARY KEY,
    respondent_type_description STRING,
    start_date DATE,
    end_date DATE,
    active BOOLEAN
)
USING DELTA
COMMENT 'Respondent type tracking table';