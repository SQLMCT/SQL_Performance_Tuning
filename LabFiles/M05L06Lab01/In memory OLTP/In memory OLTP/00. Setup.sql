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
-- destroy and recreate InMemoryOLTP database
USE master;
go
IF DB_ID('InMemoryOLTP') IS NOT NULL
  BEGIN
      ALTER DATABASE [InMemoryOLTP] SET SINGLE_USER WITH ROLLBACK immediate;
      DROP DATABASE [InMemoryOLTP];
  END;
CREATE DATABASE [InMemoryOLTP] CONTAINMENT = NONE 
ON PRIMARY ( NAME = N'InMemoryOLTP_data', FILENAME = N'F:\SQLData\InMemoryOLTP_data.mdf' ), 
	FILEGROUP [InMemoryOLTP_InMemory] CONTAINS MEMORY_OPTIMIZED_DATA 
	DEFAULT ( NAME = N'InMemoryOLTP_InMemory', FILENAME = N'M:\InMemoryOLTP_mopt' ) 
	LOG ON ( NAME = N'InMemoryOLTP_log', FILENAME = N'G:\SQLLog\InMemoryOLTP_log.ldf' )
GO

USE InMemoryOLTP;
GO 
SET NOCOUNT ON;
SET XACT_ABORT ON;



-- 1. validate that In-Memory OLTP is supported
IF SERVERPROPERTY(N'IsXTPSupported') = 0 
BEGIN                                    
    PRINT N'Error: In-Memory OLTP is not supported for this server edition or database pricing tier.';
END 
IF DB_ID() < 5
BEGIN                                    
    PRINT N'Error: In-Memory OLTP is not supported in system databases. Connect to a user database.';
END 
ELSE 
BEGIN 
	BEGIN TRY;
-- 2. add MEMORY_OPTIMIZED_DATA filegroup when not using Azure SQL DB
	IF SERVERPROPERTY('EngineEdition') != 5 
	BEGIN
		DECLARE @SQLDataFolder nvarchar(max) = cast(SERVERPROPERTY('InstanceDefaultDataPath') as nvarchar(max))
		DECLARE @MODName nvarchar(max) = DB_NAME() + N'_mod';
		DECLARE @MemoryOptimizedFilegroupFolder nvarchar(max) = @SQLDataFolder + @MODName;

		DECLARE @SQL nvarchar(max) = N'';

		-- add filegroup
		IF NOT EXISTS (SELECT 1 FROM sys.filegroups WHERE type = N'FX')
		BEGIN
			SET @SQL = N'
ALTER DATABASE CURRENT 
ADD FILEGROUP ' + QUOTENAME(@MODName) + N' CONTAINS MEMORY_OPTIMIZED_DATA;';
			EXECUTE (@SQL);

		END;

		-- add container in the filegroup
		IF NOT EXISTS (SELECT * FROM sys.database_files WHERE data_space_id IN (SELECT data_space_id FROM sys.filegroups WHERE type = N'FX'))
		BEGIN
			SET @SQL = N'
ALTER DATABASE CURRENT
ADD FILE (name = N''' + @MODName + ''', filename = '''
						+ @MemoryOptimizedFilegroupFolder + N''') 
TO FILEGROUP ' + QUOTENAME(@MODName);
			EXECUTE (@SQL);
		END
	END

	-- 3. set compat level to 130 if it is lower
	IF (SELECT compatibility_level FROM sys.databases WHERE database_id=DB_ID()) < 130
		ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL = 130 

	-- 4. enable MEMORY_OPTIMIZED_ELEVATE_TO_SNAPSHOT for the database
	ALTER DATABASE CURRENT SET MEMORY_OPTIMIZED_ELEVATE_TO_SNAPSHOT = ON;


    END TRY
    BEGIN CATCH
        PRINT N'Error enabling In-Memory OLTP';
		IF XACT_STATE() != 0
			ROLLBACK;
        THROW;
    END CATCH;
END
GO
--DROP PROCEDURE IF EXISTS dbo.ReadMultipleReservations
--DROP PROCEDURE IF EXISTS dbo.BatchInsertReservations
--DROP PROCEDURE IF EXISTS [dbo].[InsertReservationDetails]
--DROP PROCEDURE IF EXISTS UpdateReservationDetails
--DROP PROCEDURE IF EXISTS DeleteReservationDetails

DROP SEQUENCE IF EXISTS [dbo].[TicketReservationSequence]
DROP TABLE IF EXISTS [dbo].[TicketReservationDetail]
GO

