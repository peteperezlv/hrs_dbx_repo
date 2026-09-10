# HRS Silver CDM Project Overview

---

## 1. Document Information

| Property              | Value                                     |
| --------------------- | ----------------------------------------- |
| Document Name         | HRS Silver CDM Project Overview           |
| Version               | 1.0                                       |
| Author                | Perez                                     |
| AI Assistant          | ChatGPT                                   |
| Last Updated          | 2026-09-10                                |
| Target Platform       | Databricks                                |
| Compute               | Serverless                                |
| Runtime               | client.5.12                               |
| Source Dataset        | RAND HRS Longitudinal                     |
| Source Format         | RAND HRS `.sav` / Delta                   |
| Target Storage Format | Delta                                     |
| Target Data Layer     | Silver CDM                                |
| Primary Purpose       | HRS survey data engineering and analytics |

---

# 2. Project Overview

The HRS Silver CDM project provides a standardized data architecture and development process for transforming the **RAND HRS Longitudinal Dataset** into a structured Silver-layer Common Data Model (CDM) in Databricks.

The project is designed to make it easier to:

- Ingest RAND HRS data.
- Understand the HRS codebook and source variables.
- Organize the data into logical subject areas.
- Create standardized Delta tables.
- Transform the wide longitudinal RAND HRS structure into a respondent-by-wave structure.
- Support SQL-based analytics.
- Support dashboards and data visualizations.
- Add new HRS subject areas using a repeatable process.

The initial subject areas may include:

- Demographics
- Health
- Functional Limitations and Helpers
- Financial and Housing Wealth
- Income
- Social Security
- Pensions
- Health Insurance
- Family Structure
- Retirement Plans and Expectations
- Employment History
- Psycho-Social / Leave-Behind

The architecture is designed so that additional HRS subject areas can be added without redesigning the overall framework.

---

# 3. Project Objective

The primary objective is to create a reusable pipeline that transforms the RAND HRS source dataset into a collection of well-defined Silver CDM Delta tables that can be used for analytics and visualization.

The project separates **table structure** from **data loading logic**.

```text
RAND HRS DATASET
       │
       ▼
SOURCE / BRONZE DATA
       │
       ▼
DDL SPECIFICATION
       │
       ▼
SILVER CDM TABLE
       │
       ▼
DML SPECIFICATION
       │
       ▼
TRANSFORMED DATA
       │
       ▼
VALIDATED SILVER DATA
       │
       ├──────────────► SQL ANALYTICS
       │
       └──────────────► VISUALIZATIONS
```

---

# 4. High-Level Architecture

The project consists of four primary layers:

```text
┌─────────────────────────────────────────────┐
│                RAND HRS SOURCE              │
│                                             │
│ RAND HRS Longitudinal Dataset / Codebook    │
└──────────────────────┬──────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────┐
│                  BRONZE                     │
│                                             │
│ Raw RAND HRS Delta Table                    │
│ dev_catalog.brz_raw_hrs                     │
└──────────────────────┬──────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────┐
│                  SILVER                     │
│                                             │
│ HRS Silver CDM                              │
│                                             │
│ Respondent / Wave / Subject Tables          │
└──────────────────────┬──────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────┐
│                 ANALYTICS                   │
│                                             │
│ SQL Queries / Analysis / Data Products      │
└──────────────────────┬──────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────┐
│              VISUALIZATION                  │
│                                             │
│ Dashboards / Charts / Reports               │
└─────────────────────────────────────────────┘
```

---

# 5. Data Inputs

The project uses two primary sources of information.

## 5.1 RAND HRS Longitudinal Dataset

The RAND HRS Longitudinal Dataset is the primary data source.

The source contains longitudinal survey information collected across multiple HRS waves.

The source is initially represented as a wide dataset in which many variables are associated with individual survey waves.

Example:

```text
HHIDPN
R1AGEY_E
R2AGEY_E
R3AGEY_E
...
R16AGEY_E
```

The Silver CDM transforms this structure into a respondent-by-wave model.

---

