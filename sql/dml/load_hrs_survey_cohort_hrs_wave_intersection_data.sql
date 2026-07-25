-- Load HRS Cohort-Wave Intersection Data
-- Target: dev_catalog.slv_cdm_hrs.hrs_cohort_hrs_wave
-- Populates the many-to-many relationship between cohorts and waves
-- Based on participation matrix showing which cohorts participated in which waves

INSERT INTO dev_catalog.slv_cdm_hrs.hrs_cohort_hrs_wave (
    hrs_cohort_id,
    hrs_wave_id,
    create_date,
    update_date,
    active
)
WITH cohort_wave_participation AS (
    -- Define the participation matrix: wave_number and hacohort_number combinations
    SELECT * FROM VALUES
        ('1', 3), ('1', 0), ('1', 1),
        ('2a', 0), ('2a', 1),
        ('2h', 3),
        ('3a', 0), ('3a', 1),
        ('3h', 3),
        ('4', 3), ('4', 0), ('4', 1), ('4', 2), ('4', 4),
        ('5', 3), ('5', 0), ('5', 1), ('5', 2), ('5', 4),
        ('6', 3), ('6', 0), ('6', 1), ('6', 2), ('6', 4),
        ('7', 3), ('7', 0), ('7', 1), ('7', 2), ('7', 4), ('7', 5),
        ('8', 3), ('8', 0), ('8', 1), ('8', 2), ('8', 4), ('8', 5),
        ('9', 3), ('9', 0), ('9', 1), ('9', 2), ('9', 4), ('9', 5),
        ('10', 3), ('10', 0), ('10', 1), ('10', 2), ('10', 4), ('10', 5), ('10', 6),
        ('11', 3), ('11', 0), ('11', 1), ('11', 2), ('11', 4), ('11', 5), ('11', 6),
        ('12', 3), ('12', 0), ('12', 1), ('12', 2), ('12', 4), ('12', 5), ('12', 6),
        ('13', 3), ('13', 0), ('13', 1), ('13', 2), ('13', 4), ('13', 5), ('13', 6), ('13', 7),
        ('14', 3), ('14', 0), ('14', 1), ('14', 2), ('14', 4), ('14', 5), ('14', 6), ('14', 7),
        ('15', 3), ('15', 0), ('15', 1), ('15', 2), ('15', 4), ('15', 5), ('15', 6), ('15', 7),
        ('16', 3), ('16', 0), ('16', 1), ('16', 2), ('16', 4), ('16', 5), ('16', 6), ('16', 7), ('16', 8)
    AS t(wave_number, hacohort_number)
)
SELECT 
    c.hrs_cohort_id,
    w.hrs_wave_id,
    CURRENT_DATE() as create_date,
    CURRENT_DATE() as update_date,
    true as active
FROM cohort_wave_participation cwp
INNER JOIN dev_catalog.slv_cdm_hrs.hrs_cohort c ON cwp.hacohort_number = c.hacohort_number
INNER JOIN dev_catalog.slv_cdm_hrs.hrs_wave w ON cwp.wave_number = w.wave_number
ORDER BY c.hacohort_number, w.wave_number;