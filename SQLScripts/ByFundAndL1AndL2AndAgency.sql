SELECT 
  Fund,
  [Chart Section Level 1],
  [Chart Section Level 2],
  SUM([Balance Forward]) AS [Balance Forward],
  SUM([YTD Debits]) AS [YTD Debits],
  SUM([YTD Credits]) AS [YTD Credits],
  SUM([Ending Balance]) AS [Ending Balance],
  SUM([Prior Year YTD Balance]) AS [Prior Year YTD Balance]
FROM(
    SELECT 
      Fund,
      [Chart Section Level 1],
      [Chart Section Level 2],
      -[Balance Forward] AS [Balance Forward],
      -[YTD Debits] AS [YTD Debits],
      -[YTD Credits] AS [YTD Credits],
      -[Ending Balance] AS [Ending Balance],
      -[Prior Year YTD Balance] AS [Prior Year YTD Balance]
    FROM 
      A2TBLOut
    WHERE 
      Fund <> "" 
      AND [Chart Section Level 1] <> "" 
      AND [Chart Section Level 2] <> "" 
      AND [Agency] = "" 
      AND [Total Indicator] = "Y"
      
    UNION ALL
      
    SELECT 
      Fund,
      [Chart Section Level 1],
      [Chart Section Level 2],
      [Balance Forward],
      [YTD Debits],
      [YTD Credits],
      [Ending Balance],
      [Prior Year YTD Balance] 
    FROM 
      A2TBLOut
    WHERE [Total Indicator]="N" AND
      [Chart Section Level 2] <> "" 
  ) AllRecords
GROUP BY 
  Fund,
  [Chart Section Level 1],
  [Chart Section Level 2]
HAVING
  SUM([Balance Forward]) <> 0 OR
  SUM([YTD Debits]) <> 0 OR 
  SUM([YTD Credits]) <> 0 OR 
  SUM([Ending Balance]) <> 0 OR 
  SUM([Prior Year YTD Balance]) <> 0
