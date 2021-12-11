SELECT
  day,
  challenge,
  completion_id,

  user_id,
  in_contest,
  dense_rank() OVER (ORDER BY in_contest DESC NULLS LAST) AS rank_in_contest,

  batch_id,
  in_batch,
  dense_rank() OVER (PARTITION BY batch_id ORDER BY in_batch DESC NULLS LAST) AS rank_in_batch,

  city_id,
  in_city,
  dense_rank() OVER (PARTITION BY city_id ORDER BY in_city DESC NULLS LAST) AS rank_in_city

FROM point_values;
