INSERT INTO
  A2TBLTemp
SELECT
  TotalsRow.PageNum AS PageNum, 
  TotalsRow.LeftMP AS LeftMP, 
  PriorRow.LowerMP AS LowerMP, 
  TotalsRow.RightMP AS RightMP, 
  PriorRow.UpperMP AS UpperMP, 
  TotalsRow.WidthMP AS WidthMP, 
  PriorRow.HeightMP AS HeightMP, 
  PriorRow.VCumulativeMP AS VCumulativeMP, 
  TotalsRow.PDFString AS PDFString,
  TotalsRow.GroupName AS GroupName,
  TotalsRow.GroupCode AS GroupCode,
  TotalsRow.GroupDesc AS GroupDesc,
  TotalsRow.SectionL1Code AS SectionL1Code,
  TotalsRow.SectionL2Code AS SectionL2Code,
  TotalsRow.AccountCode AS AccountCode,
  TotalsRow.AccountDesc AS AccountDesc,
  TotalsRow.GrpSectTotal AS GrpSectTotal,
  TotalsRow.ColumnNum AS ColumnNum,           
  TotalsRow.NumberScale2 AS NumberScale2,           
  "Modified Total:" AS Treatment,
  TotalsRow.ThroughDate AS ThroughDate,
  NULL AS PriorRowRowID,
  TotalsRow.rowid AS MiscTotalsRowID
FROM (
    SELECT 
      rowid,
      *  
    FROM 
      A2TBLIn
    WHERE 
      Treatment="Merged Total:" OR Treatment="Group Totals:" OR Treatment="Grand Totals:"
  ) TotalsRow
INNER JOIN (
  SELECT
      rowid,
      *
    FROM 
      A2TBLIn 
    WHERE 
      ColumnNum="0"
  ) PriorRow
ON
  TotalsRow.VCumulativeMP > PriorRow.VCumulativeMP
  AND TotalsRow.VCumulativeMP-2000 <= PriorRow.VCumulativeMP;

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
