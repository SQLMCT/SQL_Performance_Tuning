-- Select from all tables in [WideWorldImportersDW]
USE [WideWorldImportersDW];
GO
BEGIN TRAN
SELECT * FROM [dbo].[Lineage];
SELECT * FROM [dbo].[City];
SELECT * FROM [dbo].[Customer];
SELECT * FROM [dbo].[Date];
SELECT * FROM [dbo].[Employee];
SELECT * FROM [dbo].[Payment Method];
SELECT * FROM [dbo].[Stock Item];
SELECT * FROM [dbo].[Supplier];
SELECT * FROM [dbo].[Transaction Type];
SELECT * FROM [dbo].Movement];
SELECT * FROM [dbo].[Order];
SELECT * FROM [dbo].[Purchase];
SELECT * FROM [dbo].[Sale];
SELECT * FROM [dbo].[Stock Holding];
SELECT * FROM [dbo].[Transaction];
COMMIT;

WAITFOR DELAY '00:00:01';