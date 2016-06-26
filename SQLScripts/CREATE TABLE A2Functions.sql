CREATE TABLE
  A2Functions
AS SELECT
  FunctionCode,
  FunctionDesc
FROM
  A2FunctionLimits
GROUP BY
  FunctionCode,
  FunctionDesc
