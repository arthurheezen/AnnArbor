CREATE TABLE
  A2SectionL1Limits
AS 
  
  -- Start with L1 limits that are balanced (header and total are both present)
  SELECT 
    SectionL1Start,
    SectionL1End,
    SectionL1Code
  FROM   
    A2SectionL1LimitsTemp
  WHERE
   SectionL1Start<>0
   AND SectionL1End<>0
  
  UNION ALL
  
  -- Union L1 limits with no header/start
  SELECT 
    MAX(AllEnds.SectionL1End)+10801 AS SectionL1Start,
    NoSectionStart.SectionL1End, 
    NoSectionStart.SectionL1Code
  FROM (
      SELECT 
        SectionL1Code,
        SectionL1End
      FROM   
        A2SectionL1LimitsTemp
      WHERE
       SectionL1Start=0
    ) NoSectionStart
  INNER JOIN (
      SELECT 
        SectionL1End 
      FROM   
        A2SectionL1LimitsTemp
    ) AllEnds
  ON AllEnds.SectionL1End < NoSectionStart.SectionL1End
  GROUP BY
    NoSectionStart.SectionL1Code,
    NoSectionStart.SectionL1End
  
  UNION ALL
  
  -- Union L1 limits with no total/end
  SELECT 
    NoSectionEnd.SectionL1Start AS SectionL1Start, 
    MIN(AllStartsUnionFundTotals.SectionL1Start)-10800 AS SectionL1End,
    NoSectionEnd.SectionL1Code AS SectionL1Code
  FROM (
  
      SELECT 
        SectionL1Code,
        SectionL1Start
      FROM   
        A2SectionL1LimitsTemp
      WHERE
       SectionL1End = 0
       
    ) NoSectionEnd
    
  INNER JOIN (
      
      -- Starts of new sections
      SELECT 
        SectionL1Start 
      FROM   
        A2SectionL1LimitsTemp
      
      UNION ALL
      
      -- End of funds
      SELECT
        FundEnd AS SectionL1Start
      FROM
        A2FundLimits
        
    ) AllStartsUnionFundTotals
    
  ON NoSectionEnd.SectionL1Start < AllStartsUnionFundTotals.SectionL1Start
  GROUP BY
    NoSectionEnd.SectionL1Code,
    NoSectionEnd.SectionL1Start
