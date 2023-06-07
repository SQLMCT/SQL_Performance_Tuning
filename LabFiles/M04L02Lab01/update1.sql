Use AdventureWorksPTO
go
update dbo.NewSalesOrderDetail set OrderQty = 3,LineTotal = UnitPrice * 3 
where SalesOrderID = 43665 and SalesOrderDetailID = 64