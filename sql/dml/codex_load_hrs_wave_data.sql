-- Load the supported RAND HRS survey waves.
-- Wave numbers are derived from the source variable wave prefixes R1...R16.
WITH source_waves AS
(
    SELECT wave_number
    FROM VALUES
        ('1'),
        ('2'),
        ('3'),
        ('4'),
        ('5'),
        ('6'),
        ('7'),
        ('8'),
        ('9'),
        ('10'),
        ('11'),
        ('12'),
        ('13'),
        ('14'),
        ('15'),
        ('16') AS waves(wave_number)
)
INSERT INTO dev_catalog.slv_cdm_hrs.codex_dim_wave
(
    wave_number,
    create_date,
    update_date,
    active
)
SELECT s.wave_number,
    CURRENT_DATE() AS create_date,
    CURRENT_DATE() AS update_date,
    TRUE AS active
FROM source_waves s
WHERE NOT EXISTS
(
    SELECT 1
    FROM dev_catalog.slv_cdm_hrs.codex_dim_wave t
    WHERE t.wave_number = s.wave_number
);
