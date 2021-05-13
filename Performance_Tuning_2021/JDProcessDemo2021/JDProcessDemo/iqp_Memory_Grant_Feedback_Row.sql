-- Step 1: Make sure this database is in compatibility level 150 and clear procedure cache for this database. Also bring the table into cache to compare warm cache queries
USE [WideWorldImportersDW]
GO
ALTER DATABASE [WideWorldImportersDW] SET COMPATIBILITY_LEVEL = 150
GO
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE
GO
SELECT COUNT(*) FROM [Fact].[OrderHistory]
GO

-- Step 2: Simulate statistics out of date
UPDATE STATISTICS Fact.OrderHistory 
WITH ROWCOUNT = 1000
GO

-- Step 3: Run a query to get order and stock item data
-- IMPORTANT: DO NOT select the comments here to run the query!
-- IMPORTANT: Enable the option to "Include Actual Execution Plan" (Ctrl+M) 

SELECT fo.[Order Key], fo.Description, si.[Lead Time Days]
FROM  Fact.OrderHistory AS fo
INNER HASH JOIN Dimension.[Stock Item] AS si 
ON fo.[Stock Item Key] = si.[Stock Item Key]
WHERE fo.[Lineage Key] = 9
AND si.[Lead Time Days] > 19
GO

-- Note the execution time: around 45 seconds
-- See the execution plan
--	Note there is no Column Store index used -> Row Mode
--	Note the spill on the Hash Match operator
--  Note the query cost: 70.03
-- See the properties of the SELECT operator. Look for the MemoryGrantInfo property 
--	 Note:  
--		GrantedMemory 1024 

-- Step 4: Let's try this again
-- DO NOT select the comments here to run the query!
SELECT fo.[Order Key], fo.Description, si.[Lead Time Days]
FROM  Fact.OrderHistory AS fo
INNER HASH JOIN Dimension.[Stock Item] AS si 
ON fo.[Stock Item Key] = si.[Stock Item Key]
WHERE fo.[Lineage Key] = 9
AND si.[Lead Time Days] > 19
GO

-- Note the execution time: around 2 seconds
-- See the execution plan
--	Note there is no Column Store index used -> Row Mode
--	Note there is no spill now
--  Note the query cost is the same: 70.03
-- See the properties of the SELECT operator. Look for the MemoryGrantInfo property 
--	 Note:  
--		GrantedMemory 626008 
--		IsMemoryGrantFeedbackAdjusted = YesAdjusting

-- Step 5: Let's try this again
-- DO NOT select the comments here to run the query!
SELECT fo.[Order Key], fo.Description, si.[Lead Time Days]
FROM  Fact.OrderHistory AS fo
INNER HASH JOIN Dimension.[Stock Item] AS si 
ON fo.[Stock Item Key] = si.[Stock Item Key]
WHERE fo.[Lineage Key] = 9
AND si.[Lead Time Days] > 19
GO

-- Note the execution time: around 2 seconds
-- See the execution plan
--	Note there is no Column Store index used -> Row Mode
--	Note there is no spill now
--  Note the query cost is the same: 70.03
-- See the properties of the SELECT operator. Look for the MemoryGrantInfo property 
--	 Note:  
--		GrantedMemory 626008 
--		IsMemoryGrantFeedbackAdjusted = YesStable 

-- Step 6: Restore table and clustered index back to its original state
UPDATE STATISTICS Fact.OrderHistory 
WITH ROWCOUNT = 3702592
GO
ALTER TABLE [Fact].[OrderHistory] DROP CONSTRAINT [PK_Fact_OrderHistory]
GO
ALTER TABLE [Fact].[OrderHistory] ADD  CONSTRAINT [PK_Fact_OrderHistory] PRIMARY KEY NONCLUSTERED 
(
	[Order Key] ASC,
	[Order Date Key] ASC
)
GO