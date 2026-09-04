-- Load BMI Statistics Fact Table by Race and Gender
-- Calculate descriptive statistics grouped by wave, cohort, and race
TRUNCATE TABLE fact_hrs_bmi_race_gender_stats;
--
INSERT INTO fact_hrs_bmi_race_gender_stats (
        cohort_id,
        wave_id,
        raracem,
        ragender,
        hacohort,
        bmi_count,
        bmi_mean,
        bmi_sd,
        bmi_min,
        bmi_max,
        create_date,
        update_date,
        active
    )
SELECT dc.cohort_id,
    dw.wave_id,
    d.raracem,
    d.ragender,
    r.hacohort,
    -- Not storing individual BMI values, only aggregates
    CAST(COUNT(*) AS INT) AS bmi_count,
    CAST(AVG(h.bmi) AS DOUBLE) AS bmi_mean,
    CAST(STDDEV(h.bmi) AS INT) AS bmi_sd,
    CAST(MIN(h.bmi) AS INT) AS bmi_min,
    CAST(MAX(h.bmi) AS INT) AS bmi_max,
    CURRENT_DATE() AS create_date,
    CURRENT_DATE() AS update_date,
    TRUE AS active
FROM dev_catalog.slv_cdm_hrs.fact_health h
    INNER JOIN dev_catalog.slv_cdm_hrs.hub_respondent r ON h.respondent_id = r.respondent_id
    INNER JOIN dev_catalog.slv_cdm_hrs.fact_demographics d ON h.respondent_id = d.respondent_id
    AND h.wave_id = d.wave_id
    INNER JOIN dev_catalog.gld_star_hrs.dim_hrs_wave dw ON h.wave_id = dw.wave_id
    INNER JOIN dev_catalog.gld_star_hrs.dim_hrs_cohort dc ON r.cohort_id = dc.cohort_id
WHERE h.bmi IS NOT NULL
    AND d.raracem IS NOT NULL
    AND d.ragender IS NOT NULL
    AND h.active = TRUE
    AND r.active = TRUE
    AND d.active = TRUE
GROUP BY dw.wave_id,
    dc.cohort_id,
    d.raracem,
    d.ragender,
    r.hacohort
ORDER BY dw.wave_id,
    dc.cohort_id,
    d.raracem,
    d.ragender;