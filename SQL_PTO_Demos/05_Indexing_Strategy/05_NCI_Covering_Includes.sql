USE AdventureWorks2022
GO

-- List the indexes
EXEC [sp_helpindex] 'Person.Address';
GO

-- Find index pages for the table
DBCC IND(0,'Person.Address',-1)

-- Look inside the data and index pages
DBCC TRACEON(3604,-1) 
DBCC PAGE(0, 1, 10272, 3) --NonClustered Index Page
DBCC PAGE(0, 1, 13512, 3) --Clustered Index Page
DBCC PAGE(0, 1, 13343, 3) --Actual Data Page

-- New Dynamic Management view from SQL Server 2016
SELECT index_id, allocated_page_page_id
FROM sys.dm_db_database_page_allocations
(DB_ID(), object_ID('Person.Address'), NULL, NULL, 'LIMITED')
WHERE index_id = 4 and allocated_page_iam_file_id IS NOT NULL
GO


-- Turn on Actual Execution Plan (CTRL + M)
-- Show IX_Address_StateProvince Index
-- SELECT * will need to find all columns
SELECT *
FROM Person.Address
WHERE StateProvinceID = 3

-- Show IX_Address_StateProvince Index
-- SELECT only columns in Index
-- This is an index that covers a query
SELECT AddressID, StateProvinceID
FROM Person.Address
WHERE StateProvinceID = 3

-- Show IX_Address_StateProvince Index
-- City is not covered in the Index
-- Use INCLUDE to add City to Index
SELECT AddressID, StateProvinceID, City
FROM Person.Address
WHERE StateProvinceID = 3

--.0230391 with Key Lookup
--.0032897 with ADD City
--.0032898 with INCLUDE City

--578 rows in the index page for AddressID and StateProvinceID -- 12 bytes per row
--232 rows when ADDing or Include City -- 30 bytes per row
--120 rows after page split
--214 rows after fill factor

--Introduce a Page Split
INSERT INTO Person.Address
(AddressLine1, AddressLine2, City, StateProvinceID, PostalCode, SpatialLocation, rowguid, ModifiedDate)
VALUES ('3548 Combahee Road', NULL, 'Greenbow', 3, '29944', 0xE6100000010C81A75BBCD45C414036C6FAAE20A755C0, NEWID(), CURRENT_TIMESTAMP)

--Don't do this until after the INCLUDE city demo
ALTER INDEX [IX_Address_StateProvinceID] 
ON [Person].[Address] 
REBUILD 
WITH (FILLFACTOR = 90)

-- Remove City from Index before this demo
-- Look inside the data and index pages
-- Currently 578 pages in StateProvinceID NCI
-- 237 Pages with City Included
-- After Page Split 289 rows.
-- With Fill Factor 221 rows.
DBCC TRACEON(3604,-1) 
DBCC PAGE(0, 1, 26216, 3)

-- New Dynamic Management view from SQL Server 2016
SELECT index_id, allocated_page_page_id
FROM sys.dm_db_database_page_allocations
(DB_ID(), object_ID('Person.Address'), NULL, NULL, 'LIMITED')
WHERE index_id = 4 and allocated_page_iam_file_id IS NOT NULL
GO

DELETE FROM Person.Address
WHERE City = 'Greenbow'


/* This Sample Code is provided for the purpose of illustration only and is not intended 
to be used in a production environment.  THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE 
PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR 
PURPOSE.  We grant You a nonexclusive, royalty-free right to use and modify the Sample Code
and to reproduce and distribute the object code form of the Sample Code, provided that You 
agree: (i) to not use Our name, logo, or trademarks to market Your software product in which
the Sample Code is embedded; (ii) to include a valid copyright notice on Your software product
in which the Sample Code is embedded; and (iii) to indemnify, hold harmless, and defend Us and
Our suppliers from and against any claims or lawsuits, including attorneys’ fees, that arise or 
result from the use or distribution of the Sample Code.
*/



