--Data Type Conversion Examples

--Implicit Conversion
SELECT 42 + 11 + '25' as Total

--Conversion Error
SELECT 42 + 11 + ' Total' as Total

--Explicit Conversion using CAST
SELECT CAST(42 + 11 as char(2)) + ' Total' as Total

--Explicit Conversion using CONVERT
SELECT CONVERT(char(2), 42 + 11) + ' Total' as Total