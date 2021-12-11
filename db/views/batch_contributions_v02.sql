SELECT
  batch_id,
  day,
  challenge,
  completion_id,

  completion_id IS NOT NULL AS participated,

  user_id,
  CASE
    WHEN up.rank_in_batch <= (VALUES (max_allowed_contributors_in_batch()))
      THEN up.in_contest
    ELSE 0
  END AS in_contest,

  city_id,
  CASE
    WHEN up.rank_in_batch <= (VALUES (max_allowed_contributors_in_batch()))
      THEN up.in_city
    ELSE 0
  END AS in_city

FROM user_points up;
