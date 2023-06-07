-- Execute query to connect to AdventureWorksPTO
USE AdventureWorksPTO
GO

--	Get information about existing constraints in the table Dcocument 
SELECT name, definition, type_desc, is_disabled, is_not_trusted
FROM sys.check_constraints
WHERE object_name(parent_object_id) = 'Document'

-- Click on Include Actual Execution Plan or press Ctrl+M

--	Execute query
SELECT *
FROM [AdventureWorksPTO].[Production].[Document] d 
	inner join person.BusinessEntity b
		on d.Owner = b.BusinessEntityID
WHERE Status = 4

-- Look at the Actual Execution Plan
-- As you can see Query Engine (QE) did not access any table 
-- it only checks constrain condition and because this query 
-- doesn’t meet the condition “([Status]>=(1) AND [Status]<=(3))”, 
-- the QE returns empty row.  

-- Switch CHECK constrain into NOCHECK state.
ALTER TABLE [Production].[Document] NOCHECK CONSTRAINT [CK_Document_Status]

--	Get information about existing constraints in the table Document to confirm that now it not trusted
SELECT name, definition, type_desc, is_disabled, is_not_trusted
FROM sys.check_constraints
WHERE object_name(parent_object_id) = 'Document'

--	Now the constraint is in a disabled state (is_disabled = 1). 
--  Column is_non_trusted “tells” the query engine that all the data in this 
-- column can be trusted in terms of CHECK condition. 
-- You also see that constrain definition is “([Status]>=(1) AND [Status]<=(3))”. 
-- This means that any data in column Status must be from 1 to 3 and nothing else.

--	Execute query
SELECT *
FROM [AdventureWorksPTO].[Production].[Document] d 
	inner join person.BusinessEntity b
		on d.Owner = b.BusinessEntityID
WHERE Status = 4

-- Look at the Actual Execution Plan
-- As you can see now, the QE executes the query without checking constrain condition.  

-- Execute query to restore constrain in its original state
ALTER TABLE [Production].[Document] WITH CHECK CHECK CONSTRAINT [CK_Document_Status]

-- Execute query to be sure that everything returns to original state.
SELECT name, definition, type_desc, is_disabled, is_not_trusted
FROM sys.check_constraints
WHERE object_name(parent_object_id) = 'Document'