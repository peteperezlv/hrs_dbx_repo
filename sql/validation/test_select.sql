--  DESCRIBE TABLE dev_catalog.slv_cdm_hrs.hrs_health
----DESCRIBE TABLE EXTENDED dev_catalog.slv_cdm_hrs.hrs_health;
--DESCRIBE HISTORY dev_catalog.slv_cdm_hrs.hrs_health
select *
from dev_catalog.slv_cdm_hrs.hrs_health
limit 100 --select * from dev_catalog.slv_cdm_hrs.hrs_health
    --version as of 1
    --limit 10;
    /*
     select 
     cohort_id, 
     wave_id, 
     bmi_count, 
     round(bmi_mean, 1) as bmi_mean,
     round(bmi_sd, 1) as bmi_sd,
     min(bmi_min), 
     
     max(bmi_max) 
     from dev_catalog.gld_star_hrs.fact_hrs_bmi_stats as f
     group by f.cohort_id, f.wave_id, bmi_count, bmi_mean, bmi_sd
     order by cohort_id, wave_id
     limit 10
     */
    /*
     select 
     cohort_id, 
     wave_id, 
     sum(bmi_count) as bmi_count, 
     round(SUM(bmi_mean * bmi_count) / SUM(bmi_count), 1) AS true_overall_mean,
     round(SQRT(AVG(POWER(bmi_sd, 2))), 1) AS combined_sd,
     min(bmi_min), 
     max(bmi_max) 
     from dev_catalog.gld_star_hrs.fact_hrs_bmi_race_gender_stats as f
     group by f.cohort_id, f.wave_id
     order by cohort_id, wave_id
     limit 10
     */
    /*
     SELECT 'A1_TABLE_EXISTS' AS test_name,
     CASE
     WHEN COUNT(*) = 1 THEN 'PASS'
     ELSE 'FAIL'
     END AS status,
     CONCAT('Row count found: ', COUNT(*)) AS details
     FROM information_schema.tables
     WHERE table_catalog = 'dev_catalog'
     AND table_schema = 'slv_cdm_hrs'
     AND table_name = 'hrs_demographics';
     */