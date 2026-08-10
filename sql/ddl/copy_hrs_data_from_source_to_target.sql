-- Copy raw HRS data from source catalog to target catalog
-- Parameters: :source_catalog, :target_catalog
CREATE SCHEMA IF NOT EXISTS IDENTIFIER(CONCAT(:target_catalog, '.brz_raw_hrs'));
CREATE OR REPLACE TABLE IDENTIFIER(
        CONCAT(
            :target_catalog,
            '.brz_raw_hrs.randhrs1992_2022v1'
        )
    ) DEEP CLONE IDENTIFIER(
        CONCAT(
            :source_catalog,
            '.brz_raw_hrs.randhrs1992_2022v1'
        )
    );