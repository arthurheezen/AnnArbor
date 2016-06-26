CREATE TABLE
  A2TBLOut
AS SELECT 
  IFNULL(qFundLimits.FundCode,"") AS [Fund], 
  IFNULL(qFundLimits.FundDesc,"") AS [Fund Description], 
  IFNULL(qSectionL1Limits.SectionL1Code,"") AS [Chart Section Level 1], 
  IFNULL(qSectionL2Limits.SectionL2Code,"") AS [Chart Section Level 2], 
  IFNULL(qAgencyLimits.AgencyCode,"") AS [Agency], 
  IFNULL(qAgencyLimits.AgencyDesc,"") AS [Agency Description], 
  IFNULL(qOrganizationLimits.OrganizationCode,"") AS [Organization], 
  IFNULL(qOrganizationLimits.OrganizationDesc,"") AS [Organization Description], 
  IFNULL(qActivityLimits.ActivityCode,"") AS [Activity], 
  IFNULL(qActivityLimits.ActivityDesc,"") AS [Activity Description], 
  IFNULL(qFunctionLimits.FunctionCode,"") AS [Function], 
  IFNULL(qFunctionLimits.FunctionDesc,"") AS [Function Description], 
  IFNULL(qAccountCode.AccountCode,"") AS [Account], 
  IFNULL(qAccountDesc.AccountDesc,"") AS [Account Description],
  IFNULL(qTotalIndicator.GrpSectTotal, "N") AS [Total Indicator],
  qBalanceForward.NumberScale2 AS [Balance Forward],
  qYTDDebits.NumberScale2 AS [YTD Debits],
  qYTDCredits.NumberScale2 AS [YTD Credits],
  qEndingBalance.NumberScale2 AS [Ending Balance],
  qPriorYearYTDBalance.NumberScale2 AS [Prior Year YTD Balance]
