SELECT
  day,
  batches.id AS batch_id,
  COALESCE(in_contest, 0) AS in_contest,
  rank() OVER (PARTITION BY scores.day ORDER BY in_contest DESC NULLS LAST) AS rank_in_contest
FROM batches
LEFT JOIN (
  SELECT
  day,
  batch_id,
  SUM(in_contest) AS in_contest
  FROM batch_points
  GROUP BY batch_id, day
) AS scores
ON batches.id = scores.batch_id;