## 5.2 RAND HRS Codebook

The RAND HRS Codebook provides the metadata required to correctly interpret the source variables.

The codebook is used to identify:

- Variable names
- Variable labels
- Variable descriptions
- Data types
- Coding schemes
- Missing-value conventions
- Wave applicability
- Subject-area classification
- Variable relationships

The codebook is therefore an important input to the DDL and DML specification process.

---

# 6. Bronze Data Layer

The Bronze layer contains the source RAND HRS data in a Delta representation.

Example source table:

```text
dev_catalog.brz_raw_hrs.randhrs1992_2022v1
```

The Bronze table is intended to preserve the source data as closely as practical.

The Bronze layer should generally not contain business-specific transformations required by the Silver CDM.

Its primary purpose is to provide a reliable source for downstream transformations.

---

# 7. Silver CDM Layer

The Silver layer contains the structured HRS Common Data Model.

Example schema:

```text
dev_catalog.slv_cdm_hrs
```

The Silver layer organizes the RAND HRS data into logical relational tables.

The model uses a respondent-by-wave design for longitudinal subject-area data.

---

# 8. Core Parent Tables

The Silver CDM uses parent tables to provide reusable identifiers.

## 8.1 Respondent

The respondent parent table contains the system-generated respondent identifier.

```text
hub_respondent
```

Primary key:

```text
respondent_id
```

Natural identifier:

```text
HHIDPN
```

The relationship is:

```text
HHIDPN
   │
   ▼
hub_respondent
   │
   ▼
respondent_id
```

`respondent_id` is a system-generated surrogate key.

`HHIDPN` is the natural identifier used to locate the respondent.

---

## 8.2 Wave

The wave parent table contains the system-generated survey-wave identifier.

```text
dim_wave
```

Primary key:

```text
wave_id
```

Natural identifier:

```text
wave_number
```

The relationship is:

```text
wave_number
     │
     ▼
 dim_wave
     │
     ▼
  wave_id
```

`wave_id` is a system-generated surrogate key.

`wave_number` is the natural identifier used to locate the survey wave.

---

# 9. Subject-Area Tables

Subject-area tables contain the actual HRS survey attributes.

Examples:

```text
fact_demographics
fact_health
fact_financial
fact_income
fact_employment
```

The actual table naming convention should be defined by the project's applicable DDL specification.

A subject-area table generally contains:

```text
subject_table
│
├── system-generated primary key
├── respondent_id
├── wave_id
├── natural identifiers where required
├── subject-area attributes
└── audit columns
```

---

# 10. Respondent-by-Wave Grain

The standard longitudinal grain is:

> **One row per respondent per survey wave.**

The logical business key is:

```text
respondent_id + wave_id
```

This design allows subject-area attributes to be analyzed across survey waves.

For example:

```text
respondent_id   wave_id   agey_e   mstat   cenreg
--------------------------------------------------
1001            1         65       ...     ...
1001            2         67       ...     ...
1001            3         69       ...     ...
```

The system-generated primary key is separate from the business grain.

---

# 11. Natural Identifiers and Surrogate Keys

The architecture intentionally separates natural identifiers from system-generated surrogate keys.

| Purpose     | Natural Identifier | Surrogate Key |
| ----------- | ------------------ | ------------- |
| Respondent  | HHIDPN             | respondent_id |
| Survey Wave | wave_number        | wave_id       |

The DML process uses the natural identifiers to resolve the appropriate surrogate keys.

The DML must not create or modify the surrogate key values.

---

# 12. DDL and DML Architecture

The project uses two complementary specifications.

## 12.1 DDL Specification

The DDL specification answers:

> **What does the target table look like?**

It defines:

- Table name
- Catalog
- Schema
- Columns
- Data types
- Nullability
- Primary key
- Foreign keys
- Identity columns
- Constraints
- Comments
- Storage format
- Table type

The DDL generates the physical Delta table.

---

## 12.2 DML Specification

The DML specification answers:

> **How is the target table populated correctly?**

It defines:

