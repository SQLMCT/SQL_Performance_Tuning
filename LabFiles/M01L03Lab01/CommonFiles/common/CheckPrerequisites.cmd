IF "%SQLSERVER%"=="" (
  @ECHO Warning: SQLSERVER env var undefined - assuming a default SQL instance. 
  SET SQLSERVER=(local)
)

REM Check for connectivity
sqlcmd.exe -E -S%SQLSERVER% -Q"select 1"  > NUL 2>&1
IF "%ERRORLEVEL%" NEQ "0" (
  @ECHO.
  @ECHO ERROR: Unable to connect to SQL instance "%SQLSERVER%".  If your SQL instance 
  @ECHO is not a local default instance, set the SQLSERVER environment variable 
  @ECHO to the instance's name before running the scenario. 
  @ECHO.
  EXIT /B 1
)

REM Check for AdventureWorks database
sqlcmd.exe -E -S%SQLSERVER% -Q"exit (select count(*) from master..sysdatabases where name = 'AdventureWorksPTO')" > NUL 2>&1
IF %errorlevel%==0 CALL :ManualAWInstructions

:NormalExit
EXIT /B 0
GOTO :eof



:ManualAWInstructions
@ECHO You can manually install "AdventureWorks2012 Database and rename it AdventureWorksPTO" from: 
@ECHO    http://www.codeplex.com/MSFTDBProdSamples/Release
EXIT /B 1
GOTO :eof
