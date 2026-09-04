TRUNCATE TABLE dev_catalog.gld_star_hrs.dim_hrs_cohort;
INSERT INTO dev_catalog.gld_star_hrs.dim_hrs_cohort (
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
FROM dev_catalog.slv_cdm_hrs.dim_cohort
WHERE active = TRUE;