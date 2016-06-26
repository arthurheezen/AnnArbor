CREATE TABLE
  A2SectionL2Limits
AS SELECT
  MIN(Headers.VCumulativeMP) AS SectionL2Start,
  SubTotalRanges.NextTotalMP AS SectionL2End,
  Headers.SectionL2Code AS SectionL2Code
FROM (
    SELECT
      IFNULL(MAX(ThisTotal.VCumulativeMP), 0) AS ThisTotalMP,
      NextTotal.VCumulativeMP AS NextTotalMP
    FROM (
        SELECT 
          VCumulativeMP, 
          SectionL2Code
        FROM 
          A2TBLIn
        WHERE 
          Treatment="Section L2 Totals:"
      ) NextTotal
    LEFT JOIN (
        SELECT 
          VCumulativeMP, 
          SectionL2Code
        FROM 
          A2TBLIn
        WHERE 
          Treatment="Section L2 Totals:"
      ) ThisTotal
    ON ThisTotal.VCumulativeMP<NextTotal.VCumulativeMP
    GROUP BY
      NextTotal.VCumulativeMP
  ) SubTotalRanges
INNER JOIN (
    SELECT 
      VCumulativeMP, 
      SectionL2Code
    FROM 
      A2TBLIn
    WHERE 
      Treatment="Section L2 Code:"
  ) Headers 
ON Headers.VCumulativeMP > SubTotalRanges.ThisTotalMP
  AND Headers.VCumulativeMP < SubTotalRanges.NextTotalMP
GROUP BY
  SubTotalRanges.NextTotalMP,
  Headers.SectionL2Code
