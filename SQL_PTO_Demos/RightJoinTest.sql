ALTER TABLE Sales.SalesOrderDetail
DROP CONSTRAINT FK_SalesOrderDetail_SalesOrderHeader_SalesOrderID

ALTER TABLE Sales.SalesOrderDetail
DROP CONSTRAINT FK_SalesOrderDetail_SpecialOfferProduct_SpecialOfferIDProductID


INSERT INTO Sales.SalesOrderDetail
(SalesOrderID, CarrierTrackingNumber, OrderQty, ProductID, SpecialOfferID, UnitPrice, 
	UnitPriceDiscount, rowguid, ModifiedDate)
VALUES ('75125', NULL, 3, 315, 1, 24.99, 0.00,  NEWID(), CURRENT_TIMESTAMP),
		     ('75125', NULL, 10, 300, 1, 499.99, 0.00,  NEWID(), CURRENT_TIMESTAMP)



SELECT SOH.SalesOrderID, SOH.CustomerID,
	OrderQty, UnitPrice
FROM Sales.SalesOrderHeader AS SOH
	LEFT JOIN Sales.SalesOrderDetail AS SOD 
		ON SOH.SalesOrderID = SOD.SalesOrderID
