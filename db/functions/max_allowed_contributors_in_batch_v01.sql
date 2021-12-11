CREATE OR REPLACE FUNCTION max_allowed_contributors_in_batch() RETURNS integer AS $body$
SELECT GREATEST(3, CEIL(percentile_cont(0.5) WITHIN GROUP (ORDER BY value))::int) AS median
FROM (
  SELECT COUNT(u.*) AS value
  FROM batches
  LEFT JOIN users AS u
  ON u.batch_id = batches.id
  WHERE u.synced
  GROUP BY batches.id
) AS synced_user_counts

$body$
STABLE
LANGUAGE SQL;
