-- Verify HRS Wave Reference Data
-- Displays all records in the hrs_wave reference table
-- coment

SELECT 
    hrs_wave_id,
    wave_number,
    wave_year,
    wave_description,
    create_date,
    update_date,
    active
FROM dev_catalog.slv_cdm_hrs.hrs_wave
ORDER BY wave_year, wave_number;