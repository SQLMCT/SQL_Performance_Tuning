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

-- Copy data page number from DBCC IND into DBCC Page command
-- Look inside the data pages
DBCC TRACEON(3604) 
DBCC PAGE(0, 1, 11712, 3) 
WITH TABLERESULTS

-- DBCC TRACESTATUS()

--New in SQL Server 2016 for allocation information
SELECT * FROM sys.dm_db_database_page_allocations
(DB_ID(), object_ID('Person.Address'), NULL, NULL, 'LIMITED')
WHERE index_id = 4

--New in SQL Server 2019 for page information
SELECT * FROM sys.dm_db_page_info(DB_ID(), 1, 11712, 'Detailed')