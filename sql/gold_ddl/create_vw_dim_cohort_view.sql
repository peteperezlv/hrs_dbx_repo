-- Create a view in the gold layer to access the dim_cohort table data.
DROP VIEW IF EXISTS dev_catalog.gld_star_hrs.vw_dim_cohort;
--
CREATE VIEW dev_catalog.gld_star_hrs.vw_dim_cohort AS
SELECT *
FROM dev_catalog.slv_cdm_hrs.dim_cohort;