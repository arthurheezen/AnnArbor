CREATE TABLE
  A2OrganizationLimits
AS SELECT
  MIN(Headers.VCumulativeMP) AS OrganizationStart,
  SubTotalRanges.NextTotalMP AS OrganizationEnd,
  Headers.GroupCode AS OrganizationCode,
  Headers.GroupDesc AS OrganizationDesc
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
          AND GroupName="Organization"
      ) NextTotal
    LEFT JOIN (
        SELECT 
          VCumulativeMP, 
          GroupCode
        FROM 
          A2TBLIn
        WHERE 
          Treatment="Modified Total:"
          AND GroupName="Organization"
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
      AND GroupName="Organization"
  ) Headers 
ON Headers.VCumulativeMP > SubTotalRanges.ThisTotalMP
  AND Headers.VCumulativeMP < SubTotalRanges.NextTotalMP
GROUP BY
  SubTotalRanges.NextTotalMP,
  Headers.GroupCode,
  Headers.GroupDesc