FROM (

  -- Output rows correlate to vertical positions with not-null columns
    SELECT
      VCumulativeMP
    FROM 
      A2TBLIn 
    WHERE 
      ColumnNum IS NOT NULL
    GROUP BY
      VCumulativeMP
  ) qRowsWithData
  
  -- Fund codes tagged using vertical positions
  LEFT JOIN (
    SELECT 
      FundStart, 
      FundEnd, 
      FundCode, 
      FundDesc 
    FROM 
      A2FundLimits
  ) qFundLimits
  ON qFundLimits.FundStart<=qRowsWithData.VCumulativeMP
    AND qFundLimits.FundEnd>=qRowsWithData.VCumulativeMP
  
  -- Chart of accounts section, first level, codes tagged using vertical positions
  LEFT JOIN (
    SELECT 
      SectionL1Start, 
      SectionL1End, 
      SectionL1Code 
    FROM 
      A2SectionL1Limits
  ) qSectionL1Limits
  ON qSectionL1Limits.SectionL1Start<=qRowsWithData.VCumulativeMP
    AND qSectionL1Limits.SectionL1End>=qRowsWithData.VCumulativeMP
  
  -- Chart of accounts section, second level, codes tagged using vertical positions
  LEFT JOIN (
    SELECT 
      SectionL2Start, 
      SectionL2End, 
      SectionL2Code 
    FROM 
      A2SectionL2Limits
  ) qSectionL2Limits
  ON qSectionL2Limits.SectionL2Start<=qRowsWithData.VCumulativeMP
    AND qSectionL2Limits.SectionL2End>=qRowsWithData.VCumulativeMP
  
  -- Agency codes tagged using vertical positions
  LEFT JOIN (
    SELECT 
      AgencyStart, 
      AgencyEnd, 
      AgencyCode, 
      AgencyDesc 
    FROM 
      A2AgencyLimits
  ) qAgencyLimits
  ON qAgencyLimits.AgencyStart<=qRowsWithData.VCumulativeMP
    AND qAgencyLimits.AgencyEnd>=qRowsWithData.VCumulativeMP
  
  -- Organization codes tagged using vertical positions
  LEFT JOIN (
    SELECT 
      OrganizationStart, 
      OrganizationEnd, 
      OrganizationCode, 
      OrganizationDesc 
    FROM 
      A2OrganizationLimits
  ) qOrganizationLimits
  ON qOrganizationLimits.OrganizationStart<=qRowsWithData.VCumulativeMP
    AND qOrganizationLimits.OrganizationEnd>=qRowsWithData.VCumulativeMP
  
  -- Activity codes tagged using vertical positions
  LEFT JOIN (
    SELECT 
    ActivityStart, 
    ActivityEnd, 
    ActivityCode, 
    ActivityDesc 
  FROM 
    A2ActivityLimits
  ) qActivityLimits
  ON qActivityLimits.ActivityStart<=qRowsWithData.VCumulativeMP
    AND qActivityLimits.ActivityEnd>=qRowsWithData.VCumulativeMP
  
  -- Function codes tagged using vertical positions
  LEFT JOIN (
    SELECT 
      FunctionStart, 
      FunctionEnd, 
      FunctionCode, 
      FunctionDesc 
    FROM 
      A2FunctionLimits
  ) qFunctionLimits
  ON qFunctionLimits.FunctionStart<=qRowsWithData.VCumulativeMP
    AND qFunctionLimits.FunctionEnd>=qRowsWithData.VCumulativeMP
  
  -- Account codes tagged using vertical positions
  LEFT JOIN (
    SELECT 
      VCumulativeMP, 
      AccountCode 
    FROM 
      A2TBLIn 
    WHERE 
      AccountCode IS NOT NULL) qAccountCode
  ON qRowsWithData.VCumulativeMP=qAccountCode.VCumulativeMP
  
  -- Account descriptions tagged using vertical positions
  LEFT JOIN (
    SELECT 
      VCumulativeMP, 
      AccountDesc 
    FROM 
      A2TBLIn 
    WHERE 
      AccountDesc IS NOT NULL
  ) qAccountDesc
  ON qRowsWithData.VCumulativeMP=qAccountDesc.VCumulativeMP
  
  -- Total indicator
  LEFT JOIN (
    SELECT 
      VCumulativeMP,
      GrpSectTotal      
    FROM 
      A2TBLIn 
    WHERE 
      GrpSectTotal IS NOT NULL
  ) qTotalIndicator
  ON qRowsWithData.VCumulativeMP=qTotalIndicator.VCumulativeMP
  
  -- Column 0 (Balance Forward) tagged using vertical positions
  LEFT JOIN (
    SELECT 
      VCumulativeMP,
      NumberScale2 
    FROM 
      A2TBLIn 
    WHERE 
      ColumnNum="0") qBalanceForward
  ON qRowsWithData.VCumulativeMP=qBalanceForward.VCumulativeMP
  
  -- Column 1 (YTD Debits) tagged using vertical positions
  LEFT JOIN (
    SELECT 
      VCumulativeMP, 
      NumberScale2 
    FROM 
      A2TBLIn 
    WHERE 
      ColumnNum="1") qYTDDebits
  ON qRowsWithData.VCumulativeMP=qYTDDebits.VCumulativeMP
  
  -- Column 2 (YTD Credits) tagged using vertical positions
  LEFT JOIN (
    SELECT 
      VCumulativeMP, 
      NumberScale2 
    FROM 
      A2TBLIn 
    WHERE 
      ColumnNum="2") qYTDCredits
  ON qRowsWithData.VCumulativeMP=qYTDCredits.VCumulativeMP
  
  -- Column 3 (Ending Balance) tagged using vertical positions
  LEFT JOIN (
    SELECT 
      VCumulativeMP, 
      NumberScale2 
    FROM 
      A2TBLIn 
    WHERE 
      ColumnNum="3") qEndingBalance
  ON qRowsWithData.VCumulativeMP=qEndingBalance.VCumulativeMP
  
  -- Column 4 (Prior Year YTD Balance) tagged using vertical positions
  LEFT JOIN (
    SELECT 
      VCumulativeMP, 
      NumberScale2 
    FROM 
      A2TBLIn 
    WHERE 
      ColumnNum="4") qPriorYearYTDBalance
  ON qRowsWithData.VCumulativeMP=qPriorYearYTDBalance.VCumulativeMP
  
ORDER BY
  qRowsWithData.VCumulativeMP
