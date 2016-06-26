CREATE TABLE
  A2ActivityLimits
AS SELECT
  MIN(Headers.VCumulativeMP) AS ActivityStart,
  SubTotalRanges.NextTotalMP AS ActivityEnd,
  Headers.GroupCode AS ActivityCode,
  Headers.GroupDesc AS ActivityDesc
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
          AND GroupName="Activity"
          
      ) NextTotal
    LEFT JOIN (
        SELECT 
          VCumulativeMP, 
          GroupCode
        FROM 
          A2TBLIn
        WHERE 
          Treatment="Modified Total:"
          AND GroupName="Activity"
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
      AND GroupName="Activity"
  ) Headers 
ON Headers.VCumulativeMP > SubTotalRanges.ThisTotalMP
  AND Headers.VCumulativeMP < SubTotalRanges.NextTotalMP
GROUP BY
  SubTotalRanges.NextTotalMP,
  Headers.GroupCode,
  Headers.GroupDesc
