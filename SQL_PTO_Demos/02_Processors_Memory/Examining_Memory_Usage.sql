--1). View the various memory clerks and their current memory allocations by name and memory node
SELECT type
       ,name
       ,memory_node_id
       ,SUM(pages_kb + virtual_memory_reserved_kb
            + virtual_memory_committed_kb
            + awe_allocated_kb
            + shared_memory_reserved_kb
            + shared_memory_committed_kb) AS TotalKB
FROM
  sys.dm_os_memory_clerks
  -- uncomment the following line to see just the object store clerks
  --where name like '%OBJ%'
GROUP  BY
  type
  ,name
  ,memory_node_id
ORDER  BY
  TotalKB DESC; 


-- 2). View the current state of the memory brokers
-- Note the current memory, the predicted future memory, the target memory and whether the memory is growing, shrinking or stable

SELECT p.pool_id
       ,p.name                   AS resource_governor_pool_name
       ,max_memory_percent
       ,max_cpu_percent
       ,cap_cpu_percent
       ,b.memory_broker_type
       ,b.allocations_kb         AS current_memory_allocated_kb
       ,b.allocations_kb_per_sec AS allocation_rate_in_kb_per_sec
       ,b.future_allocations_kb  AS near_future_allocations_kb
       ,b.target_allocations_kb
       ,b.last_notification      AS last_memory_notification
FROM
  sys.dm_os_memory_brokers b
  INNER JOIN sys.resource_governor_resource_pools p
          ON p.pool_id = b.pool_id; 

-- 3). View the output of sys.dm_os_loaded_modules

SELECT * FROM sys.dm_os_loaded_modules


