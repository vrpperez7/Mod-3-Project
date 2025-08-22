-- 1) 
WITH daily_performance AS(
  SELECT fv.visit_date as visit_day, d.day_name as day_of_week, SUM(fv.party_size) as total_visits, SUM(fv.spend_cents_clean)/100.0 as daily_spend_dollars
  FROM fact_visits fv
  JOIN dim_date d ON d.date_id = fv.date_id
  GROUP BY visit_day
)
  --adding running totals of visists and revenue
  SELECT visit_day, day_of_week, total_visits,
        SUM(total_visits) OVER (ORDER BY visit_day ASC) as running_total_guest,
        ROUND(daily_spend_dollars, 2) as daily_spend,
        SUM(ROUND(daily_spend_dollars,2)) OVER (ORDER BY visit_day ASC) as running_total_revenue
  FROM daily_performance

  -- top 3 days sre Sunday, Monday, and Saturday
  

-- 2) CLV_revenue_proxy = SUM(spend_cents_clean) per guest, Compute RFM and rank guests by CLV within home_state using a window function
  --CLV per Guest
WITH rfm as (SELECT fv.guest_id, 
        (dg.first_name || ' '|| dg.last_name) as full_name,
        dg.home_state as state,
        MAX(fv.visit_date) as most_recent_visit,
        COUNT(fv.guest_id) as total_visits,
        SUM(fv.spend_cents_clean)/100.0 as total_spend_dollars
  FROM fact_visits fv
  JOIN dim_guest dg ON dg.guest_id = fv.guest_id
  GROUP BY state,fv.guest_id)

SELECT full_name, 
  total_visits,
  JULIANDAY(current_date) - JULIANDAY(most_recent_visit) as days_since_last_visit,
  state, total_spend_dollars,
  DENSE_RANK() OVER (PARTITION BY state ORDER BY total_spend_dollars DESC) as rank
FROM rfm
GROUP BY full_name

-- 3) Behavior change using lag

  --a check of values between promotional offers by referencing delta and sum of money spent

    --display previous payment and previous promotion to check if promotion makes a difference on payment
WITH lag as(
          SELECT guest_id, promotion_code, visit_date, spend_cents_clean,
          LAG(spend_cents_clean, 1) OVER (PARTITION BY guest_id ORDER BY visit_date ASC) AS previous_payment,
          LAG(promotion_code, 1) OVER (PARTITION BY guest_id ORDER BY visit_date ASC) AS previous_promotion
          FROM fact_visits
          ),
    --difference between current spend vs previous spend
    delta as(
          SELECT *, (spend_cents_clean - previous_payment) as deltacol, previous_promotion
          FROM lag
          WHERE previous_payment IS NOT NULL
)
  
    SELECT guest_id, promotion_code as current_promotion, spend_cents_clean as current_payment, previous_promotion, previous_payment, deltacol as difference_of_payment,
           --column to show hte type of change
           CASE
           WHEN deltacol > 0 THEN 'positive'
           WHEN deltacol = 0 THEN 'no change'
           WHEN deltacol < 0 THEN 'negative'
           END AS 'change since last visit'
    FROM delta
    WHERE deltacol IS NOT NULL AND previous_promotion IS NOT NULL

  

SELECT *
FROM fact_visits fv
FULL OUTER JOIN fact_purchases fp ON fp.visit_id = fv.visit_id
WHERE ((fv.spend_cents_clean IS NULL) OR (fv.spend_cents_clean is 0)) AND (fp.purchase_id IS NULL)

-- 4) ticket switching 

WITH ticket AS (
      SELECT fv.guest_id, dd.day_name as day, dt.ticket_type_id, dt.ticket_type_name,
      FIRST_VALUE(dt.ticket_type_name) OVER (PARTITION BY guest_id) as first_ticket,
      dt.base_price_cents,
      FIRST_VALUE(dt.base_price_cents) OVER (PARTITION BY guest_id) AS first_ticket_price
FROM fact_visits fv
JOIN dim_ticket dt ON dt.ticket_type_id = fv.ticket_type_id
JOIN dim_date dd ON fv.date_id = dd.date_id
),
    ticket_question AS (
        SELECT guest_id, day, first_ticket, first_ticket_price, ticket_type_name, base_price_cents,
          CASE WHEN ticket_type_name <> first_ticket THEN 'Changed From First Ticket'
          ELSE 'Did Not Change'
          END AS change
        FROM ticket
)
    SELECT ticket_type_name as first_ticket_type,base_price_cents, change, COUNT(*) as tickets
    FROM ticket_question
    GROUP BY change, ticket_type_name
