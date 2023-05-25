--Remind John to show 02_TableScan_ClusteredScan
USE AdventureWorks2019
GO

--Check the ID of the Database
SELECT DB_ID()
GO

--Check the data in the table
SELECT * FROM Person.Address
GO

--What pages belong to the table
DBCC IND(0,'Person.Address',-1)

--Loog inside the data pages
DBCC TRACEON(3604) 
DBCC PAGE(0, 1, 11712, 3)

--New in SQL Server 2016
SELECT * FROM sys.dm_db_database_page_allocations
(DB_ID(), object_ID('Person.Address'), NULL, NULL, 'LIMITED')
WHERE index_id = 4

--New in SQL Server 2019
SELECT * FROM sys.dm_db_page_info(DB_ID(), 1, 8544, 'Detailed')