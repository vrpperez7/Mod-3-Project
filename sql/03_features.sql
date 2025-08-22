--1) Calculating total spend in dollars

ALTER TABLE fact_visits ADD COLUMN total_spent_dollars INTEGER;
UPDATE fact_visits
SET total_spent_dollars = (spend_cents_clean / 100.0)

  --Most people are able to recognize monetary values in dollars
  --easier to visualize instead of large numbers

--2) Bins for wait_times

ALTER TABLE fact_ride_events ADD COLUMN time_waited;
UPDATE fact_ride_events
SET
  time_waited = CASE 
  WHEN wait_minutes IS NULL THEN null
  WHEN wait_minutes >= 0 AND wait_minutes <= 15 THEN '0-15 mins'
  WHEN wait_minutes >=16 AND wait_minutes <= 30 THEN '16-30 mins'
  WHEN wait_minutes >=31 AND wait_minutes <= 60 THEN '31-60 mins'
  ELSE '61+ mins'
  END

/*
  COUNT(*) as frequency_of_wait,
  AVG(satisfaction_rating) as average_rating
FROM fact_ride_events
GROUP BY minutes_waited
ORDER BY average_rating DESC
*/

  --good to highlight what is the usual time people wait for their rides
  --able to see if satisfaction score is worse for those that waited 61+ mins

-- 3) calculating stay_minutes from entry to exit

ALTER TABLE fact_visits ADD COLUMN stay_minutes;

UPDATE fact_visits
SET stay_minutes =
      --calculating time different and multiplying by to translate to day
      (JULIANDAY(exit_time) - JULIANDAY(entry_time)) * 24 * 60

--updating to round number to nearest integer)
UPDATE fact_visits
SET stay_minutes = ROUND(stay_minutes)
  
      --can check to see how long people stay on average
      --if we know how long people stay at the park, we can compare it to previous weeks
      --shows either engagement or need to change wait times for rides
  
-- 4) column for made purchase or did not make purchase by checking if primary key (purchase_id) is null.
/*
WITH purchases AS(  
  SELECT *,
  CASE WHEN fp.purchase_id IS NULL THEN 'No Purchase'
  ELSE 'Made Purchase'
  END AS purchase_or_no
  FROM fact_visits fv
  INNER JOIN fact_purchases fp ON fv.visit_id = fp.visit_id
)
  
  SELECT guest_id, promotion_code,
  SUM(CASE WHEN purchase_or_no = 'Made Purchase' THEN 1 ELSE 0 END) as count_of_purchase
  FROM purchases
  GROUP BY promotion_code
*/

--creating a satisfied score for customers who provided ratings
ALTER TABLE fact_ride_events ADD COLUMN satisfied_score

UPDATE fact_ride_events
SET satisfied_score =
    CASE WHEN satisfaction_rating = 5 THEN 'Satisfied'
         WHEN satisfaction_rating = 4 THEN 'Moderately Satisfied'
         WHEN satisfaction_rating < 4 THEN 'Unsatisfied'
         ELSE null
         END

  --we can now count how many customers were unsatisfied with their experience
  