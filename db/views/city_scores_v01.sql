SELECT
  city_id AS batch_id,
  score,
  dense_rank() OVER (ORDER BY score DESC) AS rank
FROM (
  SELECT
  city_id AS batch_id,
  SUM(points) AS score
  FROM city_points
  GROUP BY city_id
) AS scores;
