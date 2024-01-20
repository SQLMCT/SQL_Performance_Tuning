Use PartitionDB
go
-------------------------------------------------------------------------------------------
---------------Inserting data into Partition table -------------------------------
-------------------------------------------------------------------------------------------
INSERT SalesOrderHeader (
	[RevisionNumber] ,
	[OrderDate] ,
	[DueDate] ,
	[ShipDate],
	[Status] ,
	[OnlineOrderFlag] ,
	[PurchaseOrderNumber] ,
	[AccountNumber] ,
	[CustomerID] ,
	[SalesPersonID] ,
	[TerritoryID] ,
	[BillToAddressID] ,
	[ShipToAddressID] ,
	[ShipMethodID] ,
	[CreditCardID] ,
	[CreditCardApprovalCode] ,
	[CurrencyRateID] ,
	[SubTotal] ,
	[TaxAmt] ,
	[Freight],
	[Comment] ,
	[rowguid],	
	[ModifiedDate] 
)
SELECT
	[RevisionNumber] ,
	[OrderDate] ,
	[DueDate] ,
	[ShipDate],
	[Status] ,
	[OnlineOrderFlag] ,
	[PurchaseOrderNumber] ,
	[AccountNumber] ,
	[CustomerID] ,
	[SalesPersonID] ,
	[TerritoryID] ,
	[BillToAddressID] ,
	[ShipToAddressID] ,
	[ShipMethodID] ,
	[CreditCardID] ,
	[CreditCardApprovalCode] ,
	[CurrencyRateID] ,
	[SubTotal] ,
	[TaxAmt] ,
	[Freight],
	[Comment] ,
	[rowguid],	
	[ModifiedDate] 
FROM
	AdventureWorksPTO.Sales.SalesOrderHeader
-------------------------------------------------------------------------------------------------------------
----------------------Checkign rows in each partition for all Indexes---------------------------
---OTHER than Partition 1 (future data storage) all other has >0 rows
-------------------------------------------------------------------------------------------------------------
SELECT * 
FROM sys.partitions 
Where object_id = object_id ('SalesOrderHeader')
order by index_id,partition_number
