USE AdventureWorks2019
GO

--Show number of records returned for Product ID
SELECT ProductID, Count(*) AS RecordCount
FROM Sales.SalesOrderDetail
WHERE ProductID BETWEEN 732 AND 738
GROUP BY ProductID
GO

--Display Statistic information for the Sales.SalesOrderDetail table
DBCC SHOW_STATISTICS ('Sales.SalesOrderDetail', 'IX_SalesOrderDetail_ProductID')
WITH STAT_HEADER, HISTOGRAM
GO

--Show Actual Execution Plan
--When using literal value, the EQ_ROWS value is used.
SELECT ProductID
FROM Sales.SalesOrderDetail
WHERE ProductID = 732
GO

--Show Actual Execution Plan
--When using in a range, the AVG_RANGE_ROWS value is used.
SELECT ProductID
FROM Sales.SalesOrderDetail
WHERE ProductID = 733
GO


--Show Actual Execution Plan
--When using multiple values
SELECT ProductID
FROM Sales.SalesOrderDetail
WHERE ProductID IN(732, 736)
GO



--What about local variables?
--Value for ProductID is unknown at optimization, so uses density vector
--Total Rows (121,317) * Density Vector (0.003759399) = 456.079
DECLARE @ProductID int = 732

SELECT ProductID
FROM Sales.SalesOrderDetail
WHERE ProductID = @ProductID
GO


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







