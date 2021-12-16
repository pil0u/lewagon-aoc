SELECT
  scores.day,

  part_one.completion_id AS first_completion_id,
  part_two.completion_id AS second_completion_id,

  scores.user_id,
  score              AS in_contest,
  rank() OVER (PARTITION BY scores.day                   ORDER BY score DESC)       AS rank_in_contest,

  scores.batch_id,
  scores.batch_score AS in_batch,
  rank() OVER (PARTITION BY scores.day, scores.batch_id  ORDER BY batch_score DESC) AS rank_in_batch,

  scores.city_id,
  scores.city_score  AS in_city,
  rank() OVER (PARTITION BY scores.day, scores.city_id   ORDER BY city_score DESC)  AS rank_in_city

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
)  AS scores
LEFT JOIN user_points AS part_one
ON part_one.day = scores.day AND part_one.user_id = scores.user_id AND part_one.challenge = 1
LEFT JOIN user_points AS part_two
ON part_two.day = scores.day AND part_two.user_id = scores.user_id AND part_two.challenge = 2
;
