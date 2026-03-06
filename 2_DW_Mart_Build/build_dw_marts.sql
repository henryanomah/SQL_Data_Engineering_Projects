--duckdb dw_marts.duckdb -c ".read build_dw_marts.sql"

-- Step 1: DW - Create star schema tables
.read 01_create_tables_dw.sql 

--Step 2: Dw - Load data from csv files into tables
.read 02_load_schema_dw.sql 

--Step 2: Mart - Create Flat Mart

.read 03_create_flat_mart.sql

--STep 4: Mart - Create skills demand mart
.read 04_create_skills_mart.sql