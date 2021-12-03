WITH synced_user_numbers AS (
  SELECT GREATEST(3, CEIL(percentile_cont(0.5) WITHIN GROUP (ORDER BY value))::int) AS median
  FROM (
    SELECT COUNT(u.*) AS value
    FROM batches
    LEFT JOIN users AS u
    ON u.batch_id = batches.id
    WHERE u.synced
    GROUP BY batches.id
  ) AS synced_user_counts
)

SELECT
  b.id AS batch_id,
  co.day AS day,
  co.challenge AS challenge,
  COALESCE(SUM(bc.points), 0) AS points,
  dense_rank() OVER (PARTITION BY co.day, co.challenge ORDER BY SUM(bc.points) DESC) AS rank,
  COUNT(*) FILTER (WHERE bc.points <> 0) AS participating_users,
  COUNT(*) FILTER (WHERE bc.points <> 0) >= (SELECT median FROM synced_user_numbers) AS complete
FROM batches AS b
LEFT JOIN users u
ON u.batch_id = b.id
LEFT JOIN completions co
ON co.user_id = u.id
LEFT JOIN batch_contributions bc
ON bc.completion_id = co.id

WHERE u.synced

GROUP BY b.id, co.day, co.challenge
ORDER BY day, challenge, points DESC;
