INSERT INTO
  A2TBLTemp
SELECT
  PriorRow.PageNum AS PageNum, 
  PriorRow.LeftMP AS LeftMP, 
  PriorRow.LowerMP AS LowerMP, 
  PriorRow.RightMP AS RightMP, 
  PriorRow.UpperMP AS UpperMP, 
  PriorRow.WidthMP AS WidthMP, 
  PriorRow.HeightMP AS HeightMP, 
  PriorRow.VCumulativeMP AS VCumulativeMP, 
  PriorRow.PDFString || MiscTotals.PDFString AS PDFString,
  PriorRow.GroupName AS GroupName,
  PriorRow.GroupCode AS GroupCode,
  PriorRow.GroupDesc || IFNULL(MiscTotals.GroupDesc, "") AS GroupDesc,
  PriorRow.SectionL1Code AS SectionL1Code,
  PriorRow.SectionL2Code AS SectionL2Code,
  PriorRow.AccountCode AS AccountCode,
  PriorRow.AccountDesc AS AccountDesc,
  "Y" AS GrpSectTotal,
  PriorRow.ColumnNum AS ColumnNum,           
  PriorRow.NumberScale2 AS NumberScale2,           
  "Merged Total:" AS Treatment,
  PriorRow.ThroughDate AS ThroughDate,
  PriorRow.rowid AS PriorRowRowID,
  MiscTotals.rowid AS MiscTotalsRowID
FROM (
    SELECT 
      rowid,
      PDFString,
      VCumulativeMP,
      Treatment,    
      GroupDesc  
    FROM 
      A2TBLIn
    WHERE 
      Treatment="Misc Totals:"
  ) MiscTotals
INNER JOIN (
    SELECT 
      rowid,
      *
    FROM 
      A2TBLIn 
    WHERE 
      RightMP <= 231000
  ) PriorRow
ON
  MiscTotals.VCumulativeMP > PriorRow.VCumulativeMP
  AND MiscTotals.VCumulativeMP-10000 <= PriorRow.VCumulativeMP;

DELETE FROM
  A2TBLIn
WHERE rowid IN (
  SELECT
    PriorRowRowID
  FROM 
    A2TBLTemp);

DELETE FROM
  A2TBLIn
WHERE rowid IN (
  SELECT
    MiscTotalsRowID
  FROM 
    A2TBLTemp);

INSERT INTO
  A2TBLIn
SELECT
  PageNum, 
  LeftMP, 
  LowerMP, 
  RightMP, 
  UpperMP, 
  WidthMP, 
  HeightMP, 
  VCumulativeMP, 
  PDFString,
  GroupName,
  GroupCode,
  GroupDesc,
  SectionL1Code,
  SectionL2Code,
  AccountCode,
  AccountDesc,
  GrpSectTotal,
  ColumnNum,           
  NumberScale2,           
  Treatment,
  ThroughDate
FROM
  A2TBLTemp;

DELETE FROM
  A2TBLTemp;
