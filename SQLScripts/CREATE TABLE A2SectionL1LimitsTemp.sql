CREATE TABLE
  A2SectionL1LimitsTemp 
AS SELECT
  FundCode,
  SectionL1Code,
  SUM(SectionL1Start) AS SectionL1Start,
  SUM(SectionL1End) AS SectionL1End
FROM (
    SELECT
      FundLimits.FundCode AS FundCode,
      CodeEnd.SectionL1Code AS SectionL1Code,
      0 AS SectionL1Start,
      MAX(CodeEnd.VCumulativeMP) AS SectionL1End
    FROM (
        SELECT 
          FundStart, 
          FundEnd,
          FundCode
        FROM 
          A2FundLimits
      ) FundLimits
    INNER JOIN (
        SELECT 
          VCumulativeMP, 
          SectionL1Code
        FROM 
          A2TBLIn
        WHERE 
          Treatment="Section L1 Totals:"
      ) CodeEnd
    ON FundLimits.FundStart<=CodeEnd.VCumulativeMP
      AND FundLimits.FundEnd>=CodeEnd.VCumulativeMP
    GROUP BY
      FundLimits.FundCode,
      CodeEnd.SectionL1Code
    
    UNION ALL
    
    SELECT
      FundLimits.FundCode AS FundCode,
      CodeStart.SectionL1Code AS SectionL1Code,
      MIN(CodeStart.VCumulativeMP) AS SectionL1Start,
      0 AS SectionL1End
    FROM (
        SELECT 
          FundStart, 
          FundEnd,
          FundCode
        FROM 
          A2FundLimits
      ) FundLimits
    INNER JOIN (
        SELECT 
          VCumulativeMP, 
          SectionL1Code
        FROM 
          A2TBLIn
        WHERE 
          Treatment="Section L1 Code:"
      ) CodeStart
    ON FundLimits.FundStart<=CodeStart.VCumulativeMP
      AND FundLimits.FundEnd>=CodeStart.VCumulativeMP
    GROUP BY
      FundLimits.FundCode,
      CodeStart.SectionL1Code
  ) UnionSubquery
GROUP BY
  FundCode,
  SectionL1Code
ORDER BY
  FundCode,
  SUM(SectionL1Start),
  SUM(SectionL1End)
