USE WideWorldImportersDW
GO
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO

DROP PROCEDURE IF EXISTS [FactOrderByLineageKey];
GO
CREATE PROCEDURE [FactOrderByLineageKey]
	@LineageKey INT 
AS
SELECT   
	[fo].[Order Key], [fo].[Description] 
FROM    [Fact].[Order] AS [fo]
INNER HASH JOIN [Dimension].[Stock Item] AS [si] 
	ON [fo].[Stock Item Key] = [si].[Stock Item Key]
WHERE   [fo].[Lineage Key] = @LineageKey
	AND [si].[Lead Time Days] > 0
ORDER BY [fo].[Stock Item Key], [fo].[Order Date Key] DESC
OPTION (MAXDOP 1);
GO

-- IMPORTANT:  Click on Include Actual Execution Plan or press Ctrl+M

EXEC [FactOrderByLineageKey] 8;
GO

EXEC [FactOrderByLineageKey] 8;
GO

EXEC [FactOrderByLineageKey] 8;
GO

EXEC [FactOrderByLineageKey] 9;
GO

EXEC [FactOrderByLineageKey] 9;
GO
