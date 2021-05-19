
--Restore File on Same instance. (Server JDSQL01)
--NOTE: No mention of encryption or decryption during restore
RESTORE DATABASE ADWorks2 FROM DISK = N'D:\DATA\ADWorkSecure.bak'
WITH MOVE 'AdventureWorks2016_Data' TO 'D:\DATA2\ADwork2.mdf',
     MOVE 'AdventureWorks2016_Log' TO 'D:\DATA2\ADwork2_log.ldf'

--Restore File on Different instance. (Server JDSQL02)
--NOTE: Switch connection to JDSQL02
RESTORE DATABASE ADWorks2 FROM DISK = N'D:\DATA\ADWorkSecure.bak'
WITH MOVE 'AdventureWorks2016_Data' TO 'D:\DATA3\ADwork2.mdf',
     MOVE 'AdventureWorks2016_Log' TO 'D:\DATA3\ADwork2_log.ldf'

--Verify certificate does not exist on JDSQL02
SELECT name, thumbprint FROM sys.certificates
GO

--Make sure connection is on JDSQL02 and Restore Certificate
--The first step is to create a Master Key. Can only perform once.
--CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'SQLProtection#1';
--GO
SELECT is_master_key_encrypted_by_server FROM sys.databases
GO
SELECT * FROM sys.symmetric_keys
GO

CREATE CERTIFICATE BackupCert FROM FILE = N'D:\Backups\BackupCertifiate.cer'
WITH PRIVATE KEY (FILE = N'D:\Backups\BackupCertificate.pvk',
DECRYPTION BY PASSWORD = N'J3nnY8675309');



