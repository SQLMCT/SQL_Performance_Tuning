/*
Run 05_WWI_Extend_Order_History script to create the Fact.OrderHistoryExtended 
Table that will  have 29,620,736 rows
*/

USE WideWorldImportersDW
GO

-- Clean up just in case.
-- Begin Setup run up to End of setup
--DROP TABLE IF EXISTS CCSIDEmo.OrderHistoryExtended;
--GO
--DROP SCHEMA IF EXISTS CCSIDemo;
--GO

CREATE SCHEMA CCSIDemo;
GO

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
PRINT 'Without CCSI';
SET STATISTICS IO ON;
DECLARE @start DATETIME,
        @end   DATETIME;
SET @start = GETDATE();
SELECT [OrderDateKey]
       ,AVG([TotalIncludingTax])
FROM
  Fact.OrderHistoryExtended
GROUP  BY
  [OrderDateKey];
SET @end = GETDATE();
PRINT 'Elapsed time: '
      + CAST(DATEDIFF(ms, @start, @end) AS VARCHAR(50))
      + ' milliseconds.';
SET STATISTICS IO OFF;
GO

PRINT ' '
PRINT 'Demonstration Separator'
PRINT ' '

DBCC DROPCLEANBUFFERS;
PRINT 'With CCSI';
SET STATISTICS IO ON;
DECLARE @start DATETIME,
        @end   DATETIME;
SET @start = GETDATE();
SELECT [OrderDateKey]
       ,AVG([TotalIncludingTax])
FROM
  CCSIDemo.OrderHistoryExtended
GROUP  BY
  [OrderDateKey];
SET @end = GETDATE();
PRINT 'Elapsed time: '
      + CAST(DATEDIFF(ms, @start, @end) AS VARCHAR(50))
      + ' milliseconds.';
SET STATISTICS IO OFF;
GO 

-- Note that the elapsed time for rowstore is ~ 4043 milliseconds.
-- and with the columnstore index it is only ~ 313 milliseconds!

-- Also note that the IO is considerably higher for the row store version than the column store
-- and that the row store cost is 99% of the batch when run together with the column store version.

-- Looking at the actual cost from the execution plan: row store - 590.070 column store - 4.6292!




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