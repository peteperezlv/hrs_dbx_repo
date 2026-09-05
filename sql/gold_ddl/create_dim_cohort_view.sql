DROP VIEW IF EXISTS dev_catalog.gld_star_hrs.dim_cohort;
CREATE VIEW dev_catalog.gld_star_hrs.dim_cohort AS
SELECT *
FROM silver.dim_cohort;