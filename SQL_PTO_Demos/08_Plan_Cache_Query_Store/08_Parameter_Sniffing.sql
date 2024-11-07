USE AdventureWorks2019
GO

/*
-- Clean up from Query Store demo
	DROP INDEX IF EXISTS demo_ProductID__UnitPrice_OrderQty ON Sales.SalesOrderDetail;
	DROP INDEX IF EXISTS demo_ProductID__UnitPrice ON Sales.SalesOrderDetail;
	GO
*/

--ProductID 897 has 2 rows
--ProductID 945 has 257 rows
--ProductID 870 has 4688 rows

--Ad-Hoc Query
SELECT SalesOrderID, OrderQty
FROM Sales.SalesOrderDetail
WHERE ProductID = 897
GO
--DBCC FREEPROCCACHE
--DROP PROC IF EXISTS GET_ORDERID_ORDER_QTY

--Parameter Sniffing 897, 945, 870
CREATE OR ALTER PROC GET_ORDERID_ORDER_QTY
@PRODUCTID int
AS

SELECT SalesOrderID, OrderQty
FROM Sales.SalesOrderDetail
WHERE ProductID = @PRODUCTID
Option(Optimize FOR (@ProductID = 945))
--OPTION(Optimize FOR UNKNOWN)
GO

EXEC dbo.GET_ORDERID_ORDER_QTY 870

--DBCC FREEPROCCACHE


/* This Sample Code is provided for the purpose of illustration only and is not intended 
to be used in a production environment.  THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE 
PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR 
PURPOSE.  We grant You a nonexclusive, royalty-free right to use and modify the Sample Code
and to reproduce and distribute the object code form of the Sample Code, provided that You 
agree: (i) to not use Our name, logo, or trademarks to market Your software product in which
the Sample Code is embedded; (ii) to include a valid copyright notice on Your software product
in which the Sample Code is embedded; and (iii) to indemnify, hold harmless, and defend Us and
Our suppliers from and against any claims or lawsuits, including attorneys’ fees, that arise or 
result from the use or distribution of the Sample Code.
*/