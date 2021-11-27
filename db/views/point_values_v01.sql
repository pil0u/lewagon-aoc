SELECT
  co.id AS completion_id,
  (SELECT COUNT(*) FROM users WHERE synced)                                 - cr.in_contest + 1 AS in_contest,
  (SELECT COUNT(*) FROM users WHERE synced AND users.batch_id = u.batch_id) - cr.in_batch + 1   AS in_batch,
  (SELECT COUNT(*) FROM users WHERE synced AND users.city_id = u.city_id)   - cr.in_city + 1    AS in_city
FROM completions co
LEFT JOIN users u
ON co.user_id = u.id
LEFT JOIN completion_ranks cr
ON cr.completion_id = co.id;
