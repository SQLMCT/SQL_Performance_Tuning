USE [AdventureWorks2019];
GO

--Don't do this in a Production environment.
DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE
GO

--List the indexes
EXEC [sp_helpindex] 'Person.Address';
GO

--Count the Pages
SELECT database_id, index_id, index_Level, page_count, record_count, avg_fragment_size_in_pages 
FROM [sys].[dm_db_index_physical_stats]
	(db_id(), object_id('Person.Address'), 
	    1, NULL, 'DETAILED') 
WHERE record_count > 0

/*
** Page Count = 344 
** Record Count = 19614
** Row Per Page = SELECT 19614 / 344 = 57

** Clustered Index has 344 PAGES (Level 0 is leaf level in Clustered Index)
** SELECT 344/4 = 86
** SELECT 344/3 = 114
**
** The tipping point will be between 86 and 114
*/

-- Count how many address per StateProvinceID

SELECT StateProvinceID, COUNT(*) AS Address_Count
FROM Person.Address
GROUP BY StateProvinceID
ORDER BY StateProvinceID;
GO

-- Turn on Actual Execution Plan (Ctrl+M)
-- Show Key Lookup with single value
-- SELECT * will need to find all columns

SELECT *
FROM Person.Address
WHERE StateProvinceID = 3

-- Show Key Lookup with multiple values below tipping point
-- Only 50 rows to lookup when StateProvince is below 6
-- Remember tipping point will be between 86 and 114

SELECT *
FROM Person.Address
WHERE StateProvinceID <= 6

-- Show Clustered Scan with multiple values above tipping point
-- StateProvinceID of 7 added 1579 rows and performed a scan
-- Remember tipping point will be between 86 and 114

SELECT *
FROM Person.Address
WHERE StateProvinceID <= 7

-- Show multiple values closer to the tipping point
-- Count how many rows, Should be 101 rows

SELECT StateProvinceID, COUNT(*) AS Address_Count
FROM Person.Address
WHERE StateProvinceID IN (1, 3, 6, 10, 11, 15)
GROUP BY StateProvinceID

-- Show Key Lookup with multiple values below tipping point
-- Remember tipping point will be between 86 and 114
SELECT *
FROM Person.Address
WHERE StateProvinceID IN (1, 3, 6, 10, 11, 15)

-- Show multiple values closer to the tipping point
-- First count how many rows when adding StateProvinceID 17
-- This adds 17 more rows for a total of 118

SELECT StateProvinceID, COUNT(*) AS Address_Count
FROM Person.Address
WHERE StateProvinceID IN (1, 3, 6, 10, 11, 15, 17)
GROUP BY StateProvinceID

-- Show Clustered Index scan with multiple values above tipping point

SELECT *
FROM Person.Address
WHERE StateProvinceID IN (1, 3, 6, 10, 11, 15, 17)


/*
This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.  
THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  
We grant You a nonexclusive, royalty-free right to use and modify the 
Sample Code and to reproduce and distribute the object code form of the Sample Code, provided that You agree: (i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded; 
(ii) to include a valid copyright notice on Your software product in which the Sample Code is 
embedded; and 
(iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys’ fees, that arise or result from the use or distribution of the Sample Code.
Please note: None of the conditions outlined in the disclaimer above will supercede the terms and conditions contained within the Premier Customer Services Description.
*/

