SELECT
  batch_id AS batch_id,
  score,
  dense_rank() OVER (ORDER BY score DESC) AS rank
FROM (
  SELECT
  batch_id AS batch_id,
  SUM(points) AS score
  FROM batch_points
  GROUP BY batch_id
) AS scores;
