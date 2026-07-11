DROP TABLE IF EXISTS dev_catalog.slv_cdm_hrs.respondent_type;

CREATE TABLE dev_catalog.slv_cdm_hrs.respondent_type (
    respondent_type_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    respondent_type_description STRING,
    start_date DATE,
    end_date DATE,
    active BOOLEAN
)
USING DELTA
COMMENT 'Respondent type tracking table';