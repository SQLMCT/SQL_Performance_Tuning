--Create Procedure Sp_KillAllSessions

Use master
go
declare @Dbname nvarchar(255)
--As 
set @Dbname ='AdventureWorksPTO'
Begin
		DECLARE @spid int, @str varchar(1000)

		DECLARE curGetSpids 
		CURSOR FOR 
		SELECT p.Spid 
		FROM master..sysprocesses p, master..sysdatabases d (NOLOCK) 
		where p.dbid = d.dbid 
		and d.name = @DBname 


		OPEN curGetSpids 
		FETCH NEXT FROM curGetSpids INTO @spid 
		WHILE(@@FETCH_STATUS<>-1) 
		BEGIN 
		SELECT @str='KILL '+CONVERT(varchar(3),@spid) 
		EXEC (@str) 
		FETCH NEXT FROM curGetSpids INTO @spid 
		END 
		CLOSE curGetSpids 
		DEALLOCATE curGetSpids 
END