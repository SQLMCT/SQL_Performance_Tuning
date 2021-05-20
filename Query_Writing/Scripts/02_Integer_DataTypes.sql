--Integer Data Types Example

DECLARE @tinyint as tinyint = 255
DECLARE @smallint as smallint = 32767
DECLARE @integer as int = 2147483647
DECLARE @bigint as bigint = 922337203685477807

SELECT @tinyint as TinyInteger,
	   @smallint as SmallInteger,
	   @integer as RegularInteger,
	   @bigint as BigInteger
GO