- Source variables
- Target columns
- Natural identifier lookups
- Transformations
- Wave mappings
- Wide-to-long transformations
- Missing-value rules
- Type conversions
- Audit values
- Load pattern
- Validation rules

The DML populates the table created by the DDL.

---

# 13. DDL-to-DML Relationship

The relationship between the two specifications is:

```text
             DDL SPECIFICATION
                    │
                    ▼
             CREATE TABLE
                    │
                    ▼
            SILVER CDM TABLE
                    │
                    ▼
             DML SPECIFICATION
                    │
                    ▼
           TRANSFORM SOURCE DATA
                    │
                    ▼
             LOAD TARGET TABLE
```

The DML specification should reference the approved DDL specification rather than redefining the target table.

---

# 14. Project Documentation Architecture

The project uses several complementary documents.

```text
HRS PROJECT OVERVIEW
        │
        ▼
HRS DDL_DML TEMPLATE ARCHITECTURE
        │
        ├─────────────────────┐
        ▼                     ▼
DDL WORKFLOW             DML WORKFLOW
        │                     │
        ▼                     ▼
DDL MASTER TEMPLATE      DML MASTER TEMPLATE
        │                     │
        ▼                     ▼
Subject DDL              Subject DML
Specification            Specification
        │                     │
        ▼                     ▼
Generated DDL            Generated DML
```

Each document has a different purpose.

---

# 15. Project Artifacts

## 15.1 Project Overview

This document.

Purpose:

> Provide a high-level introduction to the project and explain how the major components fit together.

This should be the first document a new user reads.

---

## 15.2 Architecture Document

Purpose:

> Explain the overall DDL/DML architecture and how the specifications, generated SQL, tables, and workflows relate to each other.

---

## 15.3 DDL Master Template

Purpose:

> Provide the standardized template used to define the physical Silver CDM table.

Example:

```text
HRS_DDL_Master_Template.ipynb
```

---

## 15.4 DML Master Template

Purpose:

> Provide the standardized template used to define how source RAND HRS data is transformed and loaded into a Silver CDM table.

Example:

```text
HRS_DML_Master_Template.ipynb
```

---

## 15.5 DDL Specification

A subject-specific specification created from the DDL Master Template.

Example:

```text
HRS Demographics DDL Specification
```

---

## 15.6 DML Specification

A subject-specific specification created from the DML Master Template.

Example:

```text
HRS Demographics DML Specification
```

---

## 15.7 Generated SQL

The final SQL generated from the specifications.

Example:

```text
/sql/ddl/create_fact_demographics.sql
```

DML files would follow the project's established DML naming convention.

---

# 16. Standard Subject-Area Development Process

Each new HRS subject area follows the same general process.

```text
1. Identify Subject Area
          │
          ▼
2. Review RAND HRS Codebook
          │
          ▼
3. Identify Source Variables
          │
          ▼
4. Define Target Data Model
          │
          ▼
5. Create DDL Specification
          │
          ▼
6. Generate DDL
          │
          ▼
7. Create Delta Table
          │
          ▼
8. Validate Table
          │
          ▼
9. Create DML Specification
          │
          ▼
10. Generate DML
          │
          ▼
11. Test Transformations
          │
          ▼
12. Load Data
          │
          ▼
13. Validate Data
          │
          ▼
14. Approve Subject Area
```

---

# 17. Step-by-Step: Adding a New HRS Category

This section provides the recommended starting point when adding a new subject area.

## Step 1 — Select the HRS Category

Choose the subject area to be developed.

Examples:

```text
Demographics
Health
Income
Employment
Family Structure
Pensions
```

---

## Step 2 — Review the RAND HRS Codebook

Identify the variables associated with the selected subject area.

Document:

- Variable name
- Label
- Description
- RAND type
- Wave
- Coding
- Missing values

---

## Step 3 — Define the Target Table

Determine:

- Target table name
- Target columns
- Data types
- Nullable columns
- Primary key
- Foreign keys
- Audit columns
- Business grain

The default longitudinal grain is:

```text
One respondent per wave
```

