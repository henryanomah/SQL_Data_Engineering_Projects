--Step 4: Mart - Create Skills Mart

DROP SCHEMA IF EXISTS skills_mart CASCADE;

CREATE SCHEMA skills_mart;


--dim skills table
SELECT '===Loading Skills Dim for Skills Mart===' AS info;
CREATE OR REPLACE TABLE skills_mart.dim_skills(
    skill_id        INTEGER     PRIMARY KEY,
    skills          VARCHAR,
    type            VARCHAR
);

INSERT INTO skills_mart.dim_skills(
    skill_id,
    skills,
    type 
)
SELECT 
    skill_id,
    skills,
    type 
FROM skills_dim;    


--dim date_month table
SELECT '===Loading Date Dim for Skills Mart===' AS info;
CREATE OR REPLACE TABLE skills_mart.dim_date_month(
    month_start_date        DATE    PRIMARY KEY,
    year                    INTEGER,
    month                   INTEGER,   
    quarter                 INTEGER,
    quarter_name            VARCHAR,
    year_quarter            VARCHAR
);

INSERT INTO skills_mart.dim_date_month(
    month_start_date,
    year,
    month,
    quarter,
    quarter_name,
    year_quarter
)
SELECT DISTINCT
    DATE_TRUNC('month', job_posted_date) AS month_start_date,
    EXTRACT(YEAR FROM job_posted_date) AS year,
    EXTRACT(MONTH FROM job_posted_date) AS month,
    EXTRACT(QUARTER FROM job_posted_date) AS quarter,
    'Q-' || EXTRACT(QUArTER FROM job_posted_date) :: VARCHAR AS quarter_name,
    EXTRACT(YEAR FROM job_posted_date):: VARCHAR ||'-Q' ||
    EXTRACT(QUARTER FROM job_posted_date):: VARCHAR as year_quarter
FROM job_postings_fact
ORDER BY month_start_date;



--fact skill_demanded_monthly table
SELECT '===Loading Skills Fact for Skills Mart===' AS info;
CREATE OR REPLACE TABLE skills_mart.fact_skill_demand_monthly(
    skill_id                          INTEGER,
    month_start_date                  DATE,
    job_title_short                   VARCHAR,
    postings_count                    INTEGER,
    remote_postings_count             INTEGER,
    health_insurance_postings_count   INTEGER,
    no_degree_mention_postings_count  INTEGER,
    PRIMARY KEY(skill_id,month_start_date,job_title_short),
    FOREIGN KEY (skill_id) REFERENCES skills_mart.dim_skills(skill_id),
    FOREIGN KEY (month_start_date) REFERENCES skills_mart.dim_date_month(month_start_date)
);

INSERT INTO skills_mart.fact_skill_demand_monthly(
    skill_id,
    month_start_date,
    job_title_short,
    postings_count,
    remote_postings_count,
    health_insurance_postings_count,
    no_degree_mention_postings_count
)
WITH job_postings_prep AS (
    SELECT 
        sjd.skill_id,
        DATE_TRUNC('month', job_posted_date) AS month_start_date,
        jpf.job_title_short,
        --convert boolean flags (1 or 0)
        CASE WHEN jpf.job_work_from_home = TRUE THEN 1 ELSE 0 END AS is_remote,
        CASE WHEN jpf.job_health_insurance = TRUE THEN 1 ELSE 0 END AS has_health_insurance,
        CASE WHEN jpf.job_no_degree_mention = TRUE THEN 1 ELSE 0 END AS no_degree_mention
    FROM 
        job_postings_fact AS jpf 
    INNER JOIN 
        skills_job_dim AS sjd 
        ON sjd.job_id = jpf.job_id
)
SELECT
    skill_id,
    month_start_date,
    job_title_short,
    COUNT(*) AS postings_count, 
    SUM(is_remote) AS remote_postings_count,
    SUM(has_health_insurance) AS health_insurance_postings_count,
    SUM(no_degree_mention) AS no_degree_mention_postings_count
FROM job_postings_prep
GROUP BY ALL
ORDER BY skill_id, month_start_date , job_title_short;



--COUNT Validation
SELECT 'Skill Dimension' AS table_name , COUNT(*) AS record_count FROM skills_mart.dim_skills
UNION ALL
SELECT 'Date Month Dimension' AS table_name , COUNT(*) AS record_count FROM skills_mart.dim_date_month
UNION ALL
SELECT 'Skill Demand Fact' AS table_name , COUNT(*) AS record_count FROM skills_mart.fact_skill_demand_monthly;


--QUERY Validation

SELECT '=== Skill Dimension Sample ===' AS info;
SELECT * FROM skills_mart.dim_skills LIMIT 5;

SELECT '=== Date Month Dimension Sample ===' AS info;
SELECT * FROM skills_mart.dim_date_month LIMIT 5;

SELECT '=== Skill Demand Sample ===' AS info;
SELECT * FROM skills_mart.fact_skill_demand_monthly LIMIT 5;