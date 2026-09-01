-- comments
DROP TABLE IF EXISTS IDENTIFIER(
    CONCAT(
        :catalog_name,
        '.',
        :schema_prefix,
        '.dim_cohort'
    )
);
CREATE TABLE IDENTIFIER(
    CONCAT(
        :catalog_name,
        '.',
        :schema_prefix,
        '.dim_cohort'
    )
) (
    cohort_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    hacohort_number INT,
    hacohort_label STRING,
    hacohort_description STRING,
    create_date DATE,
    update_date DATE,
    active BOOLEAN
) USING DELTA COMMENT 'Cohort tracking table';