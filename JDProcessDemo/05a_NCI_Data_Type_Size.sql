--This script is used to see how data type choices effect NCI

USE [AdventureWorksDW2019];
GO

--Notice the Clustered Index on SalesOrderNumber
--Notice the Data Type for SalesOrderNumber

EXEC sp_help N'FactInternetSales';
EXEC sp_helpindex N'FactInternetSales';
GO

-- Create seven nonclustered indexes
--CREATE NONCLUSTERED INDEX [IX_FactInternetSales_CurrencyKey] 
--ON [dbo].[FactInternetSales] ([CurrencyKey]);
--GO

--CREATE NONCLUSTERED INDEX [IX_FactInternetSales_CustomerKey] 
--ON [dbo].[FactInternetSales] ([CustomerKey]);
--GO

--CREATE NONCLUSTERED INDEX [IX_FactInternetSales_DueDateKey] 
--ON [dbo].[FactInternetSales] ([DueDateKey]);
--GO

--CREATE NONCLUSTERED INDEX [IX_FactInternetSales_OrderDateKey] 
--ON [dbo].[FactInternetSales] ([OrderDateKey]);
--GO

--CREATE NONCLUSTERED INDEX [IX_FactInternetSales_ProductKey] 
--ON [dbo].[FactInternetSales] ([ProductKey]);
--GO

--CREATE NONCLUSTERED INDEX [IX_FactInternetSales_PromotionKey] 
--ON [dbo].[FactInternetSales] ([PromotionKey]);
--GO

--CREATE NONCLUSTERED INDEX [IX_FactInternetSales_ShipDateKey] 
--ON [dbo].[FactInternetSales] ([ShipDateKey]); 
--GO

-- Just in case fragmentation affects rows/pages
ALTER TABLE [dbo].[FactInternetSales] 
REBUILD;
GO

-- Create a duplicate of FactInternetSales 
IF OBJECTPROPERTY (OBJECT_ID (N'dbo.FactInternetSales2')
		, N'IsUserTable') = 1
	DROP TABLE [dbo].[FactInternetSales2];
GO

SELECT [ProductKey]
      ,[OrderDateKey]
      ,[DueDateKey]
      ,[ShipDateKey]
      ,[CustomerKey]
      ,[PromotionKey]
      ,[CurrencyKey]
      ,[SalesTerritoryKey]
      , CONVERT (INT, 
			SUBSTRING ([SalesOrderNumber], 3, 5) ) 
				AS [SalesOrderNumber]
      ,[SalesOrderLineNumber]
	  ,[RevisionNumber]
      ,[OrderQuantity]
      ,[UnitPrice]
      ,[ExtendedAmount]
      ,[UnitPriceDiscountPct]
      ,[DiscountAmount]
      ,[ProductStandardCost]
      ,[TotalProductCost]
      ,[SalesAmount]
      ,[TaxAmt]
      ,[Freight]
      ,[CarrierTrackingNumber]
      ,[CustomerPONumber]
      ,[OrderDate]
      ,[DueDate]
      ,[ShipDate]
INTO [dbo].[FactInternetSales2]
FROM [dbo].[FactInternetSales];
GO

-- Modify the newly created table to make it 
-- non-nullable (required for a PK) 
-- Change data type of [SalesOrderNumber] to an Integer data type
ALTER TABLE [dbo].[FactInternetSales2]
ALTER COLUMN [SalesOrderNumber] 
	INT NOT NULL;
GO

-- Create the clustered index
ALTER TABLE [dbo].[FactInternetSales2]
ADD CONSTRAINT [FactInternetSales2_PK] 
	PRIMARY KEY CLUSTERED 
		( [SalesOrderNumber] ASC,
		  [SalesOrderLineNumber] ASC );
GO

-- Create the seven nonclustered indexes to match original table

CREATE NONCLUSTERED INDEX [IX_FactInternetSales2_CurrencyKey] 
ON [dbo].[FactInternetSales2] ([CurrencyKey]);
GO

CREATE NONCLUSTERED INDEX [IX_FactInternetSales2_CustomerKey] 
ON [dbo].[FactInternetSales2] ([CustomerKey]);
GO

CREATE NONCLUSTERED INDEX [IX_FactInternetSales2_DueDateKey] 
ON [dbo].[FactInternetSales2] ([DueDateKey]);
GO

CREATE NONCLUSTERED INDEX [IX_FactInternetSales2_OrderDateKey] 
ON [dbo].[FactInternetSales2] ([OrderDateKey]);
GO

CREATE NONCLUSTERED INDEX [IX_FactInternetSales2_ProductKey] 
ON [dbo].[FactInternetSales2] ([ProductKey]);
GO

CREATE NONCLUSTERED INDEX [IX_FactInternetSales2_PromotionKey] 
ON [dbo].[FactInternetSales2] ([PromotionKey]);
GO

CREATE NONCLUSTERED INDEX [IX_FactInternetSales2_ShipDateKey] 
ON [dbo].[FactInternetSales2] ([ShipDateKey]); 
GO

EXEC sp_helpindex N'FactInternetSales';
EXEC sp_helpindex N'FactInternetSales2';
GO

-- Only 60,398 rows
SELECT TOP 100 * 
FROM [dbo].[FactInternetSales];

SELECT TOP 100 * 
FROM [dbo].[FactInternetSales2];
GO

--Compare space used between Clustered Index 
--on FactInternetSales (varchar)
--and FactInternetSales2 (int)
SELECT OBJECT_NAME ([si].[object_id]) AS [Table Name] 
	, [si].[name] AS [Index Name]
	, [ps].[index_id] AS [Index ID] 
	, [ps].[alloc_unit_type_desc] AS [Data Structure]
	, [ps].[page_count] AS [Pages]
	, [ps].[record_count] AS [Rows]
	, [ps].[min_record_size_in_bytes] AS [Min Row]
	, [ps].[max_record_size_in_bytes] AS [Max Row]
FROM [sys].[indexes] AS [si]
	CROSS APPLY sys.dm_db_index_physical_stats 
		(DB_ID ()
		, [si].[object_id]
		, NULL
		, NULL
		, N'DETAILED') AS [ps]
WHERE [si].[object_id] = [ps].[object_id]
		AND [si].[index_id] = [ps].[index_id]
		AND [si].[object_id] 
			IN (OBJECT_ID (N'FactInternetSales')
				, OBJECT_ID (N'FactInternetSales2'))
		AND [ps].[index_level] = 0
--		AND [ps].[index_id] = 1
ORDER BY [Table Name], [Index ID];
GO

-- Run code again but comment out [index_id] = 1
-- to display space used by non-clustered indexes

-- SO12345 (varchar) = 7 chars * 2 bytes per char = 14 bytes
-- 12345 (integer) = 4 bytes

-- Compare the total index amount using sp_spaceused
EXEC sp_spaceused N'FactInternetSales';
EXEC sp_spaceused N'FactInternetSales2';
GO
