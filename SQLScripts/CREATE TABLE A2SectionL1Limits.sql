CREATE TABLE
  A2SectionL1Limits
AS SELECT 
  SectionL1Start,
  SectionL1End,
  SectionL1Code
FROM   
  A2SectionL1LimitsTemp
WHERE
 SectionL1Start<>0
 AND SectionL1End<>0

UNION ALL

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

SELECT 
  NoSectionEnd.SectionL1Start AS SectionL1Start, 
  MIN(AllStarts.SectionL1Start)-10801 AS SectionL1End,
  NoSectionEnd.SectionL1Code AS SectionL1Code
FROM (
    SELECT 
      SectionL1Code,
      SectionL1Start
    FROM   
      A2SectionL1LimitsTemp
    WHERE
     SectionL1End=0
  ) NoSectionEnd
INNER JOIN (
    SELECT 
      SectionL1Start 
    FROM   
      A2SectionL1LimitsTemp
  ) AllStarts
ON NoSectionEnd.SectionL1Start < AllStarts.SectionL1Start
GROUP BY
  NoSectionEnd.SectionL1Code,
  NoSectionEnd.SectionL1Start
