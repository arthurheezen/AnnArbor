CREATE TABLE
  A2FunctionLimits
AS SELECT
  MIN(Headers.VCumulativeMP) AS FunctionStart,
  SubTotalRanges.NextTotalMP AS FunctionEnd,
  Headers.GroupCode AS FunctionCode,
  Headers.GroupDesc AS FunctionDesc
FROM (
    SELECT
      IFNULL(MAX(ThisTotal.VCumulativeMP), 0) AS ThisTotalMP,
      NextTotal.VCumulativeMP AS NextTotalMP
    FROM (
        SELECT 
          VCumulativeMP, 
          GroupCode
        FROM 
          A2TBLIn
        WHERE 
          Treatment="Modified Total:"
          AND GroupName="Function"
      ) NextTotal
    LEFT JOIN (
        SELECT 
          VCumulativeMP, 
          GroupCode
        FROM 
          A2TBLIn
        WHERE 
          Treatment="Modified Total:"
          AND GroupName="Function"
      ) ThisTotal
    ON ThisTotal.VCumulativeMP<NextTotal.VCumulativeMP
    GROUP BY
      NextTotal.VCumulativeMP
  ) SubTotalRanges
INNER JOIN (
    SELECT 
      VCumulativeMP, 
      GroupCode,
      GroupDesc
    FROM 
      A2TBLIn
    WHERE 
      Treatment="Group Header:"
      AND GroupName="Function"
  ) Headers 
ON Headers.VCumulativeMP > SubTotalRanges.ThisTotalMP
  AND Headers.VCumulativeMP < SubTotalRanges.NextTotalMP
GROUP BY
  SubTotalRanges.NextTotalMP,
  Headers.GroupCode,
  Headers.GroupDesc
