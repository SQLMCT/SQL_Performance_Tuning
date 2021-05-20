--This is a continuation to instructions from script "C:\Demos\M03L02Demo01\Backup-DB-Encryption.sql" from the SQLSecurityClient machine
--Assuming steps so far is completed from the above script we are connected to SQLSecNode2 now.
--Check if SQLSecnode2 service is running and start service if you have issues with connecting to the instance.
--We need to try restoring the backup taken with encryption option enabled on SQLSecNode1

--First try copying the backup "backupencryption.bak" from \\sqlsecnode1\c$\temp to \\sqlsecnode2\c$\temp. 
--Create a similar folder structure on SQLsecnode2 as required.

--Once the backup is copied. Now lets try to restore

RESTORE DATABASE [BackupEncryption] FROM DISK = 'C:\temp\backupencryption.bak';
GO

--You will receive the error like below

/*
Msg 33111, Level 16, State 3, Line 11
Cannot find server certificate with thumbprint '0x03A83C634DF54B7AF7408A417D9A230A6F4CB84C'.
Msg 3013, Level 16, State 1, Line 11
RESTORE DATABASE is terminating abnormally.

*/

--So we need to restore the certificate in order to restore the backup.

--Copy the certificates and private key (MyBackupCert and MyBackupCertPrivateKey) from SQLSecnode1 to SQLSecnode2
--From \\sqlsecnode1\c$\temp to \\sqlsecnode2\c$\temp

--Try creating the certificate

CREATE CERTIFICATE MyBackupCert 
FROM FILE = 'c:\temp\MyBackupCert'
 WITH PRIVATE KEY 
 (  FILE = 'c:\temp\MyBackupCertPrivateKey',  DECRYPTION BY PASSWORD = '997jkhUbhk$w4ez0876hKHJH5gh' 
  );
  GO

--Few Errors you may receive...

-- You may receive an error if the permissions to the SQL service account doesnt exist or if the files are missing in the respective path. 
--Make sure you provide permissions to the SQL service account on the files

/*
Msg 15208, Level 16, State 6, Line 31
The certificate, asymmetric key, or private key file is not valid or does not exist; or you do not have permissions for it.

*/

--You may also receive the below error if the master key is not created on this new server.

/*
Msg 15581, Level 16, State 1, Line 31
Please create a master key in the database or open the master key in the session before performing this operation.
*/

--In such case create the master key

USE master;
GO
IF NOT EXISTS(SELECT * FROM sys.symmetric_keys WHERE name LIKE '%[_]DatabaseMasterKey%') 
BEGIN 
CREATE MASTER KEY ENCRYPTION  BY PASSWORD = '997jkhUbhk$w4ez0876hKHJH5gh';
END
GO

--Try now creating the certificate

CREATE CERTIFICATE MyBackupCert 
FROM FILE = 'c:\temp\MyBackupCert'
 WITH PRIVATE KEY 
 (  FILE = 'c:\temp\MyBackupCertPrivateKey',  DECRYPTION BY PASSWORD = '997jkhUbhk$w4ez0876hKHJH5gh' 
  );
  GO

--The certificate will now be successfully created.

-- Restore the backup now and it will be successful.

RESTORE DATABASE [BackupEncryption] FROM DISK = 'C:\temp\backupencryption.bak';
GO


-- Cleanup. To cleanup the environment. Run it on both SQLSecNode1 and SQlSecNode2

USE master;
GO
DROP DATABASE [BackupEncryption];
GO
DROP CERTIFICATE MyBackupCert;
GO





