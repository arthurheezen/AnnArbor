CREATE TABLE 
  A2Agencies
AS SELECT
  AgencyCode,
  AgencyDesc
FROM
  A2AgencyLimits
GROUP BY
  AgencyCode,
  AgencyDesc
