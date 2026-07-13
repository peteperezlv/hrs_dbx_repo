-- Load Wave Reference Data from RAND Longitudinal Dataset
-- Creates wave records for each cohort based on cohort participation rules
-- Target: dev_catalog.slv_cdm_hrs.wave
-- wave_id is auto-generated (IDENTITY column)

-- Cohort-to-Wave Mapping (based on hacohort_number):
-- hacohort_number 0, 1, 3: waves 1-16 (all waves)
-- hacohort_number 2, 4: waves 4-16
-- hacohort_number 5: waves 7-16
-- hacohort_number 6: waves 10-16
-- hacohort_number 7: waves 13-16
-- hacohort_number 8: wave 16

INSERT INTO dev_catalog.slv_cdm_hrs.wave (
    cohort_id,
    wave_number,
    wave_year,
    wave_description,
    create_date,
    update_date,
    active
)
WITH wave_numbers AS (
    -- Generate wave numbers 1-16
    SELECT EXPLODE(SEQUENCE(1, 16)) as wave_number
),
cohort_wave_mapping AS (
    -- Cross join cohorts with waves, then filter by participation rules
    SELECT 
        c.cohort_id,
        c.hacohort_number,
        c.hacohort_label,
        w.wave_number
    FROM dev_catalog.slv_cdm_hrs.cohort c
    CROSS JOIN wave_numbers w
    WHERE 
        -- hacohort_number 0, 1, 3: all waves 1-16
        (c.hacohort_number IN (0, 1, 3) AND w.wave_number BETWEEN 1 AND 16)
        -- hacohort_number 2, 4: waves 4-16
        OR (c.hacohort_number IN (2, 4) AND w.wave_number BETWEEN 4 AND 16)
        -- hacohort_number 5: waves 7-16
        OR (c.hacohort_number = 5 AND w.wave_number BETWEEN 7 AND 16)
        -- hacohort_number 6: waves 10-16
        OR (c.hacohort_number = 6 AND w.wave_number BETWEEN 10 AND 16)
        -- hacohort_number 7: waves 13-16
        OR (c.hacohort_number = 7 AND w.wave_number BETWEEN 13 AND 16)
        -- hacohort_number 8: wave 16 only
        OR (c.hacohort_number = 8 AND w.wave_number = 16)
)
SELECT 
    m.cohort_id,
    m.wave_number,
    CASE 
        -- Wave 1 mappings
        WHEN m.wave_number = 1 AND m.hacohort_number = 3 THEN '1992'
        WHEN m.wave_number = 1 AND m.hacohort_number = 0 THEN '1992 (HRS/AHEAD overlaps only)'
        WHEN m.wave_number = 1 AND m.hacohort_number = 1 THEN '1992 (HRS/AHEAD overlaps only)'
        
        -- Wave 2 mappings
        WHEN m.wave_number = 2 AND m.hacohort_number = 3 THEN '1994 (wave 2H)'
        WHEN m.wave_number = 2 AND m.hacohort_number = 0 THEN '1994 (wave 2H)'
        WHEN m.wave_number = 2 AND m.hacohort_number = 1 THEN '1993 (Wave 2A)'
        
        -- Wave 3 mappings
        WHEN m.wave_number = 3 AND m.hacohort_number = 3 THEN '1996 (wave 3H)'
        WHEN m.wave_number = 3 AND m.hacohort_number = 0 THEN '1996 (wave 3H)'
        WHEN m.wave_number = 3 AND m.hacohort_number = 1 THEN '1995 (Wave 3A)'
        
        -- Wave 4 (1998 for cohorts 0,1,2,3,4,5)
        WHEN m.wave_number = 4 THEN '1998'
        
        -- Wave 5 (2000 for cohorts 0,1,2,3,4,5)
        WHEN m.wave_number = 5 THEN '2000'
        
        -- Wave 6 (2002 for cohorts 0,1,2,3,4,5)
        WHEN m.wave_number = 6 THEN '2002'
        
        -- Wave 7 (2004 for cohorts 0,1,2,3,4,5,6)
        WHEN m.wave_number = 7 THEN '2004'
        
        -- Wave 8 (2006 for cohorts 0,1,2,3,4,5,6)
        WHEN m.wave_number = 8 THEN '2006'
        
        -- Wave 9 (2008 for cohorts 0,1,2,3,4,5,6)
        WHEN m.wave_number = 9 THEN '2008'
        
        -- Wave 10 (2010 for cohorts 0,1,2,3,4,5,6,7)
        WHEN m.wave_number = 10 THEN '2010'
        
        -- Wave 11 (2012 for cohorts 0,1,2,3,4,5,6,7)
        WHEN m.wave_number = 11 THEN '2012'
        
        -- Wave 12 (2014 for cohorts 0,1,2,3,4,5,6,7)
        WHEN m.wave_number = 12 THEN '2014'
        
        -- Wave 13 (2016 for cohorts 0,1,2,3,4,5,6,7,8)
        WHEN m.wave_number = 13 THEN '2016'
        
        -- Wave 14 (2018 for cohorts 0,1,2,3,4,5,6,7,8)
        WHEN m.wave_number = 14 THEN '2018'
        
        -- Wave 15 (2020 for cohorts 0,1,2,3,4,5,6,7,8)
        WHEN m.wave_number = 15 THEN '2020'
        
        -- Wave 16 (2022 for cohorts 0,1,2,3,4,5,6,7,8)
        WHEN m.wave_number = 16 THEN '2022'
        
        ELSE CONCAT('Wave ', CAST(m.wave_number AS STRING))
    END as wave_year,
    CONCAT('HRS Interview Wave ', CAST(m.wave_number AS STRING), ', COHORT ', m.hacohort_label) as wave_description,
    CURRENT_DATE() as create_date,
    CURRENT_DATE() as update_date,
    true as active
FROM cohort_wave_mapping m
ORDER BY m.cohort_id, m.wave_number;