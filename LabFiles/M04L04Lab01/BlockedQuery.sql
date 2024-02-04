/*============================================================================
	SQL Server  PTO Module 04 Hands-on Labs
	BlockedQuery.sql
	--Run AddTables.sql ( pre requisite)
------------------------------------------------------------------------------

This script run periodical query for simulating blocking issue
============================================================================*/

USE AdventureworksPTO ;
go
WAITFOR DELAY '00:00:10' 
Select 'Blocked'
 WHILE 1=1
BEGIN
	SELECT * FROM dbo.NewContacts
	WAITFOR DELAY '00:00:10'
END
GO