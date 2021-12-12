SELECT
  city_id,
  day,
  challenge,
  completion_id,

  completion_id IS NOT NULL AS participated,

  user_id,
  CASE
    WHEN up.rank_in_city <= (VALUES (max_allowed_contributors_in_city()))
      THEN up.in_contest
    ELSE 0
  END AS in_contest,

  batch_id,
  CASE
    WHEN up.rank_in_city <= (VALUES (max_allowed_contributors_in_city()))
      THEN up.in_batch
    ELSE 0
  END AS in_batch

FROM user_points up;
