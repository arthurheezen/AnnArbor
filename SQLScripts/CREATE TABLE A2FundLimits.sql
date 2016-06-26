CREATE TABLE
  A2FundLimits
AS SELECT
  MIN(Headers.VCumulativeMP) AS FundStart,
  SubTotalRanges.NextTotalMP AS FundEnd,
  Headers.GroupCode AS FundCode,
  Headers.GroupDesc AS FundDesc
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
          AND GroupName="Fund"
      ) NextTotal
    LEFT JOIN (
        SELECT 
          VCumulativeMP, 
          GroupCode
        FROM 
          A2TBLIn
        WHERE 
          Treatment="Modified Total:"
          AND GroupName="Fund"
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
      AND GroupName="Fund"
  ) Headers 
ON Headers.VCumulativeMP > SubTotalRanges.ThisTotalMP
  AND Headers.VCumulativeMP < SubTotalRanges.NextTotalMP
GROUP BY
  SubTotalRanges.NextTotalMP,
  Headers.GroupCode,
  Headers.GroupDesc
