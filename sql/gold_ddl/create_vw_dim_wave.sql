-- Create a view in the gold layer to access the dim_wave table data.
-- Do this instead of creating a speparate dimension table.
DROP VIEW IF EXISTS dev_catalog.gld_star_hrs.vw_dim_wave;
--
CREATE VIEW dev_catalog.gld_star_hrs.vw_dim_wave AS
SELECT *
FROM dev_catalog.slv_cdm_hrs.dim_wave;