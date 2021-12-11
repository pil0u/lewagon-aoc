SELECT
  cr.user_id,
  cr.day,
  cr.challenge,
  cr.completion_id,

  CASE
    WHEN cr.in_contest IS NULL THEN 0
    ELSE (SELECT COUNT(*) FROM users WHERE synced) - cr.in_contest + 1
  END AS in_contest,

  u.batch_id,
  CASE
    WHEN cr.in_batch IS NULL THEN 0
    ELSE (SELECT COUNT(*) FROM users WHERE synced AND users.batch_id = u.batch_id) - cr.in_batch + 1
  END AS in_batch,

  u.city_id,
  CASE
    WHEN cr.in_city IS NULL THEN 0
    ELSE (SELECT COUNT(*) FROM users WHERE synced AND users.city_id = u.city_id) - cr.in_city + 1
  END AS in_city

FROM users u
LEFT JOIN completion_ranks cr
ON cr.user_id = u.id;
