-- Validate totals by fund

-- Total numeric fields
SELECT 
  Fund,
  SUM([Balance Forward]) AS [Error in Balance Forward Totals],
  SUM([YTD Debits]) AS [Error in YTD Debits Totals],
  SUM([YTD Credits]) AS [Error in YTD Credits Totals],
  SUM([Ending Balance]) AS [Error in Ending Balance Totals],
  SUM([Prior Year YTD Balance]) AS [Error in Prior Year YTD Balance Totals],
  ABS(SUM([Balance Forward]))
  + ABS(SUM([YTD Debits]))
  + ABS(SUM([YTD Credits]))
  + ABS(SUM([Ending Balance]))
  + ABS(SUM([Prior Year YTD Balance]))
      AS [Total Deviation]

-- Negate totals and union with raw records
FROM(
    
    -- Totals
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
    
    -- All non-total records
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
