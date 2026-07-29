-- Load Wave Reference Data
-- Target: dev_catalog.slv_cdm_hrs.hrs_wave
-- hrs_wave_id is auto-generated (IDENTITY column)

INSERT INTO dev_catalog.slv_cdm_hrs.hrs_survey_wave (
    wave_number,
    wave_year,
    wave_description,
    create_date,
    update_date,
    active
)
VALUES
    ('1', '1992', 'Wave Number 1, Year 1992', CURRENT_DATE(), CURRENT_DATE(), true),
    ('2', '1993', 'Wave Number 2, Year 1993 and 1994', CURRENT_DATE(), CURRENT_DATE(), true),
    ('3', '1995', 'Wave Number 3a, Year 1995 and 1996', CURRENT_DATE(), CURRENT_DATE(), true),
    ('4', '1998', 'Wave Number 4, Year 1998', CURRENT_DATE(), CURRENT_DATE(), true),
    ('5', '2000', 'Wave Number 5, Year 2000', CURRENT_DATE(), CURRENT_DATE(), true),
    ('6', '2002', 'Wave Number 6, Year 2002', CURRENT_DATE(), CURRENT_DATE(), true),
    ('7', '2004', 'Wave Number 7, Year 2004', CURRENT_DATE(), CURRENT_DATE(), true),
    ('8', '2006', 'Wave Number 8, Year 2006', CURRENT_DATE(), CURRENT_DATE(), true),
    ('9', '2008', 'Wave Number 9, Year 2008', CURRENT_DATE(), CURRENT_DATE(), true),
    ('10', '2010', 'Wave Number 10, Year 2010', CURRENT_DATE(), CURRENT_DATE(), true),
    ('11', '2012', 'Wave Number 11, Year 2012', CURRENT_DATE(), CURRENT_DATE(), true),
    ('12', '2014', 'Wave Number 12, Year 2014', CURRENT_DATE(), CURRENT_DATE(), true),
    ('13', '2016', 'Wave Number 13, Year 2016', CURRENT_DATE(), CURRENT_DATE(), true),
    ('14', '2018', 'Wave Number 14, Year 2018', CURRENT_DATE(), CURRENT_DATE(), true),
    ('15', '2020', 'Wave Number 15, Year 2020', CURRENT_DATE(), CURRENT_DATE(), true),
    ('16', '2022', 'Wave Number 16, Year 2022', CURRENT_DATE(), CURRENT_DATE(), true),
    ('A', 'all', 'Wave Number A, All Years', CURRENT_DATE(), CURRENT_DATE(), true),
    ('E', 'exit', 'Wave Number E, Exit', CURRENT_DATE(), CURRENT_DATE(), true);