CREATE SEQUENCE [dbo].[TicketReservationSequence] 
 AS [int]
 START WITH 1
 INCREMENT BY 1
 MINVALUE -2147483648
 MAXVALUE 2147483647
 CACHE  50000 
GO

CREATE TABLE [dbo].[TicketReservationDetail]
(
	[TicketReservationID] [bigint] NOT NULL,
	[TicketReservationDetailID] [bigint] IDENTITY(1,1) NOT NULL,
	[Quantity] [int] NOT NULL,
	[FlightID] [int] NOT NULL,
	[Comment] [nvarchar](1000) NULL,

		CONSTRAINT [PK_TicketReservationDetail]  PRIMARY KEY 
	(
		[TicketReservationDetailID] ASC
	)
)
GO

-- SELECT * FROM [dbo].[TicketReservationDetail]


CREATE OR ALTER PROCEDURE InsertReservationDetails(@TicketReservationID int, @LineCount int, @Comment NVARCHAR(1000), @FlightID int)
AS
BEGIN 


	DECLARE @loop int = 0;
	while (@loop < @LineCount)
	BEGIN
		INSERT INTO dbo.TicketReservationDetail (TicketReservationID, Quantity, FlightID, Comment) 
			VALUES(@TicketReservationID, @loop % 8 + 1, @FlightID, @Comment);
		SET @loop += 1;
	END
END
GO

CREATE OR ALTER PROCEDURE UpdateReservationDetails(@ServerTransactions int, @RowsPerTransaction int, @ThreadID int)
AS
BEGIN 
	DECLARE @tranCount int = 0;
	DECLARE @CurrentSeq int = 0;
	DECLARE @Sum int = 0;
	DECLARE @loop int = 0;

	DECLARE @TS Datetime2;
	DECLARE @Char_TS NVARCHAR(23);
	SET @TS = SYSDATETIME();
	SET @Char_TS = CAST(@TS AS NVARCHAR(23));


	WHILE (@tranCount < @ServerTransactions)	
	BEGIN
		BEGIN TRY
			SELECT @CurrentSeq = RAND() * IDENT_CURRENT(N'dbo.TicketReservationDetail')
			SET @loop = 0
			BEGIN TRAN
			WHILE (@loop < @RowsPerTransaction)
			BEGIN
				UPDATE dbo.TicketReservationDetail 
				SET Comment = @Char_TS,
					Quantity -= 1
				WHERE 
					TicketReservationDetailID = @CurrentSeq - @loop;
--				SELECT @Sum += FlightID from dbo.TicketReservationDetail where TicketReservationDetailID = @CurrentSeq - @loop;

				SET @loop += 1;
			END
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			IF XACT_STATE() = -1
				ROLLBACK TRAN
			;THROW
		END CATCH
		SET @tranCount += 1;
	END
END
GO

CREATE OR ALTER PROCEDURE DeleteReservationDetails(@ServerTransactions int, @RowsPerTransaction int, @ThreadID int)
AS
BEGIN 
	DECLARE @tranCount int = 0;
	DECLARE @CurrentSeq int = 0;
	DECLARE @Sum int = 0;
	DECLARE @loop int = 0;

	WHILE (@tranCount < @ServerTransactions)	
	BEGIN
		BEGIN TRY
			SELECT @CurrentSeq = RAND() * IDENT_CURRENT(N'dbo.TicketReservationDetail')
			SET @loop = 0
			BEGIN TRAN
			WHILE (@loop < @RowsPerTransaction)
			BEGIN
				DELETE dbo.TicketReservationDetail 
				WHERE 
					TicketReservationDetailID = @CurrentSeq - @loop;
				SET @loop += 1;
			END
			COMMIT TRAN

		END TRY
		BEGIN CATCH
			IF XACT_STATE() = -1
				ROLLBACK TRAN
			;THROW
		END CATCH
		SET @tranCount += 1;
	END
END
GO



CREATE OR ALTER PROCEDURE BatchInsertReservations(@ServerTransactions int, @RowsPerTransaction int, @ThreadID int)
AS
BEGIN
	DECLARE @tranCount int = 0;
	DECLARE @TS Datetime2;
	DECLARE @Char_TS NVARCHAR(23);
	DECLARE @CurrentSeq int = 0;

	SET @TS = SYSDATETIME();
	SET @Char_TS = CAST(@TS AS NVARCHAR(23));
	WHILE (@tranCount < @ServerTransactions)	
	BEGIN
		BEGIN TRY
			BEGIN TRAN
			SET @CurrentSeq = NEXT VALUE FOR TicketReservationSequence ;
			EXEC InsertReservationDetails  @CurrentSeq, @RowsPerTransaction, @Char_TS, @ThreadID;
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			IF XACT_STATE() = -1
				ROLLBACK TRAN
			;THROW
		END CATCH
		SET @tranCount += 1;
	END
