DROP TABLE IF EXISTS IDENTIFIER(
    CONCAT(
        :catalog_name,
        '.',
        :schema_prefix,
        '.hub_respondent'
    )
);
DROP TABLE IF EXISTS dev_catalog.slv_cdm_hrs.hub_respondent;
--
CREATE TABLE dev_catalog.slv_cdm_hrs.hub_respondent (
    respondent_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cohort_id BIGINT,
    hhid STRING,
    pn STRING,
    hhidpn BIGINT,
    hacohort INT,
    --
    -- ---------------------------------------------------------------
    -- Respondent demographic invariants (normalized out of fact_demographics)
    -- ---------------------------------------------------------------
    raracem TINYINT COMMENT 'RARACEM: R Race-masked (RAND CATEG variable), Nullable = yes',
    ragender TINYINT COMMENT 'RAGENDER: R Gender-masked (RAND CATEG variable), Nullable = yes',
    rabyear DOUBLE COMMENT 'RABYEAR: R birth year (RAND invariant CONT variable), Nullable = yes',
    rahispan TINYINT COMMENT 'RAHISPAN: R Hispanic (RAND CATEG variable), Nullable = yes',
    raedyrs TINYINT COMMENT 'RAEDYRS: R Years of Education (RAND CATEG variable), Nullable = yes',
    rarelig TINYINT COMMENT 'RARELIG: R Religion (RAND CATEG variable), Nullable = yes',
    ravetrn TINYINT COMMENT 'RAVETRN: R Veteran Status (RAND CATEG variable), Nullable = yes',
    respondent_description STRING,
    create_date DATE,
    update_date DATE,
    active BOOLEAN,
    CONSTRAINT hub_respondent_dim_cohort_fk FOREIGN KEY (cohort_id) REFERENCES dev_catalog.slv_cdm_hrs.dim_cohort(cohort_id)
) USING DELTA COMMENT 'Respondent tracking table';