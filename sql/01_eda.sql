--Q0: Row counts per table
SELECT 'dim_guest' AS table_name, 
  COUNT(*) AS n 
  FROM dim_guest

  UNION ALL SELECT 'dim_ticket', 
  COUNT(*) FROM dim_ticket

  UNION ALL SELECT 'dim_attraction', 
  COUNT(*) FROM dim_attraction

  UNION ALL SELECT 'fact_visits', 
  COUNT(*) FROM fact_visits

  UNION ALL SELECT 'fact_ride_events', 
  COUNT(*) FROM fact_ride_events

  UNION ALL SELECT 'fact_purchases', 
  COUNT(*) FROM fact_purchases;

--Q1: Date range of visit_date; number of distinct dates; visits per date

SELECT DISTINCT fv.visit_date as dates,  dt.day_name as day_of_week,
  COUNT(fv.visit_date) as total_visits
FROM fact_visits fv
JOIN dim_date dt ON dt.date_id = fv.date_id
GROUP BY dates
ORDER BY total_visits DESC

--Q2: Visits by ticket type name

SELECT promotion_code,dt.ticket_type_name as ticket_type, COUNT(ft.ticket_type_id) as count, SUM(total_spent_dollars)
FROM fact_visits ft
LEFT JOIN dim_ticket dt ON  dt.ticket_type_id = ft.ticket_type_id
GROUP BY dt.ticket_type_name
ORDER BY count DESC



--Q3: Distribution of Wait Minutes

SELECT
  CASE 
  WHEN wait_minutes IS NULL THEN 'Unknown'
  WHEN wait_minutes >= 0 AND wait_minutes <= 30 THEN '0-30 mins'
  WHEN wait_minutes >=31 AND wait_minutes <= 60 THEN '31-60 mins'
  ELSE '61+ mins'
  END AS minutes_waited,
  COUNT(*) as frequency_of_wait
FROM fact_ride_events
GROUP BY minutes_waited
ORDER BY frequency_of_wait DESC

  --most values come from NULL


--Q4: Average Satisfaction rating by attraction name and category

SELECT da.attraction_name as name, da.category, ROUND(AVG(fde.satisfaction_rating),3) as rating
FROM dim_attraction da
JOIN fact_ride_events fde ON fde.attraction_id = da.attraction_id
GROUP BY da.attraction_name, da.category
ORDER BY rating DESC
  --highest rating is dragon drop at 3.313
  --lowest rating is wild rapids at 2.625

--Q5: Check for exact duplicates on fact_ride_events rows

SELECT visit_id, COUNT(*) as dup
FROM fact_ride_events
GROUP BY visit_id,attraction_id, ride_time, wait_minutes, satisfaction_rating,photo_purchase
HAVING COUNT(*)>1
ORDER BY dup DESC;

--2 duplicates in visit_id's 4,12,18,19,22,24,34 and 37

--Q6: Null audit for columns used for analysis

  --72 records of wait_minutes is null
  --67 after removing duplicates
SELECT COUNT(*) as null_values
FROM fact_ride_events
WHERE wait_minutes IS NULL

  --20 values between null in total_spend_cents and n/a values
SELECT COUNT(*) as null_values
FROM fact_visits
WHERE total_spend_cents IS 'n/a' OR total_spend_cents IS NULL

--Q7: Average party size by day of week

SELECT dd.day_name, count(dd.day_name) as count_of_appearances, ROUND(AVG(fv.party_size),3) as avgparty_size, SUM(fv.party_size) as sumparty_size
FROM fact_visits fv
JOIN dim_date dd ON fv.date_id = dd.date_id
GROUP BY dd.day_name
ORDER BY avgparty_size DESC

