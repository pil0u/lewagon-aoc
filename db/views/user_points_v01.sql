SELECT
  day,
  challenge,
  completion_id,

  completion_id IS NOT NULL AS completed,

  user_id,
  in_contest,
  rank() OVER (PARTITION BY day, challenge           ORDER BY in_contest DESC NULLS LAST) AS rank_in_contest,

  batch_id,
  in_batch,
  rank() OVER (PARTITION BY day, challenge, batch_id ORDER BY in_batch DESC NULLS LAST) AS rank_in_batch,

  city_id,
  in_city,
  rank() OVER (PARTITION BY day, challenge, city_id  ORDER BY in_city DESC NULLS LAST) AS rank_in_city

FROM point_values;
