-- Check SSMS option "Actual Execution Plan"

-- Activate output to console
DBCC TRACEON (3604);
GO

USE AdventureWorks2019;
GO

/*
	Using Trace flag 8675 we can see details on which Stage and Phase
	of optimization is being used. This is an undocumented trace flag
	and should not be used in a production environment.
	Verify in Messages tab what was done in which optimization phase
	of the Query Optimizer after each execution

	The "end search(x)" values indicate the phase of the 
	Query Optimizer the query reached:
		- Transaction Processing (Phase 0)
		- Quick Plan (Phase 1)
		- Full Optimization (Phase 2)
			
	Also verify StatementOptmEarlyAbortReason and StatementOptmLevel 
	values in XML. Note that StatementOptmLevel only shows values
	TRIVIAL or FULL
*/

--Turn on Acutal Execution Plan (CTRL + M)
--Demonstrate Trivial Plan Example
SELECT * FROM Person.Person OPTION (RECOMPILE, QUERYTRACEON 8675); --Trivial
SELECT * FROM Person.Person WHERE LastName = 'Baker'
	OPTION (RECOMPILE, QUERYTRACEON 8675); --FULL
	

-- Example Phase 1
SELECT p.Name AS ProductName, 
NonDiscountSales = (OrderQty * UnitPrice),
Discounts = ((OrderQty * UnitPrice) * UnitPriceDiscount)
FROM Production.Product AS p 
INNER JOIN Sales.SalesOrderDetail AS sod ON p.ProductID = sod.ProductID 
ORDER BY ProductName DESC
OPTION (RECOMPILE, QUERYTRACEON 8675);
GO
/*
	The complexity of the query qualified it for Phase 1 optimization.
	At the end of Phase 1 optimization the best plan found had a cost 
	exceeding the current "cost threshold of parallelism (default of 5).
	So parallel plans where evaluated.

	There are two search(1) lines in the trace flag output. 
	The plan having the lower output (Serial vs Parallel) will be passed
	to Phase 2. In this example, the plan was immediately returned without 
	need to go to Full optimization. (We don't see search(2) in the output.)

--First end search is Serial plan, Second end search is Parallel Plan
--end search(1),  cost: 11.1698 tasks: 282 time: 0 net: 0 total: 0.004 net: 0.017
--end search(1),  cost: 4.64-47 tasks: 385 time: 0 net: 0 total: 0.005 net: 0.018
*/
-- Example 2 --Query Optimizer Time Out (Show Messages and Properties)
SELECT I.CustomerID, C.FirstName, C.LastName, A.AddressLine1, A.City,
SP.Name AS State, CR.Name AS CountryRegion
FROM Person.Person AS C
INNER JOIN Sales.SalesPerson AS CA ON CA.BusinessEntityID = C.BusinessEntityID
INNER JOIN Sales.SalesOrderHeader AS I ON CA.BusinessEntityID = I.SalesPersonID
INNER JOIN Person.Address AS A ON A.AddressID = I.BillToAddressID
INNER JOIN Person.StateProvince SP ON SP.StateProvinceID = A.StateProvinceID
INNER JOIN Person.CountryRegion CR ON CR.CountryRegionCode = SP.CountryRegionCode
ORDER BY I.CustomerID
OPTION (RECOMPILE, QUERYTRACEON 8675)
GO
--*** Optimizer time out abort at task 3492 ***
--https://docs.microsoft.com/en-us/archive/blogs/psssql/understanding-optimizer-timeout-and-how-complex-queries-can-be-affected-in-sql-server

--DMV with cumulative optimization information
SELECT counter, occurrence
FROM sys.dm_exec_query_optimizer_info
WHERE counter IN (N'optimizations', N'trivial plan', 
				  N'search 0', N'search 1', N'search 2', N'timeout');


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