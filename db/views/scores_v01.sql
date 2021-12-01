SELECT
  u.id AS user_id,
  COALESCE(SUM(pv.in_contest), 0) AS in_contest,
  COALESCE(SUM(pv.in_batch), 0) AS in_batch,
  COALESCE(SUM(pv.in_city), 0) AS in_city
FROM users u
LEFT JOIN completions co
ON co.user_id = u.id
LEFT JOIN point_values pv
ON pv.completion_id = co.id
GROUP BY u.id;
