-- =====================================================================
-- HRS GOLD Star Data Model DDL – Wave Dimension View
--
-- Target View: dev_catalog.gld_star_hrs.dim_hrs_wave
--
-- Source Table: dev_catalog.slv_cdm_hrs.dim_wave
--
-- Purpose: Gold-layer passthrough view over the Silver CDM wave
--          dimension.  Provides the wave dimension in the gold star
--          schema without duplicating silver data.
--
-- AI Assistant: Genie Code (Databricks)
--
-- Databricks Runtime: 15.x | SQL Dialect: Spark SQL | Storage: Delta Lake
--
-- =====================================================================
--
CREATE OR REPLACE VIEW dev_catalog.gld_star_hrs.vw_dim_hrs_wave
COMMENT 'Gold view over Silver CDM wave dimension (dev_catalog.slv_cdm_hrs.dim_wave)'
AS SELECT
    wave_id,
    wave_number,
    wave_year,
    wave_description,
    create_date,
    update_date,
    active
FROM dev_catalog.slv_cdm_hrs.dim_wave;
