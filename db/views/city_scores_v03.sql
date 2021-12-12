SELECT
  cities.id AS city_id,
  COALESCE(in_contest, 0) AS in_contest,
  dense_rank() OVER (ORDER BY in_contest DESC NULLS LAST) AS rank_in_contest
FROM cities
LEFT JOIN (
  SELECT
  city_id,
  SUM(in_contest) AS in_contest
  FROM city_points
  GROUP BY city_id
) AS scores
ON cities.id = scores.city_id;
