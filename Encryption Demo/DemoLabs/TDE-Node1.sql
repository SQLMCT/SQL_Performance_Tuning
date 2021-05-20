-- Create a Database which will be used for enabling TDE

USE master;
GO
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'TdeDemo') 
DROP DATABASE TdeDemo;
GO
CREATE DATABASE TdeDemo;
GO

/*

Create the server-level certificate which will protect the database key used to 
encrypt the database's files.  This certificate in turn will be protected by the master key 
which if it does not exist will need to be created.

*/


USE master;
GO
IF NOT EXISTS(SELECT * FROM sys.symmetric_keys WHERE name LIKE '%[_]DatabaseMasterKey%') 
BEGIN 
CREATE MASTER KEY ENCRYPTION  BY PASSWORD = '997jkhUbhk$w4ez0876hKHJH5gh';
END
GO
CREATE CERTIFICATE MyTdeCert WITH SUBJECT = 'My TDE Certificate';
GO

/*

With the server-level components in place, the database can now be encrypted.  
This is done by first creating the database (symmetric) encryption key within the database and then enabling TDE

*/

USE TdeDemo;
GO

CREATE DATABASE ENCRYPTION KEY 
WITH ALGORITHM = AES_128 
ENCRYPTION BY SERVER CERTIFICATE MyTdeCert;
GO

--Ignore the below warning for now as you will be creating the backup of encryption key at later stage.
--Warning: The certificate used for encrypting the database encryption key has not been backed up. You should immediately back up the certificate and the private key associated with the certificate. If the certificate ever becomes unavailable or if you must restore or attach the database on another server, you must have backups of both the certificate and the private key or you will not be able to open the database.

--Go ahead and enable TDE on the Database

ALTER DATABASE TdeDemo SET ENCRYPTION ON;
GO

--Database encryption may take a while to complete.  While in progress, the sys.dm_database_encryption_keys data management view will show the database in an encryption_state of 2
--However Once TDE encryption has been fully applied, the encryption_state will become 3.

SELECT DB_NAME(database_id) as DB,encryption_state 
 FROM sys.dm_database_encryption_keys 
 WHERE database_id=DB_ID();
 GO

--The query will show result like below once completed

 /*
 DB             encryption_state
 --------        ----------------
 TdeDemo             3

 (1 row(s) affected)

 */

  --Now to demonstrate the protection of database backup files through TDE, backup the database 
  --and its certificate.  Please note that these are being backed up locally to the same location.
  --This is not a secure practice but for the lab purpose we are ok with this option.
  --***Please create the required folder structure below on server SQLSecnode1, otherwise the command will fail***
  --Access the share \\sqlsecnode1\C$\LabFiles from the client machine to create the "TDE" folder under "LabFiles".

  USE master;
  GO
  BACKUP CERTIFICATE MyTdeCert TO FILE = 'c:\LabFiles\TDE\MyTdeCert' 
  WITH PRIVATE KEY (  FILE = 'c:\LabFiles\TDE\MyTdeCertPrivateKey', 
  ENCRYPTION BY PASSWORD = '997jkhUbhk$w4ez0876hKHJH5gh'  );
  GO

  --Backup the Database

  BACKUP DATABASE TdeDemo TO DISK = 'c:\LabFiles\TDE\TdeDemo.bak' WITH INIT;
  GO

  -- You will see three new files (certificate backup, private key and Database backup) created on the SQLSecNode1 server in the following location.
  --\\sqlsecnode1\c$\LabFiles\TDE (Try accessing the share and verify)

 --Now lets simulate to restore the database backup to a different server to understand how TDE enabled database backups are protected 
 --and to confirm that without certificates you cannot restore the backup.

 --Switch to C:\Labfiles\M03L02Lab01\TDE-Node2.sql on the SQLSecurityClient machine

 --Open C:\Labfiles\M03L02Lab01\TDE-Node2.sql in a different query window and connect to SQLSecNode2 SQL server.












