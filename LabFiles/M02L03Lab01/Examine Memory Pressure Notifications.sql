SELECT CONVERT (varchar(30), GETDATE(), 121) as [RunTime], 
dateadd (ms, (rbf.[timestamp] - tme.ms_ticks), GETDATE()) as [Notification_Time],  
cast(record as xml).value('(//Record/ResourceMonitor/Notification)[1]', 'varchar(30)') AS [Notification_type],  
cast(record as xml).value('(//Record/MemoryRecord/MemoryUtilization)[1]', 'bigint') AS [MemoryUtilization %],  
cast(record as xml).value('(//Record/MemoryNode/@id)[1]', 'bigint') AS [Node Id],  
cast(record as xml).value('(//Record/ResourceMonitor/IndicatorsProcess)[1]', 'int') AS [Process_Indicator],  
cast(record as xml).value('(//Record/ResourceMonitor/IndicatorsSystem)[1]', 'int') AS [System_Indicator], 
cast(record as xml).value('(//Record/ResourceMonitor/Effect/@type)[1]', 'varchar(30)') AS [type],  
cast(record as xml).value('(//Record/ResourceMonitor/Effect/@state)[1]', 'varchar(30)') AS [state],  
cast(record as xml).value('(//Record/ResourceMonitor/Effect/@reversed)[1]', 'int') AS [reserved], 
cast(record as xml).value('(//Record/ResourceMonitor/Effect)[1]', 'bigint') AS [Effect], 
   
cast(record as xml).value('(//Record/ResourceMonitor/Effect[2]/@type)[1]', 'varchar(30)') AS [type],  
cast(record as xml).value('(//Record/ResourceMonitor/Effect[2]/@state)[1]', 'varchar(30)') AS [state],  
cast(record as xml).value('(//Record/ResourceMonitor/Effect[2]/@reversed)[1]', 'int') AS [reserved],  
cast(record as xml).value('(//Record/ResourceMonitor/Effect)[2]', 'bigint') AS [Effect], 
   
cast(record as xml).value('(//Record/ResourceMonitor/Effect[3]/@type)[1]', 'varchar(30)') AS [type],  
cast(record as xml).value('(//Record/ResourceMonitor/Effect[3]/@state)[1]', 'varchar(30)') AS [state],  
cast(record as xml).value('(//Record/ResourceMonitor/Effect[3]/@reversed)[1]', 'int') AS [reserved],  
cast(record as xml).value('(//Record/ResourceMonitor/Effect)[3]', 'bigint') AS [Effect], 
   
cast(record as xml).value('(//Record/MemoryNode/ReservedMemory)[1]', 'bigint') AS [SQL_ReservedMemory_KB],  
cast(record as xml).value('(//Record/MemoryNode/CommittedMemory)[1]', 'bigint') AS [SQL_CommittedMemory_KB],  
cast(record as xml).value('(//Record/MemoryNode/AWEMemory)[1]', 'bigint') AS [SQL_AWEMemory],  
cast(record as xml).value('(//Record/MemoryNode/SinglePagesMemory)[1]', 'bigint') AS [SinglePagesMemory],  
cast(record as xml).value('(//Record/MemoryNode/MultiplePagesMemory)[1]', 'bigint') AS [MultiplePagesMemory],  
cast(record as xml).value('(//Record/MemoryRecord/TotalPhysicalMemory)[1]', 'bigint') AS [TotalPhysicalMemory_KB],  
cast(record as xml).value('(//Record/MemoryRecord/AvailablePhysicalMemory)[1]', 'bigint') AS [AvailablePhysicalMemory_KB],  
cast(record as xml).value('(//Record/MemoryRecord/TotalPageFile)[1]', 'bigint') AS [TotalPageFile_KB],  
cast(record as xml).value('(//Record/MemoryRecord/AvailablePageFile)[1]', 'bigint') AS [AvailablePageFile_KB],  
cast(record as xml).value('(//Record/MemoryRecord/TotalVirtualAddressSpace)[1]', 'bigint') AS [TotalVirtualAddressSpace_KB],  
cast(record as xml).value('(//Record/MemoryRecord/AvailableVirtualAddressSpace)[1]', 'bigint') AS [AvailableVirtualAddressSpace_KB],  
cast(record as xml).value('(//Record/@id)[1]', 'bigint') AS [Record Id],  
cast(record as xml).value('(//Record/@type)[1]', 'varchar(30)') AS [Type],  
cast(record as xml).value('(//Record/@time)[1]', 'bigint') AS [Record Time], 
tme.ms_ticks as [Current Time] 
FROM sys.dm_os_ring_buffers rbf 
cross join sys.dm_os_sys_info tme 
where rbf.ring_buffer_type = 'RING_BUFFER_RESOURCE_MONITOR' 
	--and cast(record as xml).value('(//Record/ResourceMonitor/Notification)[1]', 'varchar(30)') = 'RESOURCE_MEMPHYSICAL_LOW' 
ORDER BY rbf.timestamp ASC