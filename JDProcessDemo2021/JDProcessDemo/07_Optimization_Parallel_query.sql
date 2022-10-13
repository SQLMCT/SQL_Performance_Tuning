USE AdventureWorks2019;
GO
SET SHOWPLAN_XML ON;  
GO
--Execute the query in Adventureworks2019 database
SELECT sod.SalesOrderID, sod.OrderQty, 
p.ProductID, p.Name
FROM Production.Product p
INNER MERGE JOIN Sales.SalesOrderDetail sod
    ON sod.ProductID = p.ProductID    
    --OPTION (MAXDOP 3)
--open the XML plan and check: StatementSubTreeCost="6.62051".
--Look the execution plan for that proc
--The value is high. So query optimizer consider a parallel execution.


SET SHOWPLAN_XML ON;  
go
SELECT sod.SalesOrderID, sod.OrderQty, 
p.ProductID, p.Name
FROM Production.Product p
INNER MERGE JOIN Sales.SalesOrderDetail sod
    ON sod.ProductID = p.ProductID    
    OPTION (MAXDOP 1)
--open the XML plan and check: StatementSubTreeCost.
--the cost is even higher. But as you limit the execution to 1 CPU the optimizer has now choice. Parallelism is not possible
--Look the execution plan for that proc
-----------------------------------------------------------
--Join Order

-----------------------------------------------------------
----enable execution plan for both queries
--you will realize that doesn't matter the query join order. SQl Server optimizer will filter the data considering only the cost.
----------------------------------------------
--Clear Cache
SET SHOWPLAN_XML OFF;
GO
DBCC FREEPROCCACHE	
GO
SET SHOWPLAN_XML ON;
GO

--From tables with a small number of rows first
SELECT bc.[BusinessEntityID]
		, c.[Name]
		, p.[PersonType]
		, p.[NameStyle]
		, e.[NationalIDNumber]
FROM 		[Person].[ContactType] c  --20 rows
INNER JOIN [Person].[BusinessEntityContact] bc --20777 rows
	ON bc.[ContactTypeID] = c.[ContactTypeID]
INNER JOIN [HumanResources].[Employee] e --290 rows
	on e.[BusinessEntityID] = bc.[BusinessEntityID]
INNER JOIN [Person].[Person] p  --19972 rows
	on p.[BusinessEntityID] = bc.BusinessEntityID 

/* Compare Join order in the plan
	
	Query Order					Plan Order
		ContactType					Employee
		BusinessEntityContact		BusinessEntityContact
		Employee					Person
		Person						ContactType
*/

--Clear Cache
SET SHOWPLAN_XML OFF;
GO
DBCC FREEPROCCACHE	
GO
SET SHOWPLAN_XML ON;
GO
----------------------------------------------	
--From tables with a larger number of rows first
SELECT bc.[BusinessEntityID]
		, c.[Name]
		, p.[PersonType]
		, p.[NameStyle]
		, e.[NationalIDNumber]
FROM  [Person].[BusinessEntityContact] bc--20777 rows
INNER JOIN [Person].[Person] p--19972 rows
	on p.[BusinessEntityID] = bc.BusinessEntityID 
INNER JOIN [HumanResources].[Employee] e --290 rows
	on e.[BusinessEntityID] = bc.[BusinessEntityID]
INNER JOIN [Person].[ContactType] c --20 rows
	ON bc.[ContactTypeID] = c.[ContactTypeID]

	--THE SAME PLAN WAS GENERATED FOR BOTH


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