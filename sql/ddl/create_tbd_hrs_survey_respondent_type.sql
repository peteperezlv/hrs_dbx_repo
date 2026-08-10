DROP TABLE IF EXISTS IDENTIFIER(
    CONCAT(
        :catalog_name,
        '.',
        :schema_prefix,
        '.hrs_respondent_type'
    )
);
CREATE TABLE IDENTIFIER(
    CONCAT(
        :catalog_name,
        '.',
        :schema_prefix,
        '.hrs_respondent_type'
    )
) (
    hrs_respondent_type_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    respondent_type_code STRING,
    respondent_type_description STRING,
    create_date DATE,
    update_date DATE,
    active BOOLEAN
) USING DELTA COMMENT 'Respondent type tracking table';