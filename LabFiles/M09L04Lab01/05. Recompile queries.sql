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
use AdventureWorksPTO;
go
CREATE OR ALTER PROCEDURE Usp_ddldml2
AS
-- DDL
CREATE TABLE #t1
(
     a INT NOT NULL
);
ALTER TABLE #t1 ADD CONSTRAINT pk1 PRIMARY KEY(a);
SELECT *
FROM #t1
-- DDL
CREATE INDEX idx_t1 ON #t1(a)
-- Select after index
SELECT *
FROM #t1 OPTION(RECOMPILE);
go 

exec usp_ddldml2;
go 10