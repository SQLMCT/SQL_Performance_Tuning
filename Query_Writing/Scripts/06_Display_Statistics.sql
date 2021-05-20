USE AdventureWorks2016
GO

--Show Actual Execution Plan
SELECT ProductID
FROM Sales.SalesOrderDetail
WHERE ProductID = 732
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










