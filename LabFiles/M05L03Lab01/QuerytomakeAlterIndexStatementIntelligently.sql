USE [AdventureWorksPTO]
GO
Declare @pageCount int = 50 

SELECT * ,
CASE
	WHEN  Percentage_Frag between 10 and  30.0 and Page_Count>=@pageCount  and partition_number <=1 then
						'Use '+db_name()+ N';ALTER INDEX ' + index_name + N' ON ' + [schema_name] + N'.' + Table_Name + N' REORGANIZE;'
	WHEN  Percentage_Frag between 10 and  30.0 and Page_Count>=@pageCount  and partition_number >=1 then
	                   	'Use '+db_name()+ N';ALTER INDEX ' + index_name + N' ON ' + [schema_name] + N'.' + Table_Name + N' REORGANIZE'+ N'  PARTITION=' + CAST(partition_number AS nvarchar(10))+';'
	WHEN  Percentage_Frag> 30.0 and Page_Count>=@pageCount  and partition_number <=1 THEN
				'Use '+db_name()+ N';ALTER INDEX ' + index_name + N' ON ' +  [schema_name]  + N'.' + Table_Name + N' REBUILD;'
	WHEN  Percentage_Frag> 30.0and Page_Count>=@pageCount   and partition_number >1 THEN
				'Use '+db_name()+ N';ALTER INDEX ' + index_name + N' ON ' +  [schema_name]  + N'.' + Table_Name + N' REBUILD'+ N'  PARTITION=' + CAST(partition_number AS nvarchar(10))+';'
     Else ''
END
Indexstatement
FROM ToBEworked
---------------Clean up------------------
--DROP TABLE ToBEworked