WITH payment_cnt AS (
  SELECT payment_type,
         count(1) as cnt
  FROM rides
  GROUP BY payment_type
)
SELECT payment_type,
       cnt * 100.0 / (SELECT sum(cnt) FROM payment_cnt) AS percent
FROM payment_cnt;
