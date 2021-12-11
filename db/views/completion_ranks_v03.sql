SELECT
  e.day,
  e.challenge,
  u.id AS user_id,
  co.id AS completion_id,

  CASE
    WHEN co.completion_unix_time IS NULL THEN NULL
    ELSE rank() OVER (PARTITION BY  e.day, e.challenge ORDER BY completion_unix_time ASC)
  END AS in_contest,
  CASE
    WHEN co.completion_unix_time IS NULL THEN NULL
    ELSE rank() OVER (PARTITION BY u.batch_id, e.day, e.challenge ORDER BY completion_unix_time ASC)
  END AS in_batch,
  CASE
    WHEN co.completion_unix_time IS NULL THEN NULL
    ELSE rank() OVER (PARTITION BY u.city_id, e.day, e.challenge ORDER BY completion_unix_time ASC)
  END AS in_city

FROM exercises e
CROSS JOIN users u
LEFT JOIN completions co
ON co.day = e.day AND co.challenge = e.challenge AND co.user_id = u.id;
