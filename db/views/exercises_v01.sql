SELECT *
FROM generate_series(1,25) AS days(day)
NATURAL JOIN generate_series(1,2) AS challenges(challenge)
ORDER BY day, challenge;
