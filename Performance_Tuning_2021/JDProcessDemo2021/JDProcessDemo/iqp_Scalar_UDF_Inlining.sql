USE WideWorldImportersDW
GO

/* First let's see how much each customer spends. */
SELECT c.[Customer Key], SUM(oh.[Total Including Tax]) as total_spend
FROM [Fact].[OrderHistory] oh
JOIN [Dimension].[Customer] c 
ON oh.[Customer Key] = c.[Customer Key]
GROUP BY c.[Customer Key]
ORDER BY total_spend DESC
GO

-- Create a UDF to set Customer category based on amount spent.
CREATE OR ALTER FUNCTION [Dimension].[customer_category](@CustomerKey INT) 
RETURNS CHAR(10) AS
BEGIN
DECLARE @total_amount DECIMAL(18,2);
DECLARE @category CHAR(10);

SELECT @total_amount = 	SUM([Total Including Tax]) 
FROM [Fact].[OrderHistory]
WHERE [Customer Key] = @CustomerKey

IF @total_amount <= 3000000
	SET @category = 'REGULAR'
ELSE IF @total_amount < 4500000
	SET @category = 'GOLD'
ELSE 
	SET @category = 'PLATINUM'

RETURN @category
END
GO
-- End Function Creation


DBCC DROPCLEANBUFFERS
GO
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE
GO

-- IMPORTANT:  Click on Include Actual Execution Plan or press Ctrl+M
SET STATISTICS TIME ON
SELECT    [Customer Key]
		, [Customer]
		, [Dimension].[customer_category]([Customer Key]) AS [Discount Price]
FROM [Dimension].[Customer]
ORDER BY [Customer Key]
OPTION (USE HINT('DISABLE_TSQL_SCALAR_UDF_INLINING'))
SET STATISTICS TIME OFF
GO

DBCC DROPCLEANBUFFERS
GO
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE
GO

SET STATISTICS TIME ON
SELECT    [Customer Key]
		, [Customer]
		, [Dimension].[customer_category]([Customer Key]) AS [Discount Price]
FROM [Dimension].[Customer]
ORDER BY [Customer Key]
SET STATISTICS TIME OFF
GO









