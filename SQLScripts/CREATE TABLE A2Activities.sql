CREATE TABLE
  A2Activities
AS SELECT
  ActivityCode,
  ActivityDesc
FROM
  A2ActivityLimits
GROUP BY
  ActivityCode,
  ActivityDesc
