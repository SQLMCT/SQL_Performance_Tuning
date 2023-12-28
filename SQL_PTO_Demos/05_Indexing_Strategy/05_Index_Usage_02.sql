SET NOCOUNT ON;
GO
USE AdventureWorks2019;
GO

/* Run 05_Index_Usage_01 after each of the following queries */ 

SELECT * 
FROM Sales.SalesOrderHeader 
WHERE SalesOrderID = 43800
-- Check increase for USER_Seeks on PK_SalesOrderHeader_SalesOrderID

SELECT * 
FROM Sales.SalesOrderHeader 
WHERE SalesOrderNumber ='SO43800'
-- Check increase for USER_Seeks on AK_SalesOrderHeader_SalesOrderNumber
-- and increase for Lookup on PK_SalesOrderHeader_SalesOrderID

SELECT SalesOrderID, SalesOrderNumber
FROM Sales.SalesOrderHeader 
WHERE SalesOrderNumber = 'SO43800'
-- Check increase for USER_Seeks on AK_SalesOrderHeader_SalesOrderNumber
-- and NO increase for Lookup on PK_SalesOrderHeader_SalesOrderID

SELECT *
FROM Sales.SalesOrderHeader 
WHERE CustomerID = 21710
-- Check increase for USER_Seeks on IX_SalesOrderHeader_CustomerID
-- and increase for Lookup on PK_SalesOrderHeader_SalesOrderID

Declare @RowGuid as UNIQUEIDENTIFIER  = '46CD4997-1031-482B-8EAB-4F1FECCCBEE1'
UPDATE Sales.SalesOrderHeader
SET ModifiedDate = getdate()
WHERE rowguid = @RowGuid

-- Check increase for USER_Seeks on AK_SalesOrderHeader_rowguid
-- and increase for user_updates on PK_SalesOrderHeader_SalesOrderID

SELECT *
FROM Sales.SalesOrderHeader 
WHERE RevisionNumber=8
-- Check increase for USER_Scans on PK_SalesOrderHeader_SalesOrderID

SELECT SalesPersonID, COUNT(*)
FROM Sales.SalesOrderHeader 
GROUP BY SalesPersonID
-- Check increase for USER_Scans on IX_SalesOrderHeader_SalesPersonID

SELECT *
FROM Sales.SalesOrderHeader 
WHERE SalesPersonID=285
-- Check increase for USER_Seeks on IX_SalesOrderHeader_SalesPersonID
-- and increase for USER_lookups on PK_SalesOrderHeader_SalesOrderID

-- What about a delete statement?
DELETE Sales.SalesOrderHeader 
WHERE SalesPersonID=285


/*
This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.  
THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  
We grant You a nonexclusive, royalty-free right to use and modify the 
Sample Code and to reproduce and distribute the object code form of the Sample Code, provided that You agree: (i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded; 
(ii) to include a valid copyright notice on Your software product in which the Sample Code is 
embedded; and 
(iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys’ fees, that arise or result from the use or distribution of the Sample Code.
Please note: None of the conditions outlined in the disclaimer above will supercede the terms and conditions contained within the Premier Customer Services Description.
*/