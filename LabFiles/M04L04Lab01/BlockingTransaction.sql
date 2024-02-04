/*============================================================================
	SQL Server PTO Module 04 Hands-on Labs
	BlockingTransaction.sql
	--Run AddTables.sql ( pre requisite)
	
------------------------------------------------------------------------------

This script run periodical update for simulating blocking and deadlock issue
============================================================================*/

USE AdventureWorksPTO ;
go

WHILE 1=1
BEGIN
       Select 'Blocking'
	BEGIN TRAN
	UPDATE dbo.NewContacts
		SET FirstName = N'Update: ' + convert(nvarchar, getdate()) 
		WHERE BusinessEntityID = 3
		WAITFOR DELAY '00:00:25'
	SELECT * from dbo.NewContacts WHERE BusinessEntityID = 3
	COMMIT TRAN
	WAITFOR DELAY '00:00:03'
END
GO