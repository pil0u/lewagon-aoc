CREATE OR REPLACE FUNCTION max_allowed_contributors_in_city() RETURNS integer AS $body$
SELECT GREATEST(3, CEIL(percentile_cont(0.5) WITHIN GROUP (ORDER BY value))::int) AS median
FROM (
  SELECT COUNT(u.*) AS value
  FROM cities
  LEFT JOIN users AS u
  ON u.city_id = cities.id
  WHERE u.synced
  GROUP BY cities.id
) AS synced_user_counts

$body$
STABLE
LANGUAGE SQL;
