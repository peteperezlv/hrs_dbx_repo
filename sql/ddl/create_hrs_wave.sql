DROP TABLE IF EXISTS IDENTIFIER(
    CONCAT(
        :catalog_name,
        '.',
        :schema_prefix,
        '.hrs_wave'
    )
);
CREATE TABLE IDENTIFIER(
    CONCAT(
        :catalog_name,
        '.',
        :schema_prefix,
        '.hrs_wave'
    )
) (
    wave_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    wave_number STRING,
    wave_year STRING,
    wave_description STRING,
    create_date DATE,
    update_date DATE,
    active BOOLEAN
) USING DELTA COMMENT 'Wave tracking table';