END
GO

ALTER DATABASE CURRENT SET MEMORY_OPTIMIZED_ELEVATE_TO_SNAPSHOT=ON  
GO
CHECKPOINT
SELECT 
	 is_memory_optimized_elevate_to_snapshot_on
	,* 
FROM 
	sys.databases
GO

CREATE OR ALTER PROCEDURE ReadMultipleReservations(@ServerTransactions int, @RowsPerTransaction int, @ThreadID int)
AS
BEGIN 
	DECLARE @tranCount int = 0;
	DECLARE @CurrentSeq int = 0;
	DECLARE @Sum int = 0;
	DECLARE @loop int = 0;

	DECLARE @TS Datetime2;
	DECLARE @Char_TS NVARCHAR(23);
	SET @TS = SYSDATETIME();
	SET @Char_TS = CAST(@TS AS NVARCHAR(23))+' UPD';

	DECLARE @currentOperation INT = 0
    DECLARE @retry INT = 10;  
	DECLARE @DELAY VARCHAR(12) = '00:00:00.001';
    WHILE (@retry > 0)  
    BEGIN  

		WHILE (@tranCount < @ServerTransactions)	
		BEGIN
			BEGIN TRY
				SELECT @CurrentSeq = RAND() * IDENT_CURRENT(N'dbo.TicketReservationDetail')
				SELECT @currentOperation = @CurrentSeq % 3

				BEGIN TRAN

				-- select X rows
				IF @currentOperation = 0 
				BEGIN
					SET @loop = 0
					WHILE (@loop < @RowsPerTransaction)
					BEGIN
						SELECT @Sum += FlightID from dbo.TicketReservationDetail where TicketReservationDetailID = @CurrentSeq - @loop;
						SET @loop += 1;
					END
				END

				-- update up to x%3 rows
				IF @currentOperation = 1 
				BEGIN
					SET @loop = 0
					WHILE (@loop < 2) --  @RowsPerTransaction%6)
					BEGIN
						UPDATE dbo.TicketReservationDetail 
						SET -- Comment = @Char_TS,
							Quantity -= 1,
							[FlightID] = 0,
							[Comment] = '***'
						WHERE 
							TicketReservationDetailID = @CurrentSeq - @loop;
						SET @loop += 1;
					END
				END

				-- delete up to x%2 rows
				-- get another random# for delete
				IF @currentOperation = 2 
				BEGIN
					SET @loop = 0
					WHILE (@loop < 1 ) -- @RowsPerTransaction%3)
					BEGIN
						DELETE 
							dbo.TicketReservationDetail 
						WHERE 
							TicketReservationDetailID = @CurrentSeq - @loop;
						SET @loop += 1;
					END
				END

				COMMIT TRAN
				SET @retry = 0;  -- //Stops the loop.  

			END TRY
			-----
			-----
			BEGIN CATCH  
				PRINT 'error found...'
				SET @retry -= 1;  

				IF (@retry > 0 AND  
					ERROR_NUMBER() in (41302, 41305, 41325, 41301, 41839, 1205)  
					)  
				BEGIN  
					BEGIN
						-- https://msdn.microsoft.com/en-us/library/mt668435.aspx
						IF ERROR_NUMBER() = 41302
						BEGIN
							PRINT '41302 - Attempted to update a row that was updated in a different transaction since the start of the present transaction.'
						END
						IF ERROR_NUMBER() = 41305
						BEGIN
							PRINT '41305 - Repeatable read validation failure. A row read from a memory-optimized table this transaction has been updated by another transaction that has committed before the commit of this transaction.'
						END
						IF ERROR_NUMBER() = 41325
						BEGIN
							PRINT '41325 - Serializable validation failure. A new row was inserted into a range that was scanned earlier by the present transaction. We call this a phantom row.'
						END
						IF ERROR_NUMBER() = 41301
						BEGIN
							PRINT '41301 - Dependency failure: a dependency was taken on another transaction that later failed to commit.'
						END
						IF ERROR_NUMBER() = 41839
						BEGIN
							PRINT '41839 - Transaction exceeded the maximum number of commit dependencies.'
						END
					END
					IF XACT_STATE() = -1  
						ROLLBACK TRANSACTION;  

					WAITFOR DELAY @DELAY;
				END  
				ELSE  
				BEGIN  
					PRINT 'Suffered an error for which Retry is inappropriate.';  
					THROW;  
				END  
			END CATCH  

			-----
			-----
			SET @tranCount += 1;
		END
	END
END
GO

