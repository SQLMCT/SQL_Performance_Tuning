use PartitionDB
go
-----------------------------------------------------------------------------------------------------
-----Creating cluster index on territory id using partition function 
-----------------------------------------------------------------------------------------------------
CREATE CLUSTERED INDEX  CLK_SalesOrderHeader on SalesOrderHeader
(
	TerritoryID
)
ON [OrderHeader_TerritoryPartitions_PS] (TerritoryID) 
GO
-------------Adding primary key using  [SalesOrderID] &  [TerritoryID]  to make it ascending key------------------
ALTER TABLE SalesOrderHeader
ADD  CONSTRAINT [PK_OrderHeader] PRIMARY KEY  
(   
   [SalesOrderID] ASC,   
   [TerritoryID] ASC   
) 
ON [OrderHeader_TerritoryPartitions_PS] (TerritoryID) 
GO  
-----------------------------------------------------------------------------------------------------
------------------------------ADD Non Cluster Indexes -----------------------------------
-----------------------------------------------------------------------------------------------------
/****** Object:  Index [AK_SalesOrderHeader_rowguid]    Script Date: 5/9/2018 9:48:20 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_SalesOrderHeader_rowguid] ON [SalesOrderHeader]
(
	[rowguid] ASC
	,TerritoryID
)
ON [OrderHeader_TerritoryPartitions_PS] (TerritoryID) 

GO

/****** Object:  Index [ix_cc]    Script Date: 5/9/2018 9:50:10 PM ******/
CREATE NONCLUSTERED INDEX [ix_cc] ON [SalesOrderHeader]
(
	[CreditCardApprovalCode] ASC
	,TerritoryID
)
ON [OrderHeader_TerritoryPartitions_PS] (TerritoryID) 
GO

/****** Object:  Index [IX_SalesOrderHeader_CustomerID]    Script Date: 5/9/2018 10:08:34 PM ******/
CREATE NONCLUSTERED INDEX [IX_SalesOrderHeader_CustomerID] ON [SalesOrderHeader]
(
	[CustomerID] ASC
)
ON [OrderHeader_TerritoryPartitions_PS] (TerritoryID) 
GO

/****** Object:  Index [IX_SalesOrderHeader_SalesPersonID]    Script Date: 5/9/2018 10:09:59 PM ******/
CREATE NONCLUSTERED INDEX [IX_SalesOrderHeader_SalesPersonID] ON [SalesOrderHeader]
(
	[SalesPersonID] ASC
)
ON [OrderHeader_TerritoryPartitions_PS] (TerritoryID) 
GO