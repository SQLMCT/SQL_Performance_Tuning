--Demonstrate the MERGE statement
USE AdventureWorks2016
GO

--Clean up from previous course.
DROP TABLE IF EXISTS dbo.StudentSource
DROP TABLE IF EXISTS dbo.StudentTarget
GO

--Demonstration setup. 
--Create Source Table and Target Table.
--Insert two records into each table.

CREATE TABLE StudentSource
(ID tinyint, First_Name varchar(10))
GO

CREATE TABLE StudentTarget
(ID tinyint, First_Name varchar(10))
GO

INSERT INTO StudentSource
VALUES (1, 'Vamshi'),
       (2, 'Kunal'),
	   (3, 'Halle'), 
	   (4, 'Jannat'),
	   (5, 'Noelle'),
	   (6, 'Kyle')	   
GO

INSERT INTO StudentTarget
VALUES (1, 'John'),
	   (7, 'Corey')
GO

--Merge the two tables 
--The First_Name for ID 1 will be updated from John to Vamshi.
--The records for ID 2-6 will be inserted into StudentTarget table.
--The record for ID 7 will be deleted from the StudentTarget table.

MERGE StudentTarget AS T
	USING StudentSource AS S
	ON T.ID = S.ID
WHEN MATCHED THEN
	UPDATE SET T.First_Name = S.First_Name
WHEN NOT MATCHED BY TARGET THEN
	INSERT (ID, First_Name)
	VALUES (S.ID, S.First_Name)
WHEN NOT MATCHED BY SOURCE THEN
	DELETE;
GO

--See results of Merge
SELECT ID, First_Name FROM StudentTarget





