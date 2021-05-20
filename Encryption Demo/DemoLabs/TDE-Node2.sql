--This is a continuation to instructions from script "C:\LabFiles\M03L02Lab01\TDE-Node1.sql" from the SQLSecurityClient machine

--Assuming steps so far is completed from the above script we are connected to SQLSecNode2 now.
--Check if SQLSecnode2 service is running and start service if you have issues with connecting to the instance.

--We need to try restoring the backup of the TDE enabled database which we had taken earlier on SQLSecNode1

--First try copying the backup "TDEdemo.bak" from \\sqlsecnode1\c$\LabFiles\TDE to \\sqlsecnode2\c$\LabFiles\TDE. 
--CREATE a similar folder structure on SQLsecnode2 as required.

--Once the backup is copied. Now lets try to restore

RESTORE DATABASE TdeDemo FROM DISK = 'C:\LabFiles\TDE\TdeDemo.bak';
GO

--You will receive the below error:

/*
Msg 33111, Level 16, State 3, Line 12
Cannot find server certificate with thumbprint '0x433C6A74D19788D99D76A83761C90AC624669A7F'.
Msg 3013, Level 16, State 1, Line 12
RESTORE DATABASE is terminating abnormally.
*/

--So we need to restore the certificate in order to restore the backup.

--Copy the certificates and private key (MyTDECert and MyTDECertPrivateKey) from SQLSecnode1 to SQLSecnode2
--From \\sqlsecnode1\c$\LabFiles\TDE to \\sqlsecnode2\c$\LabFiles\TDE

--Try creating the certificate

CREATE CERTIFICATE MyTdeCert 
FROM FILE = 'c:\LabFiles\TDE\MyTdeCert'
 WITH PRIVATE KEY 
 (  FILE = 'c:\LabFiles\TDE\MyTdeCertPrivateKey',  DECRYPTION BY PASSWORD = '997jkhUbhk$w4ez0876hKHJH5gh' 
  );
  GO

--You may receive the below error if the master key is not created on this new server.

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

CREATE CERTIFICATE MyTdeCert 
FROM FILE = 'c:\LabFiles\TDE\MyTdeCert'
 WITH PRIVATE KEY 
 (  FILE = 'c:\LabFiles\TDE\MyTdeCertPrivateKey',  DECRYPTION BY PASSWORD = '997jkhUbhk$w4ez0876hKHJH5gh' 
  );
  GO

--The certificate will now be successfully created.

-- Restore the backup now and it will be successful.

RESTORE DATABASE TdeDemo FROM DISK = 'C:\LabFiles\TDE\TdeDemo.bak';
GO 

/*
Processed 336 pages for database 'TdeDemo', file 'TdeDemo' on file 1.
Processed 3 pages for database 'TdeDemo', file 'TdeDemo_log' on file 1.
RESTORE DATABASE successfully processed 339 pages in 0.070 seconds (37.834 MB/sec).
*/

-- Cleanup. To cleanup the environment. Run it on both SQLSecNode1 and SQlSecNode2

USE master;
GO
DROP DATABASE TdeDemo;
GO
DROP CERTIFICATE MyTdeCert;
GO
