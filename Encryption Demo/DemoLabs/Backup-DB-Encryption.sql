-- You are following instruction from file  C:\Demos\M03L02Demo01\Backup-DB-Encryption.sql
--Login to SQLSecNode1 to execute the following
--Create a Database which will be used for enabling BackupEncryption

USE master;
GO
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'BackupEncryption') 
DROP DATABASE BackupEncryption;
GO
CREATE DATABASE BackupEncryption;
GO

-- Lets create a new table in the database we created and insert some dummy records to the table

use BackupEncryption
create table t1 (c1 int)
go
insert into t1 values(1)
go 100

-- Verify records to the new table created on new DB
use BackupEncryption
select * from t1
go

--Before we take a backup of the newly created DB, We need to meet pre-requisites if not already exists.
--We need a master key and certficate(server level) on the server as a pre-requisites to encrypt the Database backup

USE master;
GO
IF NOT EXISTS(SELECT * FROM sys.symmetric_keys WHERE name LIKE '%[_]DatabaseMasterKey%') 
BEGIN 
CREATE MASTER KEY ENCRYPTION  BY PASSWORD = '997jkhUbhk$w4ez0876hKHJH5gh';
END
GO
CREATE CERTIFICATE MyBackupCert WITH SUBJECT = 'My Backup DB Certificate';
GO

-- We will take a backup of the certificate (as we need it at later stage in order for the restore to happen on a different instance)
--Please note that these are being backed up locally to the same location.
--This is not a secure practice but for the demo purpose we are ok with this option.
--***Please create the required folder structure below on server SQLSecnode1, otherwise the command will fail***
--**Access the share \\sqlsecnode1\C$\ from the client machine to create the "temp" folder under C:Drive on SQLSecnode1**

  USE master;
  GO
  BACKUP CERTIFICATE MyBackupCert TO FILE = 'c:\temp\MyBackupCert' 
  WITH PRIVATE KEY (  FILE = 'c:\temp\MyBackupCertPrivateKey', 
  ENCRYPTION BY PASSWORD = '997jkhUbhk$w4ez0876hKHJH5gh'  );
  GO

-- You will see 2 new files (certificate backup, private key) created on the SQLSecNode1 server in the following location.
--\\sqlsecnode1\c$\temp (Try accessing the share and verify)

--Now lets take the backup of the Database with encryption option
BACKUP DATABASE BackupEncryption
TO DISK = 'C:\Temp\backupencryption.bak'
WITH ENCRYPTION (ALGORITHM = AES_256, SERVER CERTIFICATE = MyBackupCert)
 
-- You will see the backup file created in \\sqlsecnode1\c$\temp (Try accessing the share and verify)

-- Drop the new Database created and try to restore the database on same SQL instance (local) which is SQLSecNode1

Drop database BackupEncryption
go

-- Restore the Database from backup you took in previous step

USE [master]
RESTORE DATABASE [BackupEncryption] FROM  DISK = N'C:\Temp\backupencryption.bak' WITH  FILE = 1,  NOUNLOAD,  STATS = 5
GO

/*
** You will be able to successfully restore as the Certificate exists on same server. Now lets try copying this backup to a different server 
and try the restore
**

-- You will see three new files (certificate backup, private key and Database backup) created on the SQLSecNode1 server in the following location.
--\\sqlsecnode1\c$\temp (Try accessing the share and verify)

--Now lets simulate to restore the database backup to a different server(SQLSecNode2) to understand how database backups are protected 
--and to confirm that without certificates you cannot restore the backup.

--Switch to C:\Demos\M03L02Demo01\Restore-DB-Encryption.sql on the SQLSecurityClient machine and connect to SQLSecNode2 SQL server.