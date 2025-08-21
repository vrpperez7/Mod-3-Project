--1) Extracting minutes, hours from the subtraction of entry time from exit time
WITH time_spent AS(
     SELECT visit_id,
      --calculating time different and multiplying by to translate to day
      (JULIANDAY(exit_time) - JULIANDAY(entry_time)) * 24 as time_spent
      FROM fact_visits
),
     hours_mins AS(
    SELECT fv.entry_time, fv.exit_time, 
    --splitting outcome of time_spent into two separate columns (hours and minutes)
    (SUBSTR(ts.time_spent,1, INSTR(ts.time_spent, '.') - 1)) as hours,
    (FLOOR('.' || SUBSTR(ts.time_spent,INSTR(ts.time_spent,'.') + 1) *60)) as mins
    FROM fact_visits fv
    JOIN time_spent ts ON fv.visit_id = ts.visit_id
),
    total_time AS(
    SELECT entry_time, exit_time ,CAST(hours as INTEGER) || ':' ||
    CASE WHEN CAST(mins as INTEGER) < 10 THEN '0' || CAST(mins as INTEGER)
    ELSE CAST(mins AS INTEGER)
    END AS total_time_spent
    FROM hours_mins
)
    SELECT MAX(total_time_spent)
    FROM total_time
  --work on to understand time, doesn't recognize as hours

--2) Bins for wait_times

SELECT
  CASE 
  WHEN wait_minutes IS NULL THEN 'Unknown Time'
  WHEN wait_minutes >= 0 AND wait_minutes <= 15 THEN '0-15 mins'
  WHEN wait_minutes >=16 AND wait_minutes <= 30 THEN '16-30 mins'
  WHEN wait_minutes >=31 AND wait_minutes <= 60 THEN '31-60 mins'
  ELSE '61+ mins'
  END AS minutes_waited,
  COUNT(*) as frequency_of_wait
FROM fact_ride_events
GROUP BY minutes_waited
ORDER BY frequency_of_wait DESC

-- 3) calculating wait time in total minutes

SELECT visit_id,
      --calculating time different and multiplying by to translate to day
      (JULIANDAY(exit_time) - JULIANDAY(entry_time)) * 24 * 60 as stay_minutes
      FROM fact_visits
      ORDER BY stay_minutes DESC

-- 4) column for made purchase or did not make purchase by checking if primary key (purchase_id) is null.

  SELECT *,
  CASE WHEN fp.purchase_id IS NULL THEN 'No Purchase'
       ELSE 'Made Purchase'
       END AS 'Purchase/No Purchase'
  FROM fact_visits fv
  LEFT JOIN fact_purchases fp ON fv.visit_id = fp.visit_id

