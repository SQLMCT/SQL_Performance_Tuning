--	Execute query to connect to AdventureWorksPTO
USE AdventureWorksPTO
GO

--2.	Execute query to setup the environment:
CREATE PROCEDURE Order_NonS_Perf 
(@OrderID int)
AS
BEGIN
    SELECT * 
    FROM Sales.SalesOrderHeader
    WHERE (SalesOrderID = @OrderID OR @OrderID IS NULL)
END
GO

CREATE PROCEDURE Order_S_Perf
(@OrderID int)
AS
BEGIN
    IF (@OrderID IS NOT NULL)
    BEGIN
        SELECT * 
        FROM Sales.SalesOrderHeader
        WHERE (SalesOrderID = @OrderID)
    END
    ELSE
    BEGIN
        SELECT * 
        FROM Sales.SalesOrderHeader
    END
END
GO

--3.	Enable execution plan and make comparisons between Order_NonS_Perf and Order_S_Perf plans:

EXEC Order_NonS_Perf 43672
GO
EXEC Order_S_Perf 43672
GO
