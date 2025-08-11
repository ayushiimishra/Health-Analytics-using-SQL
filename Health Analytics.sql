-- HEALTH ANALYTICS CASE STUDY
-- AUTHOR : Aditya Shenoy

-- Q1. How many unique users exist in the logs dataset?
SELECT
	COUNT(DISTINCT id) AS unique_users
FROM user_logs;

-- Creating a temp table 
DROP TABLE IF EXISTS user_measure_count;

SELECT
    id,
    COUNT(*) AS measure_count,
    COUNT(DISTINCT measure) as unique_measures
INTO user_measure_count
FROM user_logs
GROUP BY id; 

-- Q2. How many total measurements do we have per user on average?
SELECT
	ROUND(AVG(measure_count),2) AS avg_measurements
FROM user_measure_count;

-- Q3. Median Number of measurements per user?
SELECT
	 DISTINCT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY measure_count) OVER () AS median_measurement
FROM
	user_measure_count;

-- Q4. How many users have 3 or more measurements?
SELECT
	COUNT(id) AS count_records
FROM
	user_measure_count
WHERE
	measure_count > 3;

-- Q5. How many users have 1,000 or more measurements?
SELECT
	COUNT(id) AS count_records
FROM user_measure_count
WHERE measure_count >= 1000;

-- Looking at the logs data - what is the number and percentage of the active user base who:
-- Q6. Have logged bood glucose measurements
WITH active_users AS(
SELECT
	measure,
	COUNT(DISTINCT id) AS active_users,
	ROUND(
		100*CAST(COUNT(DISTINCT id) AS NUMERIC)/SUM(COUNT(DISTINCT id)) OVER(), 
		2
		) AS perc_active_users
FROM user_logs
GROUP BY measure
)
SELECT
	measure,
	active_users,
	CONCAT(SUBSTRING(CAST(perc_active_users  AS nvarchar),1,5),'%') AS perc_active_users
FROM 
	active_users
WHERE
	measure = 'blood_glucose'

-- Q7. Have atleast 2 types of measurements
SELECT 
  COUNT(*) AS Count
FROM user_measure_count
WHERE unique_measures >= 2;

-- Q8. Have all 3 measures - blood glucose, weight and blood pressure?
SELECT
  COUNT(*) AS Count
FROM user_measure_count
WHERE unique_measures = 3;

-- Q9. What is the median systolic/diastolic blood pressure values?
SELECT
	DISTINCT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY CAST(systolic AS INT)) OVER() AS systolic_median
FROM user_logs
WHERE measure = 'blood_pressure';

SELECT
	DISTINCT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY CAST(diastolic AS INT)) OVER() AS diastolic_median
FROM user_logs
WHERE measure = 'blood_pressure';
	

