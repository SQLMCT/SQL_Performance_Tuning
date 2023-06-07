

USE [AdventureWorksPTO]
GO
----------------------Check the Frgamentation again this time there should not be any fragmentation---------------
DECLARE		@ObjectID int
SELECT			@ObjectID=OBJECT_ID('NewPerson') 
--SELECT			@ObjectID ObjectID,'Newperson' as ObjectName
--------------------------------------------------------------------------------------------------------------------------------------------
IF exists ( select 1 from sys.tables where name ='ToBEworked')
Drop Table ToBEworked
SELECT 
     Case When t1.avg_fragmentation_in_percent > 30 then '==>>Rebuild'
	  When t1.avg_fragmentation_in_percent Between 10 and 30   then '==>>Reorganize'
          else '-'
     end as Recommended_Action
	 		,	    t4.name as [schema_name]
			,       t3.name as table_name
			,       t2.name as index_name
			,       index_type_desc
			,		t1.partition_number
			,		CAST(t1.avg_fragmentation_in_percent as decimal(5,2)) As Percentage_Frag
			,		t1.fragment_count  
			,		t1.avg_fragment_size_in_pages
			,		t1.page_count
			INTO ToBEworked
			FROM sys.dm_db_index_physical_stats(db_id(),@ObjectID,NULL,NULL,'LIMITED' ) t1
			inner join sys.objects t3 on (t1.object_id = t3.object_id)
			inner join sys.schemas t4 on (t3.schema_id = t4.schema_id)
			inner join sys.indexes t2 on (t1.object_id = t2.object_id and  t1.index_id = t2.index_id )
			where  t1.index_id > 0    ---Exclude Heap
					AND page_count > 1
			order by t4.name,t3.name,t2.name,partition_number  
GO
SELECT * from ToBEworked