--Backup Encryption Demo
USE AdventureWorks2016
GO
--The first step is to create a Database Master Key. 
--This can only be performed once.
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'SQL$ecurity3';
GO

--Check to see if key is encrypted by Server
SELECT name,  is_master_key_encrypted_by_server 
FROM sys.databases
GO
SELECT * FROM sys.symmetric_keys
GO

--Create Certificate for backup
DROP CERTIFICATE BackupCert 
WITH SUBJECT = 'Certificate for Backup Encryption'
GO

--Verify and write down thumbprint
SELECT name, thumbprint FROM sys.certificates
GO

--0x1062A2BC52EC7B88DE62E251D22EF40F2DBA730D

--Backup Certificate for later
BACKUP CERTIFICATE BackupCert TO FILE = N'D:\Backups\BackupCertifiate.cer'
WITH PRIVATE KEY (FILE = N'D:\Backups\BackupCertificate.pvk',
ENCRYPTION BY PASSWORD = N'J3nnY8675309');

--Backup Database (Unsecure and Secure)
BACKUP DATABASE AdventureWorks2016 
TO DISK = N'D:\DATA\ADWorkUnsecure.bak' WITH FORMAT

BACKUP DATABASE AdventureWorks2016 
TO DISK = N'D:\DATA\ADWorkSecure.bak' 
WITH FORMAT, ENCRYPTION(ALGORITHM = AES_256, SERVER CERTIFICATE = BackupCert)
GO

--Check the header of each backup
RESTORE HEADERONLY FROM DISK = N'D:\DATA\ADWorkUnsecure.bak'
RESTORE HEADERONLY FROM DISK = N'D:\DATA\ADWorkSecure.bak'
GO

--Look at the thumbprint again
SELECT name, thumbprint FROM sys.certificates
GO






