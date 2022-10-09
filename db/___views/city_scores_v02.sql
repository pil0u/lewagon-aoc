SELECT
  city_id AS city_id,
  score AS in_contest,
  rank() OVER (ORDER BY score DESC) AS rank
FROM (
  SELECT
  city_id AS city_id,
  SUM(points) AS score
  FROM city_points
  GROUP BY city_id
) AS scores;
