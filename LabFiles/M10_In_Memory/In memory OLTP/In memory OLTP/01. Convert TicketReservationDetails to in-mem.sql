-- USE [TicketReservations]
USE InMemoryOLTP
GO

DROP TABLE IF EXISTS [dbo].[TicketReservationDetail]
GO

-- SCHEMA and DATA: PK as NONCLUSTERED
CREATE TABLE [dbo].[TicketReservationDetail]
(
	[TicketReservationID] [bigint] NOT NULL,
	[TicketReservationDetailID] [bigint] IDENTITY(1,1) NOT NULL,
	[Quantity] [int] NOT NULL,
	[FlightID] [int] NOT NULL,
	[Comment] [nvarchar](1000) NULL,

	CONSTRAINT [PK_TicketReservationDetail]  PRIMARY KEY NONCLUSTERED 
	(
		[TicketReservationDetailID] ASC
	)
 )WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_AND_DATA )

GO