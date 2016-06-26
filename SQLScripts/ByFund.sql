SELECT 
  Fund,
  SUM([Balance Forward]) AS [Balance Forward],
  SUM([YTD Debits]) AS [YTD Debits],
  SUM([YTD Credits]) AS [YTD Credits],
  SUM([Ending Balance]) AS [Ending Balance],
  SUM([Prior Year YTD Balance]) AS [Prior Year YTD Balance]
FROM(
    SELECT 
      Fund,
      -[Balance Forward] AS [Balance Forward],
      -[YTD Debits] AS [YTD Debits],
      -[YTD Credits] AS [YTD Credits],
      -[Ending Balance] AS [Ending Balance],
      -[Prior Year YTD Balance] AS [Prior Year YTD Balance]
    FROM 
      A2TBLOut
    WHERE 
      Fund<>"" 
      AND [Chart Section Level 1]="" 
      AND [Total Indicator]="Y"
      
    UNION ALL
      
    SELECT 
      Fund,
      [Balance Forward],
      [YTD Debits],
      [YTD Credits],
      [Ending Balance],
      [Prior Year YTD Balance] 
    FROM 
      A2TBLOut
    WHERE [Total Indicator]="N"
  ) AllRecords
GROUP BY 
  Fund
HAVING
  SUM([Balance Forward]) <> 0 OR
  SUM([YTD Debits]) <> 0 OR 
  SUM([YTD Credits]) <> 0 OR 
  SUM([Ending Balance]) <> 0 OR 
  SUM([Prior Year YTD Balance]) <> 0
