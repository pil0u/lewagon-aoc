WITH synced_user_numbers AS (
  SELECT GREATEST(3, CEIL(percentile_cont(0.5) WITHIN GROUP (ORDER BY value))::int) AS median
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
  c.id AS city_id,
  co.day AS day,
  co.challenge AS challenge,
  COALESCE(SUM(cc.points), 0) AS points,
  rank() OVER (PARTITION BY co.day, co.challenge ORDER BY SUM(cc.points) DESC) AS rank,
  COUNT(*) FILTER (WHERE co.id IS NOT NULL) AS participating_users,
  COUNT(*) FILTER (WHERE co.id IS NOT NULL) >= (SELECT median FROM synced_user_numbers) AS complete
FROM cities AS c
LEFT JOIN users u
ON u.city_id = c.id
LEFT JOIN completions co
ON co.user_id = u.id
LEFT JOIN city_contributions cc
ON cc.completion_id = co.id

GROUP BY c.id, co.day, co.challenge
ORDER BY day, challenge, points DESC;
