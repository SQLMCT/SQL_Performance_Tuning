/*
This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.  
THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  
We grant You a nonexclusive, royalty-free right to use and modify the 
Sample Code and to reproduce and distribute the object code form of the Sample Code, provided that You agree: (i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded; 
(ii) to include a valid copyright notice on Your software product in which the Sample Code is 
embedded; and 
(iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys’ fees, that arise or result from the use or distribution of the Sample Code.
Please note: None of the conditions outlined in the disclaimer above will supercede the terms and conditions contained within the Premier Customer Services Description.
*/

-- NOTE: These are subject to change in each version of SQL Server
-- so you should always look up current values in sys.dm_xe_map_values!
--SELECT map_key, map_value
--FROM
--  sys.dm_xe_map_values
--WHERE  name = 'statement_recompile_cause'; 

--map_key	map_value
--1		Schema changed
--2		Statistics changed
--3		Deferred compile
--4		Set option change
--5		Temp table changed
--6		Remote rowset changed
--7		For browse permissions changed
--8		Query notification environment changed
--9		PartitionView changed
--10	Cursor options changed
--11	Option (recompile) requested
--12	Parameterized plan flushed
--13	Test plan linearization
--14	Plan affecting database version changed
--15	Query Store plan forcing policy changed
--16	Query Store plan forcing failed
--17	Query Store missing the plan

;WITH Info(Recompiles, reason)
AS 
(
		 SELECT XmlColumns.value('@count[1]', 'bigint') AS [Recompiles],
                XmlColumns.value('value[1]', 'bigint')  AS [Reason]
         FROM
           (
		   SELECT Cast(t.target_data AS XML) AS TargetXml
            FROM
              sys.dm_xe_session_targets AS t
              JOIN sys.dm_xe_sessions AS s
                ON s.address = t.event_session_address
            -- find the session that we are interested in. Must specify the type and the name
            WHERE  t.target_name = 'histogram'
                   AND s.name = 'WhyDidThatRecompile') AS recompiles
           CROSS APPLY TargetXml.nodes('/HistogramTarget/Slot') AS T2(XmlColumns)
)
SELECT Recompiles,
       v.[map_value] AS cause
FROM
  Info i
  JOIN sys.dm_xe_map_values v
    ON i.reason = v.map_key
WHERE  name = 'statement_recompile_cause' 
order by Recompiles desc;

