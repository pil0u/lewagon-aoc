SELECT
  day,
  cities.id AS city_id,
  COALESCE(in_contest, 0) AS in_contest,
  rank() OVER (ORDER BY in_contest DESC NULLS LAST) AS rank_in_contest
FROM cities
LEFT JOIN (
  SELECT
  day,
  city_id,
  SUM(in_contest) AS in_contest
  FROM city_points
  GROUP BY city_id, day
) AS scores
ON cities.id = scores.city_id;
