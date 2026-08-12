-- Load BMI Statistics Fact Table
-- Calculate descriptive statistics grouped by wave and cohort
TRUNCATE TABLE dev_catalog.gld_star_hrs.fact_hrs_bmi_stats;
--
INSERT INTO dev_catalog.gld_star_hrs.fact_hrs_bmi_stats TRUNCATE TABLE IDENTIFIER(
        CONCAT(
            :catalog_name,
            '.',
            :schema_prefix,
            '.fact_hrs_bmi_stats'
        )
    );
--
INSERT INTO IDENTIFIER(
        CONCAT(
            :catalog_name,
            '.',
            :schema_prefix,
            '.fact_hrs_bmi_stats'
        )
    ) (
        cohort_id,
        wave_id,
        hacohort,
        bmi,
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
    r.hacohort,
    NULL AS bmi,
    -- Not storing individual BMI values, only aggregates
    CAST(COUNT(*) AS INT) AS bmi_count,
    CAST(AVG(h.bmi) AS INT) AS bmi_mean,
    CAST(STDDEV(h.bmi) AS INT) AS bmi_sd,
    CAST(MIN(h.bmi) AS INT) AS bmi_min,
    CAST(MAX(h.bmi) AS INT) AS bmi_max,
    CURRENT_DATE() AS create_date,
    CURRENT_DATE() AS update_date,
    TRUE AS active
FROM dev_catalog.slv_cdm_hrs.hrs_health h
    INNER JOIN dev_catalog.slv_cdm_hrs.hrs_respondent r ON h.respondent_id = r.respondent_id
    INNER JOIN dev_catalog.gld_star_hrs.dim_hrs_wave dw ON h.wave_id = dw.wave_id
    INNER JOIN dev_catalog.gld_star_hrs.dim_hrs_cohort dc ON r.cohort_id = dc.cohort_id
WHERE h.bmi IS NOT NULL
    AND h.active = TRUE
    AND r.active = TRUE
GROUP BY dw.wave_id,
    dc.cohort_id,
    r.hacohort
ORDER BY dw.wave_id,
    dc.cohort_id;