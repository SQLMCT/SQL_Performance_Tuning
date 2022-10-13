
--Need to run the WWI_Extend_Order_History script from Joe Sack.

--USE WideWorldImportersDW
--GO

---- Clean up just in case.
----Begin Setup run up to End of setup
----DROP TABLE IF EXISTS CCSIDEmo.OrderHistoryExtended;
----GO
----DROP SCHEMA IF EXISTS CCSIDemo;
----GO
--CREATE SCHEMA CCSIDemo;
--GO

-- Takes 2 Minutes: 
--Create a duplicate table to show side by side comparisons
PRINT 'Creating duplicate table'
SELECT *
INTO   CCSIDemo.OrderHistoryExtended
FROM
  Fact.OrderHistoryExtended;
GO

--Takes 1 1/2 Minutes:
--Now create a clustered column store index on our new table
PRINT 'Creating Clustered Column Store Index'
CREATE CLUSTERED COLUMNSTORE INDEX CCSI_OHE
	ON CCSIDemo.OrderHistoryExtended
WITH (DATA_COMPRESSION = COLUMNSTORE);
GO 
-- End of setup

-- Let's demonstrate the benefit of CCSI
-- Turn on Actual Execution Plan (CTRL+L)
-- make sure we have a cold cache
DBCC DROPCLEANBUFFERS;
PRINT ' ';
PRINT 'Without CCSI';
SET STATISTICS IO ON;
DECLARE @start DATETIME,
        @end   DATETIME;
SET @start = GETDATE();
SELECT [Order Date Key]
       ,AVG([Total Including Tax])
FROM
  Fact. OrderHistoryExtended
GROUP  BY
  [Order Date Key];
SET @end = GETDATE();
PRINT 'Elapsed time: '
      + CAST(DATEDIFF(ms, @start, @end) AS VARCHAR(50))
      + ' milliseconds.';
SET STATISTICS IO OFF;
GO



DBCC DROPCLEANBUFFERS;
PRINT ' ';
PRINT 'With CCSI';
SET STATISTICS IO ON;
DECLARE @start DATETIME,
        @end   DATETIME;
SET @start = GETDATE();
SELECT [Order Date Key]
       ,AVG([Total Including Tax])
FROM
  CCSIDemo. OrderHistoryExtended
GROUP  BY
  [Order Date Key];
SET @end = GETDATE();
PRINT 'Elapsed time: '
      + CAST(DATEDIFF(ms, @start, @end) AS VARCHAR(50))
      + ' milliseconds.';
SET STATISTICS IO OFF;
GO 

-- Note that the elapsed time for no columnstore is ~14554 millisecs.
-- and with the columnstore index it is only ~403 millisecs!

-- Also note that the IO is considerably higher for the row store version than the column store
-- and that the row store cost is 99% of the batch when run together with the column store version.
-- Looking at the actual cost from the execution plan: row store - 565.599 column store - 3.98267!

SET STATISTICS IO ON
SELECT [Order Date Key]
FROM  Fact.OrderHistoryExtended
SET STATISTICS IO OFF;

SET STATISTICS IO ON
SELECT [Order Date Key]
FROM   CCSIDemo.OrderHistoryExtended
SET STATISTICS IO OFF;


/* 
This Sample Code is provided for the purpose of illustration only and is not 
	intended to be used in a production environment. THIS SAMPLE CODE AND ANY
	RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
	EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED 
	WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE. 
We grant You a nonexclusive, royalty-free right to use and modify the Sample 
	Code and to reproduce and distribute the object code form of the Sample 
	Code, provided that You agree: 
	(i) to not use Our name, logo, or trademarks to market Your software 
		product in which the Sample Code is embedded; 
	(ii) to include a valid copyright notice on Your software product in 
		which the Sample Code is embedded; and 
	(iii) to indemnify, hold harmless, and defend Us and Our suppliers from 
		and against any claims or lawsuits, including attorneys fees, that 
		arise or result from the use or distribution of the Sample Code.
*/