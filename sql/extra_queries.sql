
--category, count of category, average wait, and average rating
SELECT da.category, COUNT(fre.satisfaction_rating) as count_of_visits,
       ROUND(AVG(fre.wait_minutes),2) as average_wait,
       ROUND(AVG(fre.satisfaction_rating),2) as average_rating
FROM fact_ride_events fre
JOIN dim_attraction da ON fre.attraction_id = da.attraction_id
WHERE fre.wait_minutes IS NOT NULL
GROUP BY da.category
  --able to see water has highest count, highest wait, and lowest rating

--cte for join of fact purchases and fact_visits
  WITH promopurchase AS (
  SELECT *
  FROM fact_purchases fp
  JOIN fact_visits fv ON fv.visit_id = fp.visit_id
)
--promotion code is not null refers to guests who have made purchases,
  SELECT promotion_code,
         COUNT(*) as count_of_purchases
  FROM promopurchase
  WHERE promotion_code IS NOT NULL
  GROUP BY promotion_code

/*
  --CHECK FOR 9 others weren't included in fact_purchases
  WITH promopurchase AS (
  SELECT *
  FROM fact_purchases fp
  JOIN fact_visits fv ON fv.visit_id = fp.visit_id
)
  SELECT promotion_code,
         COUNT(*) as count_of_purchases
  FROM promopurchase
  WHERE promotion_code IS NULL
  GROUP BY promotion_code
  --CHECK WAS ACCURATE
*/

--40 guests didnt have null values for promotions
  SELECT promotion_code, COUNT(*)
  FROM fact_visits
  WHERE promotioN_code IS NOT NULL
  GROUP BY promotion_code

-- top 5 of unsatisfied customers
  SELECT fre.satisfied_score, da.category,COUNT(fre.satisfied_score) as count
  FROM fact_ride_events fre
  JOIN dim_attraction da ON da.attraction_id = fre.attraction_id
  GROUP BY da.category, satisfied_score
  ORDER BY count DESC
  LIMIT 5

