SELECT
  day,
  user_id,
  score       AS in_contest,
  rank() OVER (                       ORDER BY score DESC)       AS rank_in_contest,

  batch_id,
  batch_score AS in_batch,
  rank() OVER (PARTITION BY batch_id  ORDER BY batch_score DESC) AS rank_in_batch,

  city_id,
  city_score  AS in_city,
  rank() OVER (PARTITION BY city_id   ORDER BY city_score DESC)  AS rank_in_city

FROM (
  SELECT
  day,
  user_id,
  SUM(in_contest)::integer AS score,
  batch_id,
  SUM(in_batch)::integer AS batch_score,
  city_id,
  SUM(in_city)::integer AS city_score

  FROM user_points
  GROUP BY user_id, batch_id, city_id, day
) AS scores;
