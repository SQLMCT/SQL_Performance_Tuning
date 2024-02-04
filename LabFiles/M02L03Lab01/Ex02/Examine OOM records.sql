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
;WITH rb
AS (
	SELECT CAST (record as xml) record_xml FROM sys.dm_os_ring_buffers
		WHERE ring_buffer_type = 'RING_BUFFER_OOM'
)
SELECT
rx.value('(@id)[1]', 'bigint') AS RecordID
,DATEADD (ms, -1 * osi.ms_ticks - rx.value('(@time)[1]', 'bigint'), GETDATE()) AS DateOccurred
,rx.value('(OOM/Action)[1]', 'varchar(30)') AS MemoryAction
,rx.value('(OOM/Pool)[1]', 'int') AS MemoryPool
,rx.value('(MemoryRecord/MemoryUtilization)[1]', 'bigint') AS MemoryUtilization
FROM rb
CROSS APPLY rb.record_xml.nodes('Record') record(rx)
CROSS JOIN sys.dm_os_sys_info osi
ORDER BY rx.value('(@id)[1]', 'bigint') 
