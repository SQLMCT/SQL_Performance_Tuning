-- Exercise 1 -- Understand Row Level Security

--Sales representatives should be able to only view customers who are in their assigned territory.
--Managers and Vice Presidents in the Sales organization should be able to see all the customers.
--Therefore, Linda3, who is a sales representative and manages TerritoryID 4 can only view the records assigned to territory 4 and rest of the rows will not be visible.

USE AdventureWorks
GO
EXECUTE  AS  USER  =  'linda3'
GO

--Even without filter in the query, you will only get records for Territory ID 4 as because the query is executed as user 'Linda3'
--Please check the TerritoryID column in the query results
SELECT  *  FROM Sales.CustomerPII
GO

--No Rows will be deducted for TerritoryID 2
SELECT  *  FROM Sales.CustomerPII  where TerritoryID=2
GO

--Can fetch records for TerritoryID 4
SELECT  *  FROM Sales.CustomerPII  where TerritoryID=4
GO  

-- Cannot update or delete customers who are not in Territory 4 (other territories are filtered)
DELETE  FROM Sales.CustomerPII  WHERE TerritoryID  = 10
GO
-- 0 rows affected    
UPDATE Sales.CustomerPII  SET FirstName  =  'Contoso'  WHERE TerritoryID  = 9    -- 0 rows affected
GO
-- 0 rows affected  

-- Blocked from inserting a new customer in a territory not assigned to user...
  
INSERT  INTO Sales.CustomerPII  (CustomerID, FirstName, LastName, TerritoryID)
VALUES  (0,  'Test',  'Contoso', 10)  
-- operation failure

--But can insert a new customer in a territory assigned to user
  
INSERT  INTO Sales.CustomerPII  (CustomerID, FirstName, LastName, TerritoryID)
VALUES  (0,  'Test',  'Contoso', 4)  
-- 1 row affected
  
-- Blocked from updating the territory of an accessible customer to be in an unassigned territory
  
UPDATE Sales.CustomerPII  SET TerritoryID  = 7  WHERE CustomerID  = 0  
-- operation failure
  
-- Reset the changes
  
DELETE  FROM Sales.CustomerPII  WHERE CustomerID  = 0
go
REVERT
go

-- Exercise 2 -- Configure Row-Level Security

--In this exercise, Sales Persons connect to the database through a middle-tier application using a shared SQL login. 
--To identify the current application user in the database, the application will store the current user name in the SESSION_CONTEXT immediately after opening a connection. 
--This way, the RLS policy can filter rows based on the user name stored in SESSION_CONTEXT.
  
-- First, create a shared SQL login for the application's connection string and provide required permissions
  
CREATE  LOGIN AppSvc  WITH  PASSWORD  =  'P@ssw0rd1'
CREATE  USER AppSvc  FOR  LOGIN AppSvc
GRANT  SELECT,  INSERT,  UPDATE,  DELETE  ON Sales.CustomerPII  TO AppSvc
go
  
-- To set the SESSION_CONTEXT, the application will execute the following each time a connection is opened:
  
EXEC sp_set_session_context  @key=N'user_name', @value=N'michael9'
go
  
-- Now, this user name is stored in the SESSION_CONTEXT for the rest of the session (it will be reset when the connection is closed and returned to the connection pool).
  
SELECT SESSION_CONTEXT(N'user_name')
go
  
-- Reset for now
  
EXEC sp_set_session_context  @key=N'user_name', @value=NULL
go
  
-- We need to change our security policy to filter based on the user_name stored in SESSION_CONTEXT. 
--To do this, create a new predicate function that adds the new access logic. 
--As a best practice, we'll put the function in a separate 'Security' schema that we've already created.
  
CREATE  FUNCTION  Security.customerAccessPredicate_v2(@TerritoryID  int)  
RETURNS  TABLE
WITH  SCHEMABINDING
AS
RETURN  SELECT 1  AS accessResult
FROM HumanResources.Employee e 
INNER  JOIN Sales.SalesPerson sp  ON sp.BusinessEntityID  = e.BusinessEntityID
WHERE
-- SalesPersons can only access customers in assigned territory
(  IS_MEMBER('SalesPersons')  = 1
AND  RIGHT(e.LoginID,  LEN(e.LoginID)  -  LEN('adventure-works\'))  =  USER_NAME() 
AND sp.TerritoryID  = @TerritoryID  ) 
-- SalesManagers and database administrators can access all customers
OR  IS_MEMBER('SalesManagers')  = 1
OR  IS_MEMBER('db_owner')  = 1
-- NEW: Use the user_name stored in SESSION_CONTEXT if ApplicationServiceAccount is connected
OR  (  USER_NAME()  =  'AppSvc' 
AND  RIGHT(e.LoginID,  LEN(e.LoginID)  -  LEN('adventure-works\'))  =  CAST(SESSION_CONTEXT(N'user_name')  AS  sysname)
AND sp.TerritoryID  = @TerritoryID  )
go
  
-- Swap this new function into the existing security policy. 
--The FILTER predicate filters which rows are accessible via SELECT, UPDATE, and DELETE. 
--The BLOCK predicate will prevent users from INSERT-ing or UPDATE-ing rows such that they violate the predicate.
  
ALTER  SECURITY  POLICY  Security.customerPolicy
ALTER  FILTER  PREDICATE  Security.customerAccessPredicate_v2(TerritoryID)  ON Sales.CustomerPII,
ALTER  BLOCK  PREDICATE  Security.customerAccessPredicate_v2(TerritoryID)  ON Sales.CustomerPII
go
  
-- To simulate the application, impersonate ApplicationServiceAccount
  
EXECUTE  AS  USER  =  'AppSvc'
go
  
-- If the application has not set the user_name key in SESSION_CONTEXT (i.e. it's NULL), then all rows are filtered:
  
SELECT  *  FROM Sales.CustomerPII  -- 0 rows
go
  
-- So the application should set the current user_name in SESSION_CONTEXT immediately after opening a connection:
  
EXEC sp_set_session_context  @key=N'user_name', @value=N'michael9'  -- assume 'michael9' is logged in to the application
go
  
-- Only customers for Territory 2 are visible
  
SELECT  *  FROM Sales.CustomerPII
go
  
-- Application is blocked from inserting a new customer in a territory not assigned to the current user...
  
INSERT  INTO Sales.CustomerPII  (CustomerID, FirstName, LastName, TerritoryID)
VALUES  (0,  'Test',  'Customer', 10)  -- operation failed, block predicate conflicts
go
  
REVERT
go
  
-- Reset the changes
  
EXEC sp_set_session_context  @key=N'user_name', @value=NULL
go
   
ALTER  SECURITY  POLICY  Security.customerPolicy
ALTER  FILTER  PREDICATE  Security.customerAccessPredicate(TerritoryID)  ON Sales.CustomerPII,
ALTER  BLOCK  PREDICATE  Security.customerAccessPredicate(TerritoryID)  ON Sales.CustomerPII
go
   
DROP  FUNCTION  Security.customerAccessPredicate_v2
DROP  USER AppSvc
DROP  LOGIN AppSvc
go
  
-- Final note: Use these system views to monitor and manage security policies and predicates
  
SELECT  *  FROM  sys.security_policies
SELECT  *  FROM  sys.security_predicates
