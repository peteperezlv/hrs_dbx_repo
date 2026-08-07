-- Load Cohort Reference Data from RAND Longitudinal Dataset
-- Source: dev_catalog.brz_raw_hrs.randhrs1992_2022v1
-- Target: dev_catalog.slv_cdm_hrs.cohort
-- cohort_id is auto-generated (IDENTITY column)

INSERT INTO dev_catalog.slv_cdm_hrs.hrs_cohort (
    hacohort_number,
    hacohort_label,
    hacohort_description,
    create_date,
    update_date,
    active
)
SELECT DISTINCT
    CAST(HACOHORT AS INT) as hacohort_number,
    CASE 
        WHEN CAST(HACOHORT AS INT) = 0 THEN '0-HRS/AHEAD'
        WHEN CAST(HACOHORT AS INT) = 1 THEN '1-HRS/AHEAD'
        WHEN CAST(HACOHORT AS INT) = 2 THEN 'CODA'
        WHEN CAST(HACOHORT AS INT) = 3 THEN 'HRS'
        WHEN CAST(HACOHORT AS INT) = 4 THEN 'WB'
        WHEN CAST(HACOHORT AS INT) = 5 THEN 'EBB'
        WHEN CAST(HACOHORT AS INT) = 6 THEN 'MBB'
        WHEN CAST(HACOHORT AS INT) = 7 THEN 'LBB'
        WHEN CAST(HACOHORT AS INT) = 8 THEN 'EGENX'
    END as hacohort_label,
    CASE 
        WHEN CAST(HACOHORT AS INT) = 0 THEN 'HRS/AHEAD overlap'
        WHEN CAST(HACOHORT AS INT) = 1 THEN 'HRS/AHEAD overlap, born before 1924, initially a separate study (The Study of Assets and Health Dynamics Among the Oldest Old). This cohort was first interviewed in 1993 and subsequently in 1995, 1998, and subsequently every two years.'
        WHEN CAST(HACOHORT AS INT) = 2 THEN 'CODA (Children of the Depression Age).  Children of Depression (CODA) cohort, born 1924 to 1930. This cohort was first interviewed in 1998 and subsequently every two
years.'
        WHEN CAST(HACOHORT AS INT) = 3 THEN 'Initial HRS cohort, born 1931 to 1941. This cohort was first interviewed in 1992 and subsequently every two years.'
        WHEN CAST(HACOHORT AS INT) = 4 THEN 'WB (War Baby). War Baby (WB) cohort, born 1942 to 1947. This cohort was also first interviewed in 1998 and subsequently every two years.'
        WHEN CAST(HACOHORT AS INT) = 5 THEN 'EBB (Early Baby Boomer). Early Baby Boomer (EBB) cohort, born 1948 to 1953. This cohort was first interviewed in 2004.'
        WHEN CAST(HACOHORT AS INT) = 6 THEN 'MBB (Mid Baby Boomer). MidBaby Boomer (MBB) cohort, born 1954 to 1959. This cohort was first interviewed in 2010.'
        WHEN CAST(HACOHORT AS INT) = 7 THEN 'LBB (Late Baby Boomer). Late Baby Boomer (LBB) cohort, born 1960 to 1965. This cohort was first interviewed in 2016.'
        WHEN CAST(HACOHORT AS INT) = 8 THEN 'EGENX (Early Generation X). Early Generation X (EGENX) cohort, born 1966 to 1971. This cohort was first interviewed in 2022.'
    END as hacohort_description,
    CURRENT_DATE() as create_date,
    CURRENT_DATE() as update_date,
    true as active
FROM dev_catalog.brz_raw_hrs.randhrs1992_2022v1
WHERE HACOHORT IS NOT NULL
ORDER BY hacohort_number;