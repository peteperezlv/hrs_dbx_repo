-- Verify HRS Cohort-Wave Intersection Data
-- Displays all cohort-wave relationships with descriptive details

SELECT 
    chw.hrs_cohort_wave_id,
    chw.hrs_cohort_id,
    c.hacohort_number,
    c.hacohort_label,
    chw.hrs_wave_id,
    w.wave_number,
    w.wave_year,
    chw.create_date,
    chw.update_date,
    chw.active
FROM dev_catalog.slv_cdm_hrs.hrs_cohort_hrs_wave chw
INNER JOIN dev_catalog.slv_cdm_hrs.hrs_cohort c ON chw.hrs_cohort_id = c.hrs_cohort_id
INNER JOIN dev_catalog.slv_cdm_hrs.hrs_wave w ON chw.hrs_wave_id = w.hrs_wave_id
ORDER BY c.hacohort_number, w.wave_year;

-- Summary count by cohort
SELECT 
    c.hacohort_number,
    c.hacohort_label,
    COUNT(*) as wave_count
FROM dev_catalog.slv_cdm_hrs.hrs_cohort_hrs_wave chw
INNER JOIN dev_catalog.slv_cdm_hrs.hrs_cohort c ON chw.hrs_cohort_id = c.hrs_cohort_id
GROUP BY c.hacohort_number, c.hacohort_label
ORDER BY c.hacohort_number;