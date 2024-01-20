External symptoms:

Using Task Manager, verify if -> Physical Memory -> Free- > is above 100MB. 
On 64 bit the out of physical memory threshold is 96MB.

Using Task Manager, verify -> System -> Commit (GB)
Is Total close to the Limit e.g. low on virtual memory?

Start Perfmon
Add counters:
	SQL Instance:
		Memory Manager: Target Server Memory
		Memory Manager: Total Server Memory
Check:		
	If Target < Total, a lower commit value was set, indicating external physical memory pressure.
		
Add counters:		
	Memory:
		Available MBytes
		Commit Limit
		Commited Bytes
		Pages/sec
	Paging File:
		Paging File: %Usage
		Paging File: %Usage Peak
	Process (_Total and sqlservr)
		Process: Private Bytes - Process: Working Set
		Process: Working Set  (Private Bytes)

Check:
	Commit limit – Commited Bytes = Mem that can be commited before extending the pagefile.
	%Usage = a High Value equals physical memory over commitment
	Private Bytes - Process: Working Set = Amount of process Paged Out
		Why paged out? Check LPIM in SQL Server
	Working Set  (Private Bytes) = Identify highest consumers of non-shareable memory

	
Internal symptoms:
Start Perfmon
Add counters:
	Buffer Manager: 
		Buffer Cache Hit Ratio > 90 % for OLTP
		Lazy writes/sec – Possibly 0
		Checkpoint Pages/sec (correlate) 
		Free Pages > 640 (5MB)
		Page Life Expectancy (sec) > 300
		Memory Grants Pending = 0 for OLTP