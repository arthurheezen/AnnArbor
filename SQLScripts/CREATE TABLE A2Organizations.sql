CREATE TABLE
  A2Organizations
AS SELECT
  OrganizationCode,
  OrganizationDesc
FROM
  A2OrganizationLimits
GROUP BY
  OrganizationCode,
  OrganizationDesc
