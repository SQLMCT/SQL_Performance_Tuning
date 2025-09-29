--Demo setup
USE master;

--Build Database for Demo
DROP DATABASE IF EXISTS IOP_Demo;
CREATE DATABASE IOP_Demo ON PRIMARY
	(NAME = IOP_Demo,
	FILENAME = 'D:\DATA\IOP_DB.mdf')
LOG ON
	(NAME = IOP_Demo_Log, 
	FILENAME = 'D:\DATA\IOP_DB.ldf');
GO

USE IOP_Demo
GO
DROP TABLE IF EXISTS dbo.IndexOppTest
GO

SELECT *
INTO dbo.IndexOppTest
FROM AdventureWorks2019.Sales.SalesOrderHeader 
GO

--Create non-clustered index to speed up reads 
--Notice we are not creating a clustered index.
CREATE NONCLUSTERED INDEX jd_OrderID_OrderDate_demo
ON dbo.IndexOppTest(SalesOrderID, OrderDate)

CREATE NONCLUSTERED INDEX jd_OrderID_DueDate_demo
ON dbo.IndexOppTest(SalesOrderID, DueDate)

CREATE NONCLUSTERED INDEX jd_OrderID_ShipDate_demo
ON dbo.IndexOppTest(SalesOrderID, ShipDate)

CREATE NONCLUSTERED INDEX jd_OrderID_SalesOrderNumber_demo
ON dbo.IndexOppTest(SalesOrderID, SalesOrderNumber)

CREATE NONCLUSTERED INDEX jd_ModifiedDate_demo
ON dbo.IndexOppTest(ModifiedDate)

CREATE NONCLUSTERED INDEX jd_DueDate_ModifiedDate_demo
ON dbo.IndexOppTest(DueDate, ModifiedDate)

CREATE NONCLUSTERED INDEX jd_OrderID_ModifiedDate_demo
ON dbo.IndexOppTest(SalesOrderID, ModifiedDate)

CREATE NONCLUSTERED INDEX ix_OrderID_ModifiedDate_demo
ON dbo.IndexOppTest(SalesOrderID, ModifiedDate)

CREATE NONCLUSTERED INDEX nc_OrderID_ModifiedDate_demo
ON dbo.IndexOppTest(SalesOrderID, ModifiedDate)

CREATE NONCLUSTERED INDEX nc_OrderID_Include_ModifiedDate
ON dbo.IndexOppTest(SalesOrderID) INCLUDE (ModifiedDate)

--Look at the data! LOOK AT IT NOW!
SELECT SalesOrderID, OrderDate FROM dbo.IndexOppTest
WHERE SalesOrderID < 44658

--Get the current database id
USE IOP_Demo;
GO
SELECT DB_ID()
GO

-- List the indexes
EXEC [sp_helpindex] 'dbo.IndexOppTest';
GO

--Index operations before Updates and Deletes
SELECT database_id, i.name, o.object_id, o.index_id,  i.type_desc, hobt_id, 
	leaf_insert_count, leaf_delete_count, leaf_update_count, leaf_ghost_count
FROM  SYS.DM_DB_INDEX_OPERATIONAL_STATS (8,NULL,NULL,NULL ) AS O
	INNER JOIN SYS.INDEXES AS I
		ON I.[OBJECT_ID] = O.[OBJECT_ID] 
		AND I.INDEX_ID = O.INDEX_ID 
WHERE OBJECTPROPERTY(O.[OBJECT_ID],'IsUserTable') = 1

/*
--sys.dm_db_index_operational_stats (    
    { database_id | NULL | 0 | DEFAULT }    
  , { object_id | NULL | 0 | DEFAULT }    
  , { index_id | 0 | NULL | -1 | DEFAULT }    
  , { partition_number | NULL | 0 | DEFAULT }  )  
 */

--Perform some DML operations
UPDATE dbo.IndexOppTest
SET ModifiedDate = '03/25/2020'
WHERE SalesOrderID < 44658

DELETE dbo.IndexOppTest
WHERE SalesOrderID BETWEEN 44658 AND 45158

--Index operations after Updates and Deletes
SELECT database_id, i.name, o.object_id, o.index_id,  i.type_desc, hobt_id, 
	leaf_insert_count, leaf_delete_count, leaf_update_count, leaf_ghost_count
FROM  SYS.DM_DB_INDEX_OPERATIONAL_STATS (8,NULL,NULL,NULL ) AS O
	INNER JOIN SYS.INDEXES AS I
		ON I.[OBJECT_ID] = O.[OBJECT_ID] 
		AND I.INDEX_ID = O.INDEX_ID 
WHERE OBJECTPROPERTY(O.[OBJECT_ID],'IsUserTable') = 1

INSERT TOP (1) INTO dbo.IndexOppTest
SELECT [RevisionNumber],[OrderDate],[DueDate],[ShipDate],[Status],
       [OnlineOrderFlag],[SalesOrderNumber],[PurchaseOrderNumber],
       [AccountNumber],[CustomerID],[SalesPersonID],[TerritoryID],
       [BillToAddressID],[ShipToAddressID],[ShipMethodID],[CreditCardID],
       [CreditCardApprovalCode],[CurrencyRateID],[SubTotal],[TaxAmt],
       [Freight],[TotalDue],[Comment],[rowguid],[ModifiedDate]
FROM AdventureWorks2019.Sales.SalesOrderHeader 

--Create clustered index (Notice all the indexes get rebuilt.)
ALTER TABLE dbo.IndexOppTest
ADD CONSTRAINT pk_SalesOrderID PRIMARY KEY (SalesOrderID)

--Perform some DML operations again, but now with the Clustered Index
UPDATE dbo.IndexOppTest
SET ModifiedDate = '03/20/2020'
WHERE SalesOrderID < 44658

DELETE dbo.IndexOppTest
WHERE SalesOrderID BETWEEN 74623 AND 75123

--Index operations after Updates and Deletes
SELECT database_id, i.name, o.object_id, o.index_id,  i.type_desc, hobt_id, 
	leaf_insert_count, leaf_delete_count, leaf_update_count, leaf_ghost_count
FROM  SYS.DM_DB_INDEX_OPERATIONAL_STATS (8,NULL,NULL,NULL ) AS O
	INNER JOIN SYS.INDEXES AS I
		ON I.[OBJECT_ID] = O.[OBJECT_ID] 
		AND I.INDEX_ID = O.INDEX_ID 
WHERE OBJECTPROPERTY(O.[OBJECT_ID],'IsUserTable') = 1

--Start reading from Non-clustered indexes to compare usage vs updates.
SELECT *
FROM dbo.IndexOppTest
WHERE ModifiedDate = '03/20/2020'

SELECT * 
FROM dbo.IndexOppTest
WHERE SalesOrderID = 43800

SELECT * 
FROM dbo.IndexOppTest
WHERE SalesOrderNumber ='SO43800'

SELECT SalesOrderID, SalesOrderNumber
FROM dbo.IndexOppTest
WHERE SalesOrderNumber = 'SO43800'

---Check used and used indexes.
SELECT 
    i.index_id,
	indexname = i.name, 
    user_seeks, user_scans, user_lookups, user_updates,
    user_seeks + user_scans + user_lookups AS total_reads
FROM 
	sys.dm_db_index_usage_stats s
    RIGHT OUTER JOIN sys.indexes i 
		ON i.object_id = s.object_id AND i.index_id = s.index_id
    JOIN sys.objects o 
		ON o.object_id = i.object_id
    JOIN sys.schemas sc 
		ON sc.schema_id = o.schema_id
WHERE o.type = 'U' -- user table
    AND o.name = N'IndexOppTest';
GO

