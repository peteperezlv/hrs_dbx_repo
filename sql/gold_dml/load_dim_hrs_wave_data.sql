-- Truncate and reload from source
-- Load the data
TRUNCATE TABLE IDENTIFIER(
    CONCAT(
        :catalog_name,
        '.',
        :schema_prefix,
        '.dim_hrs_wave'
    )
);
--
INSERT INTO IDENTIFIER(
        CONCAT(
            :catalog_name,
            '.',
            :schema_prefix,
            '.dim_hrs_wave'
        )
    ) (
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
FROM staging_catalog.slv_cdm_hrs.hrs_wave
WHERE active = TRUE;