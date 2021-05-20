--Connect to JDSQL02 and try to attach files.
CREATE DATABASE AdventureWorks2016 ON
(FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.JDSQL01\MSSQL\DATA\AdventureWorks2016_Data.mdf'),
(FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.JDSQL01\MSSQL\DATA\AdventureWorks2016_Log.ldf')
FOR ATTACH
GO

--Switch back to JDSQL01 and rerun code to attach AdventureWorks2016.

--Now Backup Database on JDSQL01 and try to restore on JDSQL02
--Notice we are not using WITH ENCRYPTION on the Backup.

BACKUP DATABASE AdventureWorks2016 TO DISK = N'D:\DATA\ADWorksTDE.bak' WITH FORMAT
GO

--Try to restore on JDSQL02
RESTORE DATABASE ADWorksTDE FROM DISK = N'D:\DATA\ADWorksTDE.bak'
WITH MOVE 'AdventureWorks2016_Data' TO 'D:\DATA2\ADwork2.mdf',
     MOVE 'AdventureWorks2016_Log' TO 'D:\DATA2\ADwork2_log.ldf'

--To attach or restore on JDSQL02 we would need
--to backup the certificate on 01 and restore on 02.