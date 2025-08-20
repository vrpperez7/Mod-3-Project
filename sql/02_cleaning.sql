-- If you haven't added these yet, run them ONCE (comment out if they already exist)

 ALTER TABLE fact_visits ADD COLUMN spend_cents_clean INTEGER;
 ALTER TABLE fact_purchases ADD COLUMN amount_cents_clean INTEGER;
-- Visits: compute cleaned once, join by rowid, update when cleaned is non-empty
WITH c AS (
SELECT
rowid AS rid,
REPLACE(REPLACE(REPLACE(REPLACE(UPPER(COALESCE(total_spend_cents,'')),
'USD',''), '$',''), ',', ''), ' ', '') AS cleaned
FROM fact_visits
)
UPDATE fact_visits
SET spend_cents_clean = CAST((SELECT cleaned FROM c WHERE c.rid = fact_visits.rowid)
AS INTEGER)
WHERE LENGTH((SELECT cleaned FROM c WHERE c.rid = fact_visits.rowid)) > 0;

-- Purchases: same pattern (WRITE THE SAME CODE ABOVE for the fact_purchases table)
-- Remember facts_visits and facts_purchases has the `amount` column in units of cents
-- so you may need to do another SELECT statement to convert these columns to dollars


-- b. Detect Duplicates 
SELECT visit_id, COUNT(*) as dup
FROM fact_ride_events
GROUP BY visit_id,attraction_id, ride_time, wait_minutes, satisfaction_rating,photo_purchase
HAVING COUNT(*)>1
ORDER BY dup DESC;

-- Shows second record of columns that are duplicated
SELECT *
FROM fact_ride_events
WHERE rowid NOT IN (
  SELECT MIN(rowid)
  FROM fact_ride_events
  GROUP BY visit_id,attraction_id, ride_time, wait_minutes, satisfaction_rating,photo_purchase
)

-- c. Validate keys: ensure foreign keys have a matching parent

-- guest_id validated
SELECT v.visit_id, v.guest_id
FROM fact_visits v
LEFT JOIN dim_guest g ON g.guest_id = v.guest_id
WHERE g.guest_id IS NULL;

--attraction_id validated and visit_id
SELECT fre.ride_event_id, fre.attraction_id
FROM fact_ride_events fre
LEFT JOIN dim_attraction da ON fre.attraction_id = da.attraction_id
WHERE da.attraction_id IS NULL

SELECT fre.visit_id
FROM fact_ride_events fre
LEFT JOIN fact_visits fv ON fv.visit_id = fre.visit_id
WHERE fre.visit_id IS NULL

--ticket_type_id validated
SELECT v.visit_id, v.ticket_type_id
FROM fact_visits v
LEFT JOIN dim_ticket dt ON v.ticket_type_id = v.ticket_type_id
WHERE dt.ticket_type_id IS NULL

--visit_id validated in purchase_id
SELECT fp.visit_id, fp.purchase_id
FROM fact_purchases fp
LEFT JOIN fact_visits fv ON fp.visit_id = fv.visit_id
WHERE fp.visit_id IS NULL

--dim_date validation from fact_visits
SELECT fv.visit_id, fv.date_id
FROM fact_visits fv
LEFT JOIN dim_date dd ON fv.date_id = dd.date_id
WHERE fv.date_id IS NULL

--guests who did not make purchases 
SELECT fv.visit_id, fv.guest_id
FROM fact_visits fv
LEFT JOIN fact_purchases fp ON fv.visit_id = fp.visit_id
WHERE fp.visit_id IS NULL

-- D) Handling Missing Values and normalizing columns

--setting payment_method in fact_purchases to uppercase & trim
UPDATE fact_purchases
SET payment_method = TRIM(UPPER(payment_method))

--updating promotion_code to upper and removing whitespaceand extra characters (47)
UPDATE fact_visits
SET promotion_code = REPLACE(TRIM(UPPER(promotion_code)),'-','')

--fixing casing for home_state

--first trim & upper to states (all values)
UPDATE dim_guest
SET home_state = UPPER(TRIM(home_state))

--changing CALIFORNIA to CA
UPDATE dim_guest
SET home_state = 'CA'
WHERE home_state = 'CALIFORNIA'
--changing NEW YORK to NY 
UPDATE dim_guest
SET home_state = 'NY'
WHERE home_state = 'NEW YORK'

--removing duplicate rows in fact_ride_event (8 rows have the same values in all rows)
DELETE FROM fact_ride_events
WHERE rowid NOT IN (
  SELECT MIN(rowid)
  FROM fact_ride_events
  GROUP BY visit_id,attraction_id, ride_time, wait_minutes, satisfaction_rating,photo_purchase
)


