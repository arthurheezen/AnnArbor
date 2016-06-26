CREATE TABLE
  A2Funds
AS SELECT
  FundCode,
  FundDesc
FROM
  A2FundLimits
GROUP BY
  FundCode,
  FundDesc
