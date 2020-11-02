--Character Data Types Example
DECLARE @String1 AS char(10) = 'Hello'
DECLARE @String2 varchar(10)

SET @String2 = 'World'

--Concatenate the strings and notice the spaces.
SELECT @String1 + @String2 AS 'Concatenation'

--The LEN Function shows how many characters are in a string.
SELECT LEN(@String1) AS 'Length_1', LEN(@String2) AS 'Length_2'

--The DATALENGTH Function shows how many bytes are in a string.
SELECT DATALENGTH(@String1) AS 'Bytes_1' ,DATALENGTH(@String2) AS 'Bytes_2'
GO
