TRUNCATE TABLE IDENTIFIER(
    CONCAT(
        :catalog_name,
        '.',
        :schema_prefix,
        '.dim_hrs_cohort'
    )
);
--
INSERT INTO IDENTIFIER(
        CONCAT(
            :catalog_name,
            '.',
            :schema_prefix,
            '.dim_hrs_cohort'
        )
    ) (
        hacohort_number,
        hacohort_label,
        hacohort_description,
        create_date,
        update_date,
        active
    )
SELECT hacohort_number,
    hacohort_label,
    hacohort_description,
    CURRENT_DATE() AS create_date,
    CURRENT_DATE() AS update_date,
    active
FROM staging_catalog.slv_cdm_hrs.hrs_cohort
WHERE active = TRUE;