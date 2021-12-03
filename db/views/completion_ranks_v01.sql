SELECT
  co.id AS completion_id,
  dense_rank() OVER (PARTITION BY             co.day, co.challenge ORDER BY co.completion_unix_time ASC) AS in_contest,
  dense_rank() OVER (PARTITION BY u.batch_id, co.day, co.challenge ORDER BY co.completion_unix_time ASC) AS in_batch,
  dense_rank() OVER (PARTITION BY u.city_id,  co.day, co.challenge ORDER BY co.completion_unix_time ASC) AS in_city
FROM completions co
LEFT JOIN users u
ON co.user_id = u.id
WHERE co.completion_unix_time IS NOT NULL;
