SELECT
  co.id AS completion_id,
  dense_rank() over (partition by co.day, co.challenge order by co.completion_unix_time) AS in_contest,
  dense_rank() over (partition by b.id, co.day, co.challenge order by co.completion_unix_time) AS in_batch,
  dense_rank() over (partition by ci.id, co.day, co.challenge order by co.completion_unix_time) AS in_city
FROM completions co
LEFT JOIN users u
ON co.user_id = u.id
LEFT JOIN batches b
ON u.batch_id = b.id
LEFT JOIN cities ci
ON u.city_id = ci.id;
