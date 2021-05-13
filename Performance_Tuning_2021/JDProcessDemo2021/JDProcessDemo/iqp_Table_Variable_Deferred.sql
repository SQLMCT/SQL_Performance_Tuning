USE WideWorldImportersDW
GO

CREATE OR ALTER PROCEDURE Fact.OrderPrices
AS
BEGIN
	DECLARE @Order TABLE 
		([Order Key] BIGINT NOT NULL,
		 [Quantity] INT NOT NULL
		)

	INSERT @Order
	SELECT [Order Key], [Quantity]
	FROM [Fact].[OrderHistory]

	SELECT top 10 oh.[Order Key], oh.[Order Date Key],oh.[Unit Price], o.Quantity
	FROM Fact.OrderHistoryExtended AS oh
	INNER JOIN @Order AS o
	ON o.[Order Key] = oh.[Order Key]
	WHERE oh.[Unit Price] > 0.10
	ORDER BY oh.[Unit Price] DESC
END
GO

ALTER DATABASE WideWorldImportersDW SET COMPATIBILITY_LEVEL = 140
GO

DBCC DROPCLEANBUFFERS
GO
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE
GO

-- IMPORTANT:  Click on Include Actual Execution Plan or press Ctrl+M

EXEC Fact.OrderPrices
GO 3

ALTER DATABASE WideWorldImportersDW SET COMPATIBILITY_LEVEL = 150
GO

DBCC DROPCLEANBUFFERS
GO
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE
GO

EXEC Fact.OrderPrices
GO 3