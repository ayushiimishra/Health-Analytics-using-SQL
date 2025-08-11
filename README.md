# Health Analytics Mini Case Study

---

## Situation  

The General Manager of Analytics at Health Co has requested help analyzing the `health.user_logs` dataset.  

---

## Data  

We have two tables to work with:  

- `user_logs`  
- `users`  

### user_logs  

This table contains measurements like blood glucose, blood pressure, and weight, recorded by users at various times.  

The main focus of this study is the `user_logs` table.  

---

## Sneak Peek at the Data  

(A preview image of data here if needed)  

---

## Business Questions  

1. How many unique users are in the logs dataset?  
2. What is the average number of measurements per user?  
3. What is the median number of measurements per user?  
4. How many users have 3 or more measurements?  
5. How many users have 1,000 or more measurements?  

Additionally, about the active users:  

6. How many have logged blood glucose measurements?  
7. How many have at least 2 types of measurements?  
8. How many have all 3 measures: blood glucose, weight, and blood pressure?  

For users with blood pressure measurements:  

9. What are the median systolic and diastolic blood pressure values?  

---

## Solutions  

-- 1. Unique users in the logs
SELECT COUNT(DISTINCT id) AS unique_users
FROM user_logs;

-- 2 to 8: Prepare temporary table
DROP TABLE IF EXISTS user_measure_count;

SELECT
id,
COUNT(*) AS measure_count,
COUNT(DISTINCT measure) AS unique_measures
INTO user_measure_count
FROM user_logs
GROUP BY id;

-- 2. Average measurements per user
SELECT ROUND(AVG(measure_count),2) AS avg_measurements
FROM user_measure_count;

-- 3. Median measurements per user
SELECT DISTINCT
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY measure_count) OVER () AS median_measurement
FROM user_measure_count;

-- 4. Users with 3 or more measurements
SELECT COUNT(id) AS count_records
FROM user_measure_count
WHERE measure_count >= 3;

-- 5. Users with 1,000 or more measurements
SELECT COUNT(id) AS count_records
FROM user_measure_count
WHERE measure_count >= 1000;

-- 6. Users who logged blood glucose measurements
WITH active_users AS (
SELECT measure, COUNT(DISTINCT id) AS active_users,
ROUND(100 * CAST(COUNT(DISTINCT id) AS NUMERIC) / SUM(COUNT(DISTINCT id)) OVER(), 2) AS perc_active_users
FROM user_logs
GROUP BY measure
)
SELECT measure, active_users, CONCAT(SUBSTRING(CAST(perc_active_users AS nvarchar), 1, 5), '%') AS perc_active_users
FROM active_users
WHERE measure = 'blood_glucose';

-- 7. Users with at least 2 types of measurements
SELECT COUNT(*) AS Count
FROM user_measure_count
WHERE unique_measures >= 2;

-- 8. Users with all 3 measures
SELECT COUNT(*) AS Count
FROM user_measure_count
WHERE unique_measures = 3;

-- 9. Median systolic and diastolic blood pressure values
SELECT DISTINCT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY CAST(systolic AS INT)) OVER() AS systolic_median
FROM user_logs
WHERE measure = 'blood_pressure';

SELECT DISTINCT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY CAST(diastolic AS INT)) OVER() AS diastolic_median
FROM user_logs
WHERE measure = 'blood_pressure';

text
undefined