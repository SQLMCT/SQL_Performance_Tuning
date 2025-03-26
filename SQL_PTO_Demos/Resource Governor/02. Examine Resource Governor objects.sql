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
-- Resource Governor queries


-- https://msdn.microsoft.com/en-us/library/bb934099.aspx
-- sys.dm_resource_governor_configuration (Transact-SQL)
USE master;
go
-- NOTE: there is permanent and in-memory tables
-- Get the stored metadata.  
SELECT Object_schema_name(classifier_function_id) AS 'Classifier UDF schema in metadata'
       ,OBJECT_NAME(classifier_function_id)       AS 'Classifier UDF name in metadata'
FROM
  sys.resource_governor_configuration;
go
-- Get the in-memory configuration.  
SELECT Object_schema_name(classifier_function_id) AS 'Active classifier UDF schema'
       ,OBJECT_NAME(classifier_function_id)       AS 'Active classifier UDF name'
FROM
  sys.dm_resource_governor_configuration;
go


-- https://msdn.microsoft.com/en-us/library/bb934023.aspx
-- sys.dm_resource_governor_resource_pools (Transact-SQL)
SELECT *
FROM
  sys.dm_resource_governor_resource_pools;

SELECT *
FROM
  sys.dm_resource_governor_workload_groups; 