---

## Step 4 — Create the DDL Specification

Use:

```text
HRS_DDL_Master_Template.ipynb
```

Complete the subject-area DDL specification.

The specification defines the physical target table.

---

## Step 5 — Review and Approve the DDL Specification

Conduct a requirements walkthrough.

Confirm that:

- Required variables are included.
- Data types are correct.
- Relationships are correct.
- Keys are correct.
- Business grain is correct.
- Naming conventions are correct.

---

## Step 6 — Generate the DDL

Provide the approved DDL specification to the AI Assistant.

The AI Assistant generates the Databricks SQL DDL.

The generated DDL should contain only the required DDL statements.

---

## Step 7 — Execute the DDL

Execute the generated DDL in Databricks.

The result should be a managed Delta table in the Silver schema.

---

## Step 8 — Validate the Delta Table

Confirm:

- Table exists.
- Correct catalog.
- Correct schema.
- Correct table name.
- Delta format.
- Managed table.
- Correct columns.
- Correct data types.
- Correct constraints.
- Correct identity column.
- Correct parent-table relationships.

Only after successful validation should DML development begin.

---

# 18. DML Development Process

Once the target table has been approved, begin the DML process.

Use:

```text
HRS_DML_Master_Template.ipynb
```

Define:

- Source variables
- Target mappings
- Respondent lookup
- Wave lookup
- Transformations
- Wide-to-long logic
- Missing-value rules
- Audit rules
- Load pattern
- Validation rules

---

# 19. RAND HRS Wide-to-Long Transformation

One of the most important transformations in the project is converting the longitudinal RAND HRS source structure into the Silver CDM respondent-by-wave structure.

For example:

```text
RAND HRS

HHIDPN | R1AGEY_E | R2AGEY_E | R3AGEY_E
-------|----------|----------|----------
12345  | 65       | 67       | 69
```

becomes conceptually:

```text
Silver CDM

HHIDPN | wave_number | agey_e
-------|-------------|-------
12345  | 1           | 65
12345  | 2           | 67
12345  | 3           | 69
```

The DML specification documents how this transformation is performed.

---

# 20. Analytics Layer

Once Silver CDM tables have been validated, they become the primary source for analytical SQL.

Examples include:

```text
Respondent demographics
Age by survey wave
Health trends
Income trends
Employment history
Retirement behavior
Wealth analysis
Cross-subject analysis
```

Analytics should generally use the Silver CDM rather than directly querying the raw RAND HRS source.

This provides a consistent and reusable analytical foundation.

---

# 21. Visualization Layer

Validated Silver CDM data can also support dashboards and visualizations.

Typical workflow:

```text
Silver CDM
    │
    ▼
SQL Query
    │
    ▼
Analytical Dataset
    │
    ▼
Visualization
    │
    ▼
Dashboard / Report
```

Examples include:

- Line charts showing changes across waves.
- Bar charts comparing demographic groups.
- Health trends by age.
- Income distributions.
- Retirement trends.
- Cross-sectional and longitudinal comparisons.

The visualization layer should consume validated analytical data rather than raw source variables whenever possible.

---

# 22. Quality and Validation Philosophy

The project uses multiple validation stages.

```text
SOURCE VALIDATION
       │
       ▼
DDL VALIDATION
       │
       ▼
DML VALIDATION
       │
       ▼
DATA VALIDATION
       │
       ▼
RECONCILIATION
       │
       ▼
ANALYTICS VALIDATION
```

A successful SQL execution does not necessarily mean the data is correct.

Validation should confirm both:

1. **Technical correctness**
2. **Business correctness**

---

# 23. AI-Assisted Development

AI is used as a development assistant rather than as the source of business requirements.

The recommended process is:

```text
USER DEFINES REQUIREMENTS
          │
          ▼
USER CREATES SPECIFICATION
          │
          ▼
AI GENERATES SQL
          │
          ▼
USER REVIEWS SQL
          │
          ▼
DATABRICKS EXECUTES SQL
          │
          ▼
USER VALIDATES RESULTS
```

