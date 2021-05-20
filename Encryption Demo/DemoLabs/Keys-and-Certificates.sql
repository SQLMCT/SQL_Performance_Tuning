CREATE DATABASE CellEncryption
GO

USE CellEncryption
GO
/*
--========================================================================--
Encrypting data using Symmetric Key encrypted by Asymmetric Key
The purpose of creating the Asymmetric key is to encrypt our Symmetric Key
--========================================================================--
*/


-- Creates a database master key encrypted by password $Str0nGPa$$w0rd
CREATE MASTER KEY ENCRYPTION BY PASSWORD  = '$tr0nGPa$$w0rd' 
GO
-- Creates an asymmetric key encrypted by password '$e1ectPa$$w0rd'
CREATE ASYMMETRIC KEY MyAsymmetricKey 
    WITH ALGORITHM = RSA_2048
    ENCRYPTION BY PASSWORD  = '$e1ectPa$$w0rd'
GO

--Execute the query below, to view the information about asymmetric key
SELECT * FROM [sys].[asymmetric_keys] 
GO

-- Creates an symmetric key encrypted by asymmetric key
CREATE SYMMETRIC KEY MySymmetricKey
    WITH ALGORITHM = AES_256  
    ENCRYPTION BY ASYMMETRIC KEY MyAsymmetricKey
GO

--Execute the query below, to view the information about symmetric key
SELECT * FROM [sys].[symmetric_keys] 
GO

/*
Create a table called TestEncryption. This table has three columns Name, CreditCardNumber and EncryptedCreditCardNumnber. 
The EncryptedCreatedCardNumber stores the encrypted credit card number stored in CreditCardNumber column. 
Also insert some dummy data:
*/
CREATE TABLE TestEncryption
([Name]                            [varchar] (256)
,[CreditCardNumber]                [varchar](16)
,[EncryptedCreditCardNumber]       [varbinary](max))
GO

INSERT INTO TestEncryption ([Name], [CreditCardNumber])
SELECT 'Simon Jones', '9876123456782378'
UNION ALL
SELECT 'Kim Brian', '1234567898765432'
GO

SELECT * FROM TestEncryption


-- Opening the symmetric key
OPEN SYMMETRIC KEY MySymmetricKey
DECRYPTION BY ASYMMETRIC KEY MyAsymmetricKey 
WITH PASSWORD  = '$e1ectPa$$w0rd'
GO

--Execute the following query returns the list of opened key
SELECT * FROM [sys].[openkeys]
GO

/*
Now execute the following script update the TestEncryption table to insert the values in 
EncryptedCreditCardNumbers column from CreditCardNumbers column
*/

--As you can see we are using ENCRYPTBYKEY function to encrypt the column values
UPDATE TestEncryption
SET [EncryptedCreditCardNumber] = ENCRYPTBYKEY(KEY_GUID('MySymmetricKey'), CreditCardNumber)
GO

--Once successfully executed, Verify the value inside EncryptedCreditCardNumber column by running the following query
SELECT * FROM [TestEncryption]
GO

--Executing the following query to retrieve the data inside EncryptedCreditCardNumber column using DECRYPTBYKEY encryption function
SELECT CONVERT([varchar](16), DECRYPTBYKEY([EncryptedCreditCardNumber]))
 FROM [TestEncryption]
GO


/*
--========================================================================--
Encrypting data using symmetric key encrypted using Passphrase. 
In this script, The data is encrypted using symmetric key using Phaseprase 
(see below):
--========================================================================--
*/
-- Creating symmetric key encrypted by password
CREATE SYMMETRIC KEY MySymmetricKeyPwd
    WITH ALGORITHM = AES_256    
    ENCRYPTION BY PASSWORD = 'RememberMe!' 
GO

-- Opening the symmetric key
OPEN SYMMETRIC KEY MySymmetricKeyPwd
DECRYPTION BY PASSWORD = 'RememberMe!' 
GO

-- Add EncryptedCreditCardNumber2 column in the Test encryption table. 
-- This column stores the data encrypted using key encrypted by Passphrase. 
ALTER TABLE TestEncryption
ADD [EncryptedCreditCardNumber2] [varbinary](max)
GO

--As you can see we are using ENCRYPTBYKEY function to encrypt the column values
UPDATE [TestEncryption]
SET [EncryptedCreditCardNumber2] = ENCRYPTBYKEY(KEY_GUID('MySymmetricKeyPwd'), CreditCardNumber)
GO

SELECT * FROM [TestEncryption]
GO

--Let's do the encryption and with a certificate
-- Creates a certificate 
CREATE CERTIFICATE MyCertificate
   WITH SUBJECT = 'Demo Cert', 
   EXPIRY_DATE = '10/31/2050'
GO

--View the Certificates

SELECT * FROM sys.certificates

-- Creating symmetric key encrypted by password
CREATE SYMMETRIC KEY MySymmetricKeyCert
    WITH ALGORITHM = AES_256    
    ENCRYPTION BY CERTIFICATE MyCertificate
GO

-- Opening the symmetric key
OPEN SYMMETRIC KEY MySymmetricKeyCert
DECRYPTION BY CERTIFICATE MyCertificate 
GO

-- Add two more columns in the Test encryption table. 
-- EncryptedCreditCardNumber3 column stores the data encrypted directly using certificate. 
-- EncryptedCreditCardNumber4 column stores the data encrypted key encrypted using certificate.
ALTER TABLE TestEncryption
ADD [EncryptedCreditCardNumber3] [varbinary](max),
    [EncryptedCreditCardNumber4] [varbinary](max)
GO

--You either encrypt the data directly using certificate
UPDATE [TestEncryption]
SET [EncryptedCreditCardNumber3] = ENCRYPTBYCERT(CERT_ID('MyCertificate'), CreditCardNumber)
GO


--You can encrypt the data using ENCRYPTBYKEY
UPDATE [TestEncryption]
SET [EncryptedCreditCardNumber4] = ENCRYPTBYKEY(KEY_GUID('MySymmetricKeyCert'), CreditCardNumber)
GO

-- Examine the encrypted columns
SELECT [EncryptedCreditCardNumber3] 
      ,[EncryptedCreditCardNumber4]
FROM [TestEncryption]
GO

-- Reading data by decrypting data of [EncryptedCreditCardNumber3] using DECRYPTBYCERT function
SELECT CONVERT([varchar](16), 
	DECRYPTBYCERT(CERT_ID('MyCertificate')
	,[EncryptedCreditCardNumber3])) AS [CreditCardNumber]
FROM [TestEncryption]
GO

-- Reading data by decrypting data of [EncryptedCreditCardNumber4] using DECRYPTBYKEY function
SELECT CONVERT([varchar](16)
	,DECRYPTBYKEY([EncryptedCreditCardNumber4])) AS [CreditCardNumber]
FROM [TestEncryption]
GO

