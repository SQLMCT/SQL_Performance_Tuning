--Demo setup
USE master;

--Build Database for Demo
DROP DATABASE IF EXISTS IOP_Demo;
CREATE DATABASE IOP_Demo ON PRIMARY
	(NAME = IOP_Demo,
	FILENAME = 'D:\DATA\IOP_DB.mdf')
LOG ON
	(NAME = IOP_Demo_Log, 
	FILENAME = 'D:\DATA\IOP_DB.ldf');
GO

USE IOP_Demo
GO
DROP TABLE IF EXISTS dbo.IndexOppTest
GO

SELECT TOP 750000
	AcctID = IDENTITY(INT, 1, 1),
	AcctCode = CAST(CAST(RAND(CHECKSUM(NEWID()))* 10000 as int)as char(4))
				+'_JD_INSERT'  ,
	ModifiedDate = GETDATE()
INTO dbo.IndexOppTest
FROM sys.all_columns AC1 CROSS JOIN sys.all_columns AC2
GO

--Create clustered index
ALTER TABLE dbo.IndexOppTest
ADD CONSTRAINT pk_acctID PRIMARY KEY (AcctID)

--Create non-clustered index to speed up reads
CREATE NONCLUSTERED INDEX ix_jd_IndOpptest_demo
ON dbo.IndexOppTest(AcctCode, ModifiedDate)

--Look at the data! LOOK AT IT NOW!
SELECT AcctID, AcctCode, ModifiedDate FROM dbo.IndexOppTest
WHERE AcctID < 1000

--Get the current database id
USE IOP_Demo;
GO
SELECT DB_ID()
GO

--Index operations before Updates and Deletes
SELECT *
FROM  SYS.DM_DB_INDEX_OPERATIONAL_STATS (8,NULL,NULL,NULL ) AS O
	INNER JOIN SYS.INDEXES AS I
		ON I.[OBJECT_ID] = O.[OBJECT_ID] 
		AND I.INDEX_ID = O.INDEX_ID 
WHERE OBJECTPROPERTY(O.[OBJECT_ID],'IsUserTable') = 1

/*
--sys.dm_db_index_operational_stats (    
    { database_id | NULL | 0 | DEFAULT }    
  , { object_id | NULL | 0 | DEFAULT }    
  , { index_id | 0 | NULL | -1 | DEFAULT }    
  , { partition_number | NULL | 0 | DEFAULT }  )  
 */

--Perform some DML operations
UPDATE dbo.IndexOppTest
SET ModifiedDate = '03/20/2020'
WHERE AcctID < 1000

DELETE dbo.IndexOppTest
WHERE AcctID BETWEEN 1000 AND 1500

--Index operations after Updates and Deletes
SELECT name, database_id, o.index_id, type_desc,
	leaf_insert_count, leaf_delete_count, leaf_update_count, leaf_ghost_count,
	nonleaf_insert_count, nonleaf_delete_count, nonleaf_update_count
FROM  SYS.DM_DB_INDEX_OPERATIONAL_STATS (8,NULL,NULL,NULL ) AS O
	INNER JOIN SYS.INDEXES AS I
		ON I.[OBJECT_ID] = O.[OBJECT_ID] 
		AND I.INDEX_ID = O.INDEX_ID 
WHERE OBJECTPROPERTY(O.[OBJECT_ID],'IsUserTable') = 1

