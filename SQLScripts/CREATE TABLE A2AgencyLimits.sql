CREATE TABLE
  A2AgencyLimits
AS SELECT
  MIN(Headers.VCumulativeMP) AS AgencyStart,
  SubTotalRanges.NextTotalMP AS AgencyEnd,
  Headers.GroupCode AS AgencyCode,
  Headers.GroupDesc AS AgencyDesc
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
          AND GroupName="Agency"
      ) NextTotal
    LEFT JOIN (
        SELECT 
          VCumulativeMP, 
          GroupCode
        FROM 
          A2TBLIn
        WHERE 
          Treatment="Modified Total:"
          AND GroupName="Agency"
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
      AND GroupName="Agency"
  ) Headers 
ON Headers.VCumulativeMP > SubTotalRanges.ThisTotalMP
  AND Headers.VCumulativeMP < SubTotalRanges.NextTotalMP
GROUP BY
  SubTotalRanges.NextTotalMP,
  Headers.GroupCode,
  Headers.GroupDesc
