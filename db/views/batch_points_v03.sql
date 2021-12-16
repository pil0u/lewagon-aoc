SELECT
  batch_id,
  day,
  challenge,

  SUM(bc.in_contest)::integer AS in_contest,
  rank() OVER (PARTITION BY day, challenge ORDER BY SUM(in_contest) DESC) AS rank_in_contest,

  COUNT(*) FILTER (WHERE participated) AS participating_users,
  COUNT(*) FILTER (WHERE participated) >= (VALUES (max_allowed_contributors_in_batch())) AS complete,
  (VALUES (max_allowed_contributors_in_batch())) - COUNT(*) FILTER (WHERE participated) AS remaining_contributions

FROM batch_contributions AS bc
GROUP BY batch_id, day, challenge;
