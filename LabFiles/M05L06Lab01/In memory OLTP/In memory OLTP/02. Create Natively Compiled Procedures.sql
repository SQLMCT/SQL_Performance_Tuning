USE InMemoryOLTP;
GO
-- NOTE: Cannot ALTER a natively compiled stored procedure so we must drop and create to cause
-- the compiler to produce new C code for us.
DROP PROCEDURE IF EXISTS InsertReservationDetails
GO
CREATE OR ALTER PROCEDURE InsertReservationDetails(@TicketReservationID int, @LineCount int, @Comment NVARCHAR(1000), @FlightID int)
WITH NATIVE_COMPILATION, SCHEMABINDING
AS BEGIN ATOMIC WITH (TRANSACTION ISOLATION LEVEL=SNAPSHOT, LANGUAGE=N'English')
	DECLARE @loop int = 0;
	while (@loop < @LineCount)
	BEGIN
		INSERT INTO dbo.TicketReservationDetail (TicketReservationID, Quantity, FlightID, Comment) 
		    VALUES(@TicketReservationID, @loop % 8 + 1, @FlightID, @Comment);
		SET @loop += 1;
	END
END
GO

DROP PROCEDURE IF EXISTS UpdateReservationDetails
GO
CREATE PROCEDURE UpdateReservationDetails(@TicketReservationID int, @LineCount int, @Comment NVARCHAR(1000), @FlightID int)
WITH NATIVE_COMPILATION, SCHEMABINDING
AS BEGIN ATOMIC WITH (TRANSACTION ISOLATION LEVEL=SNAPSHOT, LANGUAGE=N'English')
	DECLARE @loop int = 0;
	while (@loop < @LineCount)
	BEGIN
		UPDATE 
			dbo.TicketReservationDetail 
		SET 
			Quantity -= 1, 
			Comment = @Comment
		WHERE
			TicketReservationID = @TicketReservationID;

		SET @loop += 1;
	END
END
GO