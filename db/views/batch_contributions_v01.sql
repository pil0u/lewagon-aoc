WITH synced_user_numbers AS (
  SELECT CEIL(percentile_cont(0.5) WITHIN GROUP (ORDER BY value)) AS median
  FROM (
    SELECT COUNT(u.*) AS value
    FROM batches
    LEFT JOIN users AS u
    ON u.batch_id = batches.id
    WHERE u.synced
    GROUP BY batches.id
  ) AS synced_user_counts
)

SELECT
  co.id AS completion_id,
  CASE
    WHEN cr.in_batch <= (SELECT median FROM synced_user_numbers) THEN pv.in_contest
    ELSE 0
  END AS points

FROM completions co
LEFT JOIN point_values pv
ON pv.completion_id = co.id
LEFT JOIN completion_ranks cr
ON cr.completion_id = co.id
