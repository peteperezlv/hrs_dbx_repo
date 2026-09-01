DROP TABLE IF EXISTS IDENTIFIER(
    CONCAT(
        :catalog_name,
        '.',
        :schema_prefix,
        '.hub_respondent'
    )
);
CREATE TABLE IDENTIFIER(
    CONCAT(
        :catalog_name,
        '.',
        :schema_prefix,
        '.hub_respondent'
    )
) (
    respondent_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cohort_id BIGINT,
    hhid STRING,
    pn STRING,
    hhidpn BIGINT,
    hacohort INT,
    respondent_description STRING,
    create_date DATE,
    update_date DATE,
    active BOOLEAN,
    CONSTRAINT hrs_respondent_hrs_cohort_fk FOREIGN KEY (cohort_id) REFERENCES dev_catalog.slv_cdm_hrs.hrs_cohort(cohort_id)
) USING DELTA COMMENT 'Respondent tracking table';