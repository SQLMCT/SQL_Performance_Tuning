--	Execute query to connect to AdventureWorksPTO
USE AdventureWorksPTO
GO

-- Drop the existing UNIQUE constrain.
IF EXISTS (select name from sys.indexes where name = 'PK_TransactionHistoryArchive_TransactionID')
ALTER TABLE [Production].[TransactionHistoryArchive] DROP CONSTRAINT [PK_TransactionHistoryArchive_TransactionID]
GO

-- Click on Include Actual Execution Plan or press Ctrl+M

-- Execute query
SELECT DISTINCT [TransactionID] 
FROM [Production].[TransactionHistoryArchive]

-- Look at the Actual Execution Plan
-- In spite of actual data is uniqueness SQL Server is “not sure” of this fact 
--  and builds a plan with Hash Aggregation. 
-- Check the cost of the query. It is 1.927


-- Execute 
SELECT *
FROM [Production].[TransactionHistoryArchive]
Where [TransactionID] = 71052

-- See the properies of SELECT operator
-- Look for the OptimizerStatUsage and see that the QE accessed several stats to calculate carinality
-- Check the cost of the query. It is 0562

-- Recreate the UNIQUE constrain.
ALTER TABLE [Production].[TransactionHistoryArchive] 
ADD CONSTRAINT [UNIQUE_TransactionHistoryArchive_TransactionID] UNIQUE NONCLUSTERED (TransactionID) 

-- Execute query

SELECT DISTINCT [TransactionID] 
FROM [Production].[TransactionHistoryArchive]

-- Look at the Actual Execution Plan
-- Notice that the Hash Aggregation operator is not used. 
-- Check the cost of the query. It is now 0.248. Much lower, thanks to the constraint

-- Execute 
SELECT *
FROM [Production].[TransactionHistoryArchive]
Where [TransactionID] = 71052

-- Look at the Actual Execution Plan
-- See the properies of SELECT operator
-- Look for the OptimizerStatUsage and see that no stat was used as the UNIQUE constraint garrante that 
-- there will be 0 or 1 row for a especific value of  TransactionID
-- Check the cost of the query. It is now 0.0065. Much lower, thanks to the constraint

-- Restore the database to its original state
ALTER TABLE [Production].[TransactionHistoryArchive] 
DROP CONSTRAINT [UNIQUE_TransactionHistoryArchive_TransactionID]
GO
ALTER TABLE [Production].[TransactionHistoryArchive] 
ADD CONSTRAINT [PK_TransactionHistoryArchive_TransactionID] PRIMARY KEY CLUSTERED (TransactionID)
GO

 
