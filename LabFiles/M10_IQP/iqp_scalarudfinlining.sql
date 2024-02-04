USE WideWorldImportersDW
GO

SELECT c.[Customer Key], SUM(oh.[Total Including Tax]) as total_spend
FROM [Fact].[OrderHistory] oh
JOIN [Dimension].[Customer] c 
ON oh.[Customer Key] = c.[Customer Key]
GROUP BY c.[Customer Key]
ORDER BY total_spend DESC
GO

-- begin function creation
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
-- end function creation


DBCC DROPCLEANBUFFERS
GO
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE
GO

-- IMPORTANT:  Click on Include Actual Execution Plan or press Ctrl+M

SELECT    [Customer Key]
		, [Customer]
		, [Dimension].[customer_category]([Customer Key]) AS [Discount Price]
FROM [Dimension].[Customer]
ORDER BY [Customer Key]
OPTION (USE HINT('DISABLE_TSQL_SCALAR_UDF_INLINING'))
GO

DBCC DROPCLEANBUFFERS
GO
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE
GO

SELECT    [Customer Key]
		, [Customer]
		, [Dimension].[customer_category]([Customer Key]) AS [Discount Price]
FROM [Dimension].[Customer]
ORDER BY [Customer Key]
GO

DBCC DROPCLEANBUFFERS
GO
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE
GO

SET STATISTICS IO ON

SELECT    [Customer Key]
		, [Customer]
		, [Dimension].[customer_category]([Customer Key]) AS [Discount Price]
FROM [Dimension].[Customer]
where [Customer Key] = 149
OPTION (USE HINT('DISABLE_TSQL_SCALAR_UDF_INLINING'))
GO

DBCC DROPCLEANBUFFERS
GO
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE
GO

SELECT    [Customer Key]
		, [Customer]
		, [Dimension].[customer_category]([Customer Key]) AS [Discount Price]
FROM [Dimension].[Customer]
where [Customer Key] = 149
GO

sp_helpindex 'Fact.OrderHistory'
GO    

CREATE NONCLUSTERED INDEX [ix_OrderHistory_CustomerKey] 
ON [Fact].[OrderHistory] ([Customer Key] ASC)
GO

SELECT    [Customer Key]
		, [Customer]
		, [Dimension].[customer_category]([Customer Key]) AS [Discount Price]
FROM [Dimension].[Customer]
where [Customer Key] = 149
GO