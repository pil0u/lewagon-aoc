SELECT
  u.id AS user_id,
  SUM(pv.in_contest) AS in_contest,
  SUM(pv.in_batch) AS in_batch,
  SUM(pv.in_city) AS in_city
FROM users u
LEFT JOIN completions co
ON co.user_id = u.id
LEFT JOIN point_values pv
ON pv.completion_id = co.id
GROUP BY u.id;
