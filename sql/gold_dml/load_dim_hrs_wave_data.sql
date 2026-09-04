-- Truncate and reload from source
-- Load the data
TRUNCATE TABLE dev_catalog.gld_star_hrs.dim_hrs_cohort;
INSERT INTO dev_catalog.gld_star_hrs.dim_hrs_cohort (
        wave_number,
        wave_year,
        wave_description,
        create_date,
        update_date,
        active
    )
SELECT wave_number,
    wave_year,
    wave_description,
    CURRENT_DATE() AS create_date,
    CURRENT_DATE() AS update_date,
    active
FROM dev_catalog.slv_cdm_hrs.dim_wave
WHERE active = TRUE;