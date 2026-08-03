DROP TABLE IF EXISTS dev_catalog.slv_cdm_hrs.hrs_respondent_type;

CREATE TABLE dev_catalog.slv_cdm_hrs.hrs_respondent_type (
    hrs_respondent_type_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    respondent_type_code STRING,
    respondent_type_description STRING,
    create_date DATE,
    update_date DATE,
    active BOOLEAN
)
USING DELTA
COMMENT 'Respondent type tracking table';