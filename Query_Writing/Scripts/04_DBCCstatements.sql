-- Run 04a_AddRecords 
-- Show Heap first 
-- SELECT statement, DBCC, and Execution Plans)
-- 04_TableScan_ClusteredScan will created Clustered Index

USE AdventureWorks2016
GO

SELECT * FROM Accounting.BankAccounts

--Show data stored at Page Level
--DBCC TRACEON(3604) 
--DBCC IND(0,'Accounting.BankAccounts',-1)
--DBCC PAGE(0, 1, 19712, 3)