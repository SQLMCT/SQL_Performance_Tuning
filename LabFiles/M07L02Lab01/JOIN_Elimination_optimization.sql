USE AdventureWorksPTO;
GO

/* Foreign Key Constraints */


select 
    T.name as ChildTableInFK, 
    fk.constraint_column_id as FK_PartNo, 
	c.name as ForeignKeyColumn
from sys.foreign_key_columns as FK
inner join sys.tables as T on fk.parent_object_id = T.object_id
inner join sys.columns as C on fk.parent_object_id = C.object_id and FK.parent_column_id = C.column_id
where FK.referenced_object_id = object_id('Sales.SalesOrderHeader')

-- Click on Include Actual Execution Plan or press Ctrl+M

-- Run a query that joins 2 tables but only returns data from one of them
SELECT sod.SalesOrderID, sod.UnitPrice, sod.OrderQty
FROM Sales.SalesOrderDetail AS sod
     INNER JOIN Sales.SalesOrderHeader AS soh ON sod.SalesOrderID = soh.SalesOrderID
WHERE sod.ProductID = 712;
GO
/*
	Although there's an Inner Join between SalesOrderHeader and SalesOrderDetail
	the Optimizer doesn't need to access SalesOrderHeader because: 
	
	1) we didn't request any data from that SalesOrderHeader, and
	2) the presenced of a trusted (i.e., not disabled with NOCHECK) Foreign Key 
	   on SalesOrderDetail referencing SalesOrderHeader guarantees that every 
	   row in SalesOrderDetail will have a parent row in SalesOrderHeader.
*/

-- Are both tables accessed here?
SELECT sod.SalesOrderID, sod.UnitPrice, sod.OrderQty
FROM Sales.SalesOrderDetail AS sod
     INNER JOIN Sales.SalesOrderHeader AS soh ON sod.SalesOrderID = soh.SalesOrderID
WHERE soh.SalesOrderID = 43659;
GO
/*
	Yes, because it's referenced in the the WHERE clause predicate 
*/

-- Here?
SELECT sod.SalesOrderID, sod.UnitPrice, sod.OrderQty
FROM Sales.SalesOrderDetail AS sod
WHERE sod.LineTotal > 1000 AND EXISTS ( SELECT *
                                        FROM Sales.SalesOrderHeader AS soh
                                        WHERE sod.SalesOrderID = soh.SalesOrderID );
GO
/*
	Again no, because a trusted Foreign Key constraint exists between the Header
	and Detail tables.  The Optimizer knows you can't have a row in Detail without
	a corresponding row in Header.
*/

-- What if we un-trust the constraint using the NOCHECK keyword?
-- This leaves the definition in place, but doesn't enforce referential integrity
ALTER TABLE Sales.SalesOrderDetail NOCHECK CONSTRAINT FK_SalesOrderDetail_SalesOrderHeader_SalesOrderID;
GO

-- Now try the query again
SELECT sod.SalesOrderID, sod.UnitPrice, sod.OrderQty
FROM Sales.SalesOrderDetail AS sod
WHERE sod.LineTotal > 1000 AND EXISTS ( SELECT *
                                        FROM Sales.SalesOrderHeader AS soh
                                        WHERE sod.SalesOrderID = soh.SalesOrderID );
GO
/*
	The plan is accessing both tables, joining them with Hash Match join, as it 
	must confirm that each row metting the filter criteria also has a parent row
	in SalesOrderHeader.

	IO Costs:
		Table 'Workfile'. Scan count 0, logical reads 0
		Table 'Worktable'. Scan count 0, logical reads 0
		Table 'SalesOrderDetail'. Scan count 1, logical reads 1247
		Table 'SalesOrderHeader'. Scan count 1, logical reads 57
*/

SELECT sod.SalesOrderID, sod.UnitPrice, sod.OrderQty
FROM Sales.SalesOrderDetail AS sod
     INNER JOIN Sales.SalesOrderHeader AS soh ON sod.SalesOrderID = soh.SalesOrderID
WHERE sod.ProductID = 712;
GO


SET STATISTICS IO ON;


-- Make the constraint trusted again by using both the WITH CHECK and CHECK key
-- words.
ALTER TABLE Sales.SalesOrderDetail WITH CHECK CHECK CONSTRAINT FK_SalesOrderDetail_SalesOrderHeader_SalesOrderID;
GO
/*
	CHECK (the second one) = Enables the Foreign Key constraint again
	WITH CHECK = Confirm that none of the existing data violates referential integrity

	You might notice that there's IO generated when this command is run.  That's
	because we're verifying that referential integrity is intact.

		Table 'Workfile'. Scan count 0, logical reads 0
		Table 'Worktable'. Scan count 0, logical reads 0
		Table 'SalesOrderDetail'. Scan count 1, logical reads 275
		Table 'SalesOrderHeader'. Scan count 1, logical reads 57

	This variation on the command to re-enables FK checks below (with only the 
	CHECK keyword) turns on FK checkingn going forward, but doesn't guarantee 
	that values violating it don't exist in the table.  This leaves the FK 
	relationship in limbo and means the Optimizer can't fully trust that rows 
	in Detail will always have a parent row in Header.

		ALTER TABLE Sales.SalesOrderDetail CHECK CONSTRAINT FK_SalesOrderDetail_SalesOrderHeader_SalesOrderID;
*/

/*****************************************************************************/
