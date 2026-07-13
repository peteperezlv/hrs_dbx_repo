-- Verify Wave Reference Data
-- Displays all records in the wave reference table

SELECT 
    wave_id,
    wave_number,
    wave_year,
    wave_description,
    start_date,
    end_date,
    active
FROM dev_catalog.slv_cdm_hrs.wave
ORDER BY wave_number;