
--Hey John! Make sure you are on JDSQL01

USE MASTER
GO
CREATE CERTIFICATE TDECert WITH SUBJECT = 'Certificate for TDE DB'
GO
SELECT name, thumbprint FROM master.sys.certificates
GO
USE AdventureWorks2016
GO
CREATE DATABASE ENCRYPTION KEY WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE TDECert
GO

SELECT DB_NAME(database_id) AS DBName,
	CASE encryption_state	
		WHEN 0 THEN 'No database encryption key present'
		WHEN 1 THEN 'Unencrypted'
		WHEN 2 THEN 'Encryption in Progress'
		WHEN 3 THEN 'Encrypted'
		WHEN 4 THEN 'Key Change in Progress'
		WHEN 5 THEN 'Decryption in Progress'
		WHEN 6 THEN 'Changing DEK certificate'
	END AS encyrption_state_desc,
	percent_complete, *
FROM sys.dm_database_encryption_keys
WHERE database_id > 4 --Hey, John! Why are you doing this?

/*
Notice that the Key has been created, 
but the database has not been encrypted.
The encryption process will be asynchronous,
and will not block other users. */
ALTER DATABASE AdventureWorks2016 SET ENCRYPTION ON
GO
--Run Query to try to see Encryption in Progress
SELECT DB_NAME(database_id) AS DBName,
	CASE encryption_state	
		WHEN 0 THEN 'No database encryption key present'
		WHEN 1 THEN 'Unencrypted'
		WHEN 2 THEN 'Encryption in Progress'
		WHEN 3 THEN 'Encrypted'
		WHEN 4 THEN 'Key Change in Progress'
		WHEN 5 THEN 'Decryption in Progress'
		WHEN 6 THEN 'Changing DEK certificate'
	END AS encyrption_state_desc,
	percent_complete, *
FROM sys.dm_database_encryption_keys



--Detach AdventureWorks2016 from JDSQL01
USE MASTER
GO
EXEC master.dbo.sp_detach_db @dbname = N'AdventureWorks2016'
GO
--Connect to JDSQL02 and try to attach database
--Switch over to the TDEServer02Attach.sql file

-- To clean up demonstration
-- Turn off TDE (Make sure you are back on JDSQL01)
USE master;
GO
ALTER DATABASE AdventureWorks2016 SET ENCRYPTION OFF;
GO
-- Wait a minute for Encryption to turn off
-- Remove Encryption Key from Database 

USE AdventureWorks2016;
GO
DROP DATABASE ENCRYPTION KEY;
GO

/*Cleanup
USE MASTER
GO
DROP Certificate backupcert
DROP Certificate TDECert
DROP Database ADWorks2
*/
--Make sure to clean up D:\Backups folder