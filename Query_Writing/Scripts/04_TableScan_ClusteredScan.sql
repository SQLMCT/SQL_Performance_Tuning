--Hey John! What is the difference between
--Table Scan and Clustered Index Scan

--Without Primary Key, Execution plan performs Table Scan
SELECT AcctID, AcctName, Balance, ModifiedDate
FROM Accounting.BankAccounts

---Adding a Primary Key will also create a clustered index.
ALTER TABLE Accounting.BankAccounts
ADD CONSTRAINT pk_acctID PRIMARY KEY (AcctID)

--With Primary Key, plan performs Clustered Index Scan
SELECT AcctID, AcctName, Balance, ModifiedDate
FROM Accounting.BankAccounts

