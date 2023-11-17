--Hey John! What is the difference between
--Table Scan and Clustered Index Scan

--Run 02_Create_Database.sql
--Run 02_Create_Table.sql
--Run 02_Add_Records

--What pages belong to the table
DBCC IND(0,'Accounting.BankAccounts',-1)

--Look inside the data pages
DBCC TRACEON(3604) 
DBCC PAGE(0, 1, 344, 3) WITH TABLERESULTS

--DBCC TRACESTATUS()

--Without Primary Key, Execution plan performs Table Scan
SELECT AcctID, AcctName, Balance, ModifiedDate
FROM Accounting.BankAccounts

---Adding a Primary Key will also create a clustered index.
ALTER TABLE Accounting.BankAccounts
ADD CONSTRAINT pk_acctID PRIMARY KEY(AcctID)

--With Primary Key, plan performs Clustered Index Scan
SELECT AcctID, AcctName, Balance, ModifiedDate
FROM Accounting.BankAccounts
WHERE AcctID = 18



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