The AI Assistant should not invent:

- Source variables
- Business rules
- Transformations
- Relationships
- Missing-value interpretations
- Target columns
- Constraints

when those items are not defined by the applicable specification.

The specification is the authoritative source of requirements.

---

# 24. Recommended Development Sequence

For a new developer or analyst joining the project, the recommended reading and development order is:

```text
1. HRS Silver CDM Project Overview
                │
                ▼
2. HRS DDL_DML Template Architecture
                │
                ▼
3. HRS Silver CDM DDL Workflow
                │
                ▼
4. HRS DDL Master Template
                │
                ▼
5. Subject-Area DDL Specification
                │
                ▼
6. Generated DDL
                │
                ▼
7. HRS Silver CDM DML Workflow
                │
                ▼
8. HRS DML Master Template
                │
                ▼
9. Subject-Area DML Specification
                │
                ▼
10. Generated DML
                │
                ▼
11. Validation / Testing
                │
                ▼
12. Analytics / Visualization
```

---

# 25. Getting Started Checklist

A new user can use the following checklist to begin work.

### Understand the Project

- [ ] Read this Project Overview.
- [ ] Understand Bronze and Silver layers.
- [ ] Understand respondent and wave parent tables.
- [ ] Understand respondent-by-wave grain.
- [ ] Understand natural identifiers and surrogate keys.

### Understand the Templates

- [ ] Read the DDL/DML Architecture document.
- [ ] Review the DDL Master Template.
- [ ] Review the DML Master Template.
- [ ] Review the DDL Workflow.
- [ ] Review the DML Workflow.

### Build a New Subject Area

- [ ] Select the HRS category.
- [ ] Review the RAND HRS Codebook.
- [ ] Identify source variables.
- [ ] Define target columns.
- [ ] Define target grain.
- [ ] Create DDL specification.
- [ ] Review DDL specification.
- [ ] Generate DDL.
- [ ] Create Delta table.
- [ ] Validate Delta table.
- [ ] Create DML specification.
- [ ] Review DML specification.
- [ ] Generate DML.
- [ ] Test transformations.
- [ ] Load the target table.
- [ ] Validate loaded data.
- [ ] Reconcile source and target.
- [ ] Approve the subject area.

---

# 26. Expansion Roadmap

The architecture is intended to support incremental expansion.

A recommended development sequence is:

```text
                HRS SILVER CDM
                      │
        ┌─────────────┼─────────────┐
        ▼             ▼             ▼
   Demographics     Health      Employment
        │             │             │
        ▼             ▼             ▼
     Income        Pensions     Insurance
        │             │             │
        └─────────────┼─────────────┘
                      ▼
              Integrated HRS CDM
                      │
                      ▼
                 Analytics
                      │
                      ▼
              Visualizations
```

Each category should be developed independently using the same DDL/DML methodology.

This allows the project to grow from a single subject area into a comprehensive HRS analytical data model.

---

# 27. Final Project Concept

The HRS Silver CDM project can be summarized as:

```text
                 RAND HRS
                    │
                    ▼
              BRONZE DELTA
                    │
                    ▼
          DDL SPECIFICATION
                    │
                    ▼
           SILVER CDM TABLE
                    │
                    ▼
          DML SPECIFICATION
                    │
                    ▼
        TRANSFORMED HRS DATA
                    │
                    ▼
          VALIDATED SILVER
                    │
             ┌──────┴──────┐
             ▼             ▼
          SQL DATA     VISUALIZATIONS
          ANALYTICS
```

The overall goal is to create a **repeatable, documented, and scalable process** for converting the RAND HRS longitudinal dataset into a structured Silver CDM that can support reliable research, analytics, and visualization.

The combination of:

- RAND HRS data,
- RAND HRS Codebook,
- standardized DDL specifications,
- standardized DML specifications,
- reusable SQL templates,
- Databricks Delta tables,
- validation workflows, and
- analytical SQL

provides the foundation for expanding the HRS Silver CDM across all major HRS subject areas.
