SELECT
  batches.id AS batch_id,
  COALESCE(in_contest, 0),
  dense_rank() OVER (ORDER BY in_contest DESC NULLS LAST) AS rank_in_contest
FROM batches
LEFT JOIN (
  SELECT
  batch_id,
  SUM(in_contest) AS in_contest
  FROM batch_points
  GROUP BY batch_id
) AS scores
ON batches.id = scores.batch_id;
