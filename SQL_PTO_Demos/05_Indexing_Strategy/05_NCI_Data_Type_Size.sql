--This script is used to see how data type choices effect NCI

USE [AdventureWorks2019];
GO

--Notice the Clustered Index on SalesOrderHeader table
--Notice the Data Type for SalesOrderID (int which is 4 bytes)

EXEC sp_help N'Sales.SalesOrderHeader';
EXEC sp_helpindex N'Sales.SalesOrderHeader';
GO

-- Just in case fragmentation affects rows/pages
ALTER TABLE Sales.SalesOrderHeader
REBUILD;
GO

-- Create a duplicate of SalesOrderHeader table
IF OBJECTPROPERTY (OBJECT_ID (N'Sales.SalesOrderHeader2')
		, N'IsUserTable') = 1
	DROP TABLE [Sales].[SalesOrderHeader2];
GO

--Create New table with Clustered Index on an nvarchar(50) field.
SELECT [SalesOrderNumber] --This is an nvarchar (50) field
	  ,[SalesOrderID]
      ,[RevisionNumber]
      ,[OrderDate]
      ,[DueDate]
      ,[ShipDate]
      ,[Status]
      ,[OnlineOrderFlag]
      ,[PurchaseOrderNumber]
      ,[AccountNumber]
      ,[CustomerID]
      ,[SalesPersonID]
      ,[TerritoryID]
      ,[BillToAddressID]
      ,[ShipToAddressID]
      ,[ShipMethodID]
      ,[CreditCardID]
      ,[CreditCardApprovalCode]
      ,[CurrencyRateID]
      ,[SubTotal]
      ,[TaxAmt]
      ,[Freight]
      ,[TotalDue]
      ,[Comment]
      ,[rowguid]
      ,[ModifiedDate]
INTO [Sales].[SalesOrderHeader2]
FROM [Sales].[SalesOrderHeader];
GO

-- Create the clustered index
ALTER TABLE [Sales].[SalesOrderHeader2]
ADD CONSTRAINT [PK_SalesOrderHeader_SalesOrderNumber] 
	PRIMARY KEY CLUSTERED 
		( [SalesOrderNumber] ASC);
GO


--Notice the Clustered Index on SalesOrderHeader2 table
--Notice the Data Type for SalesOrderNumber (nvarchar(50) which could be 100 bytes)

EXEC sp_help N'Sales.SalesOrderHeader2';
EXEC sp_helpindex N'Sales.SalesOrderHeader2';
GO

-- Create the nonclustered indexes to match original table
DROP INDEX IF EXISTS [AK_SalesOrderHeader_rowguid] ON [Sales].[SalesOrderHeader2];
CREATE UNIQUE NONCLUSTERED INDEX [AK_SalesOrderHeader_rowguid] ON [Sales].[SalesOrderHeader2]
([rowguid] ASC);
GO

DROP INDEX IF EXISTS [AK_SalesOrderHeader_SalesOrderNumber] ON [Sales].[SalesOrderHeader2];
CREATE UNIQUE NONCLUSTERED INDEX [AK_SalesOrderHeader_SalesOrderNumber] ON [Sales].[SalesOrderHeader2]([SalesOrderNumber] ASC);
GO

DROP INDEX IF EXISTS [IX_SalesOrderHeader_CustomerID] ON [Sales].[SalesOrderHeader2];
CREATE NONCLUSTERED INDEX [IX_SalesOrderHeader_CustomerID] ON [Sales].[SalesOrderHeader2]
([CustomerID] ASC);
GO

DROP INDEX IF EXISTS [IX_SalesOrderHeader_SalesPersonID] ON [Sales].[SalesOrderHeader2];
CREATE NONCLUSTERED INDEX [IX_SalesOrderHeader_SalesPersonID] ON [Sales].[SalesOrderHeader2]([SalesPersonID] ASC);
GO


EXEC sp_helpindex N'Sales.SalesOrderHeader';
EXEC sp_helpindex N'Sales.SalesOrderHeader2';
GO

-- Only 31,465 rows
SELECT *
FROM Sales.SalesOrderHeader;

SELECT *
FROM Sales.SalesOrderHeader2;
GO

--Compare space used between Clustered Index 
--on SalesOrderHeader (int) and SalesOrderHeader2 (varchar)
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
			IN (OBJECT_ID (N'Sales.SalesOrderHeader')
				, OBJECT_ID (N'Sales.SalesOrderHeader2'))
		AND [ps].[index_level] = 0
--		AND [ps].[index_id] = 1
ORDER BY [Table Name], [Index ID];
GO

-- Run code again but comment out [index_id] = 1
-- to display space used by non-clustered indexes

-- SO43659 (varchar) = 7 chars * 2 bytes per char = 14 bytes
-- 43659 (integer) = 4 bytes

-- Compare the total index amount using sp_spaceused
EXEC sp_spaceused N'Sales.SalesOrderHeader';
EXEC sp_spaceused N'Sales.SalesOrderHeader2';
GO
