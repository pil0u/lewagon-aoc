WITH synced_user_numbers AS (
  SELECT CEIL(percentile_cont(0.5) WITHIN GROUP (ORDER BY value)) AS median
  FROM (
    SELECT COUNT(u.*) AS value
    FROM cities
    LEFT JOIN users AS u
    ON u.city_id = cities.id
    WHERE u.synced
    GROUP BY cities.id
  ) AS synced_user_counts
)

SELECT
  b.id AS city_id,
  co.day AS day,
  co.challenge AS challenge,
  SUM(pv.in_contest) AS points,
  dense_rank() OVER (ORDER BY SUM(pv.in_contest)) AS rank,
  COUNT(pv.*) AS participating_users,
  COUNT(pv.*) >= (SELECT median FROM synced_user_numbers) AS complete

FROM cities AS b
LEFT JOIN users u
ON u.city_id = b.id
LEFT JOIN completions co
ON co.user_id = u.id
LEFT JOIN point_values pv
ON pv.completion_id = co.id
LEFT JOIN completion_ranks cr
ON cr.completion_id = co.id

WHERE cr.in_city <= (SELECT median FROM synced_user_numbers)
GROUP BY b.id, co.day, co.challenge
ORDER BY day, challenge, points DESC;
