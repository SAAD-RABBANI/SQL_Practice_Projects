# Introduction
Dive into the data job market. Focusing on data analyst and business analyst roles, this explores top-paying jobs, in-demand skills, and where high demand meets high salary in data analytics.
# Background
Driven by a quest to navigate the data analyst job market more effectively, this project was born from a desire to pinpoint top-paid and in-demand skills, streamlining others work to find optimal jobs.

Data is taken from [SQL_Course](https://lukebarousse.com/sql). Its packed with insights on job titles, salaries, locations, and essential skills.

### The questions i answered through the SQL queries were:

1. What are the top-paying data / business analyst jobs?
2. What skills are required for these top-paying jobs?
3. What skills are most in demand for data / business analysts?
4. Which skills are associated with higher salaries?
5. What are the top optimal skills to learn?

# Tools I Used
For the deep dive into the data / business analyst job market, i harnessed the power of several key tools:

- **SQL**: The backbone of my analysis, allowing me to query the database and unearth critical insights.
- **PostgreSQL**: The chosen database management system, ideal for handling the job posting data and executing SQL queries.
  
# The Analysis
Each query for this project aimed at investigating specific aspects of the data / business analyst job market.
Here's how i approach each question:

### 1. Top Paying Data Analyst Job.
To identify the highest-paying roles, i filtered data analyst positions by average yearly salary and location, focusting on remote jobs. This query highlights the paying opportunities in the field.
```sql
SELECT 
	job_id,
	job_title,
	company_dim.name AS company_name,
	job_location,
	job_schedule_type,
	salary_year_avg,
	job_posted_date
FROM
	job_postings_fact
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE 
	job_title_short IN ('Data Analyst','Business Analyst') AND
	job_location = 'Anywhere' AND
	salary_year_avg IS NOT NULL
ORDER BY
	salary_year_avg DESC
LIMIT 10;
```
Here is the breakdown of the top data analyst jobs in 2023:
- **Wide Salary Range:** Top 10 paying data analyst role span from $184,000 to $650,000, indicating significant salary potential in the field.
- **Diverse Employers:** Companies like SmartAsset, Meta, and AT&T are among those offering high salaries, showing a broad interest across different industries.
- **Job Title Variety:** There is a high diversity in job titles, from Data Analyst to Director of Data Analytics, reflecting varied roles and specifications within data analytics.
  
### 2. Skills for Top Paying Jobs
To understand waht skills are required for the top_paying jobs, i joined the job postings with the skills data, providing insights into what employers value for high-compensation roles.
```sql
WITH top_paying_jobs AS (
	SELECT 
		job_id,
		job_title,
		company_dim.name AS company_name,
		job_location,
		job_schedule_type,
		salary_year_avg,
		job_posted_date
	FROM
		job_postings_fact
	LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
	WHERE 
		job_title_short = 'Data Analyst' AND
		job_location = 'Anywhere' AND
		salary_year_avg IS NOT NULL
	ORDER BY
		salary_year_avg DESC
	LIMIT 10
)

SELECT 
	top_paying_jobs.*,
	skills
FROM 
	top_paying_jobs
INNER JOIN skills_job_dim ON top_paying_jobs.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
ORDER BY 
	salary_year_avg DESC;
```
Here is the breakdown of the most demanded skills for the top 10 highest paying data analyst job in 2023:

- **SQL** is leading with a bold count of 8.
- **Python** follows closely with a bold count of 7.
- **Tableau** is also highly sought after, with a bold count of 6. Other skills like **R, Snowflake, Panda,** and **Excel** show varing degrees of demand.

### 3. In-Demand Skills for Data Analysts
This query helped identify the skills most freques=ntly requested in job postings, directing focus to areas with high demand.
```sql
SELECT 
	skills,
	COUNT(skills_job_dim.job_id) AS demand_count
FROM 
	job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE job_title_short = 'Business Analyst'
GROUP BY 
	skills
ORDER BY
	demand_count DESC
LIMIT 5
```
| Skills    | Demand Count |
|-----------|--------------|
| SQL       | 17372        |
| Excel     | 17134        |
| Python    | 9324         |
| Tableau   | 9251         |
| Power BI  | 8097         |

*Table of the demand for the Top 5 skills in Business Analyst job postings*

Here's the breakdown of the most demanded skills for data analysts in 2023:
- **SQL** and **Excel** remain fundamental, emphasizing the need for strong foundational skills in data processing and spreadsheet manipulation.
- **Programming** and **Visualization Tools** like **Python, Tableau,** and **Power BI** are essential, pointing towards the increasing importance of the technical skills in data storytelling and decision support.

### 4. Skills Based on Salary
Exploring the average salaries associated with different skills revealed which skills are the highest paying.
```sql
SELECT 
	skills,
	ROUND(AVG(salary_year_avg), 0) AS avg_salary
FROM 
	job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE job_title_short = 'Business Analyst' 
	  AND salary_year_avg IS NOT NULL
GROUP BY 
	skills
ORDER BY
	avg_salary DESC
LIMIT 20
```
| Skills    | Average Salary ($) |
|-----------|--------------------|
| Chef      | 220,000            |
| Numpy     | 157,500            |    
| Ruby      | 150,000            |    
| Hadoop    | 139,201            |    
| Julia     | 136,100            |
| Airflow   | 135,410            |    


Here's the breakdown of the results for top paying skills for Business Analysts:
- **High Demand for Big Data & ML Skills:** Top salaries are commanded by analysts skilled in big data technologies (PySpark, Couchbase), machine learning tools (DataRobot, Jupyter), and Python libraries (Pandas, NumPy), reflecting the industry's high valuation of data processing and predictive modeling capabilities.
- **Software Development & Deployment Proficiency:** Knowledge in development and deployment tools (GitLab, Kubernetes, Airflow) indicates a lucrative crossover between data analysis and engineering, with a premium on skills that facilitate automation and efficient data pipeline management.
- **Cloud Computing Expertise:** Familiarity with cloud and data engineering tools (Elasticsearch, Databricks, GCP) underscores the growing imprortance of cloud-based analytics environments, suggesting that cloud proficiency significantly boosts earning potential in data analytics.

### 5. Most Optimal Skills to Learn
Combining insights from the demand and salary data, this query aimed to pinpoint skills that are both in high demand  and have high salaries, offering a strategic focus for skill development.

```sql
WITH skills_demand AS (
	SELECT 
		skills_dim.skill_id,
		skills_dim.skills,
		COUNT(skills_job_dim.job_id) AS demand_count
	FROM 
		job_postings_fact
	INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
	INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
	WHERE job_title_short = 'Business Analyst'
		  AND salary_year_avg IS NOT NULL
	GROUP BY 
		skills_dim.skill_id
), average_salary AS (
	SELECT
		skills_job_dim.skill_id,
		ROUND(AVG(salary_year_avg), 0) AS avg_salary
	FROM 
		job_postings_fact
	INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
	INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
	WHERE job_title_short = 'Business Analyst' 
		  AND salary_year_avg IS NOT NULL
	GROUP BY 
		skills_job_dim.skill_id
)

SELECT 
	skills_demand.skill_id,
	skills_demand.skills,
	demand_count,
	avg_salary
FROM
	skills_demand
INNER JOIN 
	average_salary ON skills_demand.skill_id = average_salary.skill_id
ORDER BY
	demand_count DESC,
	avg_salary DESC
LIMIT 20;
```
Here's a more concise version of the same query:
```sql
SELECT
	skills_dim.skill_id,
	skills_dim.skills,
	COUNT(skills_job_dim.job_id) AS demand_count,
	ROUND(AVG(job_postings_fact.salary_year_avg), 0) AS avg_salary
FROM
	job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
	job_title_short = 'Data Analyst'
	AND salary_year_avg IS NOT NULL
	AND job_work_from_home = TRUE
GROUP BY
	skills_dim.skill_id
HAVING
	COUNT(skills_job_dim.job_id) > 10
ORDER BY
	avg_salary DESC,
	demand_count DESC
LIMIT 20;
```
| Skills ID | Skills     | Demand Count | Average Salary ($) |
|-----------|------------|--------------|--------------------|
| 8         | Go         | 27           | 115,320            |
| 234       | Confluence | 11           | 114,210            |
| 97        | Hadoop     | 22           | 113,193            | 
| 80        | Snawflake  | 37           | 112,948            |
| 74        | Azure      | 34           | 111,225            |
| 77        | BigQuery   | 13           | 109,654            |


Here's is the breakdown of the most optimal skills for Data Analysts in 2023:
- **High_Demand Programming Languages:** Python and R stand out for their high demand, with demand count 236 and 148 respectively. Despite their high demand, their average salaries are arounf $101,499 for R, indicatinf that proficiency in these languages is highly valued but also videly available.
- **Cloud Tools and Technologies:** Skills in specialized technologies such as Snowflake, Azure, AWS, and BigQuery show significant demand with relatively high average salaries, pointing towards the growing importance of cloud platforms and big data technologies in data analysis.
- **Business Intelligence and Visualization Tools:** Tableau and Looker, with demand counts of 230 and 49 respectively, and average salaries around $99,288 and $103,795, highlight the critical role of the data visualization and business intelligence in deriving actionable insights from data.
- **Database Technologies:** The demand for skills in traditional and NoSQL databases (Oracle, SQL Server, NoSQL) with average salaries ranging from $97,786 to $104,534, reflects the enduring need for data storage, retrieval, and management expertise. 

# What I Learned
Throughout this project, I gained a deeper understanding of the job market for data and business analysts. I learned which skills are most valuable, both in terms of demand and salary potential. The analysis reinforced the importance of programming languages like Python and SQL, as well as tools like Tableau and cloud technologies. This knowledge can guide future skill development and career decisions in the field of data analytics.

# Conclusion
This project provided valuable insights into the data and business analyst job market, highlighting the top-paying jobs, the most in-demand skills, and the skills associated with higher salaries. By focusing on high-demand, high-salary skills, professionals can strategically enhance their expertise to improve their job prospects and earning potential in the competitive field of data analytics.
