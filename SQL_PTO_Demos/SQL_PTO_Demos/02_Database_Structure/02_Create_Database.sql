--Database Demo
USE master;

--Build Database for Demo
DROP DATABASE IF EXISTS TestDB;
CREATE DATABASE TestDB ON
(NAME = Test_DB,
 FILENAME = 'D:\DATA\TestDB.mdf',
	SIZE = 10,
    MAXSIZE = 50,
    FILEGROWTH = 5)
LOG ON
(NAME = Test_DB_Log,
 FILENAME = 'D:\DATA\TestDB.ldf',
	SIZE = 5MB,
    MAXSIZE = 25MB,
    FILEGROWTH = 5MB);
GO

USE TestDB
SELECT * 
FROM sys.database_files






