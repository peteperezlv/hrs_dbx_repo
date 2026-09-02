-- Verify HRS Wave Reference Data
-- Displays all records in the hrs_wave reference table
-- coment
SELECT wave_id,
    wave_number,
    wave_year,
    wave_description,
    create_date,
    update_date,
    active
FROM dev_catalog.slv_cdm_hrs.dim_wave
ORDER BY wave_year,
    wave_number;