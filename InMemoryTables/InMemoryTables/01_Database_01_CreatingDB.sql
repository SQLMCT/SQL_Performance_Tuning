/* 
This Sample Code is provided for the purpose of illustration only and is not intended
	to be used in a production environment. THIS SAMPLE CODE AND ANY RELATED INFORMATION 
	ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, 
	INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS 
	FOR A PARTICULAR PURPOSE. 
We grant You a nonexclusive, royalty-free right to use and modify the Sample Code
	and to reproduce and distribute the object code form of the Sample Code, provided 
	that You agree: 
	(i) to not use Our name, logo, or trademarks to market Your software product in 
		which the Sample Code is embedded; 
	(ii) to include a valid copyright notice on Your software product in which the Sample 
		Code is embedded; and 
	(iii) to indemnify, hold harmless, and defend Us and our suppliers from and against 
		any claims or lawsuits, including attorneys fees, that arise or result from the 
		use or distribution of the Sample Code.
*/

/* Demonstration: Performance Improvement of In-Memory OLTP
https://learn.microsoft.com/en-us/sql/relational-databases/in-memory-oltp/demonstration-performance-improvement-of-in-memory-oltp?view=sql-server-ver16
*/

USE Master
GO
DROP DATABASE IF EXISTS [MemoryOptimizedDB]
GO
CREATE DATABASE [MemoryOptimizedDB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'MemoryOptDB', FILENAME = N'E:\MemoryDemo\SQLData\MemoryOptDB.mdf' , SIZE = 524288KB , FILEGROWTH = 262144KB )
 LOG ON 
( NAME = N'MemoryOptDB_log', FILENAME = N'E:\MemoryDemo\SQLLog\MemoryOptDB_log.ldf' , SIZE = 131072KB , FILEGROWTH = 262144KB )
GO
  
ALTER DATABASE [MemoryOptimizedDB] ADD FILEGROUP [imoltp_mod]  
    CONTAINS MEMORY_OPTIMIZED_DATA;  
  
ALTER DATABASE [MemoryOptimizedDB] ADD FILE  
    (name = [imoltp_dir], filename= 'E:\MemoryDemo\imoltp_dir')  
    TO FILEGROUP imoltp_mod;  
GO 
  
USE [MemoryOptimizedDB];  
GO

--This is to fix a domain authentication issue for John.
ALTER AUTHORIZATION ON DATABASE::[MemoryOptimizedDB] TO [Deardurff];
GO