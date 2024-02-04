USE AdventureWorksPTO;
GO

SET STATISTICS IO ON;

-- IMPORTANT: Click on Include Actual Execution Plan or press Ctrl+M

-- 1st query

SELECT *
FROM Production.WorkOrder wo
     INNER JOIN Production.WorkOrderRouting wor 
		ON wo.WorkOrderID = wor.WorkOrderID
WHERE wor.ModifiedDate = CAST('2011-08-01' AS DATETIME);
GO

sp_helpindex 'Production.WorkOrderRouting'
GO

CREATE NONCLUSTERED INDEX [ix_WorkOrderRouting_ModifiedDate] 
ON [Production].[WorkOrderRouting] ([ModifiedDate] ASC)
GO

SELECT *
FROM Production.WorkOrder wo
     INNER JOIN Production.WorkOrderRouting wor 
		ON wo.WorkOrderID = wor.WorkOrderID
WHERE wor.ModifiedDate = CAST('2011-08-01' AS DATETIME);
GO

-- 2nd query

SELECT p.FirstName, p.LastName, e.EmailAddress
FROM Person.Person p
     INNER JOIN Person.EmailAddress e 
		ON e.BusinessEntityID = p.BusinessEntityID
WHERE e.ModifiedDate > CAST('2011-08-01' AS DATETIME);
GO

sp_helpindex 'Person.Person'
GO 

sp_helpindex 'Person.EmailAddress'
GO 

SELECT p.FirstName, p.LastName, e.EmailAddress
FROM Person.Person p
     INNER JOIN Person.EmailAddress e 
		ON e.BusinessEntityID = p.BusinessEntityID
WHERE e.ModifiedDate > CAST('2011-08-01' AS DATETIME);
GO

sp_helpindex 'Person.EmailAddress'
GO 

CREATE NONCLUSTERED INDEX [ix_EmailAddress_ModifiedDate] 
ON [Person].[EmailAddress]
([ModifiedDate] ASC) INCLUDE ([EmailAddress])
GO

SELECT p.FirstName, p.LastName, e.EmailAddress
FROM Person.Person p
     INNER JOIN Person.EmailAddress e 
		ON e.BusinessEntityID = p.BusinessEntityID
WHERE e.ModifiedDate > CAST('2011-08-01' AS DATETIME);
GO

CREATE INDEX ix_Person_BusinessEntityID
ON Person.Person ( BusinessEntityID )
INCLUDE ( FirstName, LastName );
GO

SELECT p.FirstName, p.LastName, e.EmailAddress
FROM Person.Person p
     INNER JOIN Person.EmailAddress e 
		ON e.BusinessEntityID = p.BusinessEntityID
WHERE e.ModifiedDate > CAST('2011-08-01' AS DATETIME);
GO

DROP INDEX [ix_EmailAddress_ModifiedDate]  ON Person.EmailAddress;
GO

-- 3rd query 

SELECT CONCAT(p.Title, p.FirstName, p.LastName, ' ') AS FullName
     , c.AccountNumber
	 , s.Name
FROM Person.Person AS p
     INNER JOIN Sales.Customer AS c 
		ON c.PersonID = p.BusinessEntityID
     INNER JOIN Sales.Store AS s 
		ON s.BusinessEntityID = c.StoreID
WHERE p.LastName = N'Koski';
GO

sp_helpindex 'Sales.Customer'
GO 

CREATE INDEX ix_Customer_PersonID 
ON Sales.Customer (PersonID) 
GO

SELECT CONCAT(p.Title, p.FirstName, p.LastName, ' ') AS FullName
     , c.AccountNumber
	 , s.Name
FROM Person.Person AS p
     INNER JOIN Sales.Customer AS c 
		ON c.PersonID = p.BusinessEntityID
     INNER JOIN Sales.Store AS s 
		ON s.BusinessEntityID = c.StoreID
WHERE p.LastName = N'Koski';
GO

CREATE INDEX ix_Customer_PersonID 
ON Sales.Customer (PersonID) 
INCLUDE (StoreID) 
WITH (DROP_EXISTING = ON)
GO

CREATE INDEX IX_Person_LastName_FirstName_MiddleName 
ON Person.Person (LastName, FirstName, MiddleName ) 
INCLUDE (Title) 
WITH (DROP_EXISTING = ON)
GO

SELECT CONCAT(p.Title, p.FirstName, p.LastName, ' ') AS FullName
     , c.AccountNumber
	 , s.Name
FROM Person.Person AS p
     INNER JOIN Sales.Customer AS c 
		ON c.PersonID = p.BusinessEntityID
     INNER JOIN Sales.Store AS s 
		ON s.BusinessEntityID = c.StoreID
WHERE p.LastName = N'Koski';
GO

-- Clean up
DROP INDEX [ix_WorkOrderRouting_ModifiedDate] ON [Production].[WorkOrderRouting];
DROP INDEX ix_Customer_PersonID ON Sales.Customer;
DROP INDEX ix_Person_BusinessEntityID ON Person.Person;
CREATE INDEX IX_Person_LastName_FirstName_MiddleName ON Person.Person (LastName, FirstName, MiddleName) INCLUDE (Title) WITH (DROP_EXISTING = ON)

