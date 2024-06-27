--- PROJECT - (SQL_PROJECT_JOBS_DATA_ANALYSIS) ---
/*
QUESTION 1: What are the top paying jobs for my role?
- Identify the top 10 highest paying Data Analyst and Business Analyst role that are 
  available remotely.
- Focus on job postings with specified salaries (remove nulls).
- Highlight the top paying opportunities for Data Analysts, offering insights into
  employees opportunities.
*/

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


/*
QUESTION 2: What skills are required for the top paying jobs for Data Analyst role?
- Identify the top 10 highest paying Data Analyst and Business Analyst role that are 
  available remotely. (using from the first query)
- Add the specific skills required for these skills.
- WHY? It provides a detailed look at which high-paying jobs demand certain skills,
       helping hob seekers understand which skills to develop that align with top salaries.
*/

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


/*
QUESTION 3: What are the most in-demand skills for data analysts?
- Join job postings to inner join table similar to query 2
- Identify the top 5 in-demand skills for Data Analyst or Business Analyst.
- Focus on all job postings.
- Why? Retrieves the top 5 skills with the highest demand in the job market,
	   providing insights into the most valuable skills for job seekers.
*/

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


/*
QUESTION 4: What are the top skills based on salary?
- Look at the average salary associated with each skill for Data Analyst or Business Analyst positions.
- Focus on roles with specified salaries, regardless of location.
- Why? It reveals how different skills impact salary levels for Data Analysts and helps identify the
	   most financially rewarding skills to acquire or improve.
*/

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


/*
QUESTION 5: What are the most optinal skills to learn (aka it's in high demand and high-paying skill)?
- Identify skills in high demand and associated with high average salary for Data Analyst roles.
- Concentrates on remote positions with specified salaries.
- Why? Target skills that offer job security (high demand) and financial benefits (high salaries),
       offering strategic insights for career development in Data Analysis.
*/

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
	
-- Rewriting the same query more concisely

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








