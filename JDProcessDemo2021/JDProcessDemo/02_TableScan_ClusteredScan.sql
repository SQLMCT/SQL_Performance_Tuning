--Hey John! What is the difference between
--Table Scan and Clustered Index Scan

--Run 02_CreateDatabase.sql
--Run 02_CreateTable.sql
--Run 02_AddRecords

--Without Primary Key, Execution plan performs Table Scan
SELECT AcctID, AcctName, Balance, ModifiedDate
FROM Accounting.BankAccounts

---Adding a Primary Key will also create a clustered index.
ALTER TABLE Accounting.BankAccounts
ADD CONSTRAINT pk_acctID PRIMARY KEY(AcctID)

--With Primary Key, plan performs Clustered Index Scan
SELECT AcctID, AcctName, Balance, ModifiedDate
FROM Accounting.BankAccounts


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

