/*
Question: What are the most in-demand skills for data engineers?
- Join job postings to inner join table similar to query 2
- Identify the top 10 in-demand skills for data engineers
- Focus on remote job postings
- Why? Retrieves the top 10 skills with the highest demand in the remote job market,
    p
*/

SELECT sd.skills, COUNT(jpf.*) AS DE_skills_demand
FROM 
  job_postings_fact AS jpf
INNER JOIN skills_job_dim AS sjd
  ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim AS sd 
  ON sjd.skill_id = sd.skill_id
WHERE jpf.job_title_short = 'Data Engineer'
 AND jpf.job_work_from_home = TRUE   
GROUP BY sd.skills
ORDER BY DE_skills_demand DESC
LIMIT 10;

/*

Breakdown of the most demanded skills for data engineers:
SQL and Python are the most in demand with about ~29000 for each
AWS and Azure follows next with ~17000 and ~14000 respectively
Spark rank  the 5th position with ~12000


Key Takeaways:
-SQL and PYTHON remain the foundational skills of every data enginner
-Cloud Platforms ( AWS and Azure) proved that modern data engineering works are built in the cloud
-Big Data Tools like Spark are highly valued for big data processing
-Data pipelines tools ( Snowfalke and databricks) shows growing demand
-Java and GCP rounds up the top 10 most indemand skills for data engineering


┌────────────┬──────────────────┐
│   skills   │ DE_skills_demand │
│  varchar   │      int64       │
├────────────┼──────────────────┤
│ sql        │            29221 │
│ python     │            28776 │
│ aws        │            17823 │
│ azure      │            14143 │
│ spark      │            12799 │
│ airflow    │             9996 │
│ snowflake  │             8639 │
│ databricks │             8183 │
│ java       │             7267 │
│ gcp        │             6446 │
├────────────┴──────────────────┤
│ 10 rows             2 columns │
└───────────────────────────────┘

/*