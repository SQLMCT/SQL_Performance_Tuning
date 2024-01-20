IF "%1"=="" (
  @ECHO Warning: SQLSERVER env var undefined - assuming a default SQL instance. 
  SET SQLSERVER=.
) ELSE (
  SET SQLSERVER=%1
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

REM Check for AdventureWorksPTO database
sqlcmd.exe -E -S%SQLSERVER% -Q"exit (select count(*) from master..sysdatabases where name = 'AdventureWorksPTO')" > NUL 2>&1
IF %errorlevel%==0 CALL :InstallAW

:NormalExit
EXIT /B 0
GOTO :eof



:InstallAW
@ECHO %time% - Attempting to install AdventureWorksPTO database (this is a one-time operation)
@ECHO %time% - Extracting AdventureWorksPTO database backup...
..\bin\7za.exe e -y awdb.zip -o%TEMP%
IF %errorlevel% neq 0 (
  @ECHO ERROR: Unzip failed
  GOTO :ManualAWInstructions
)
@ECHO %time% - Restoring AdventureWorksPTO database...
sqlcmd -E -S%SQLSERVER% -Q"restore database AdventureWorksPTO from disk = '%temp%\awdb.bak' with stats=10"
del %TEMP%\awdb.bak
sqlcmd.exe -E -S%SQLSERVER% -Q"exit (select count(*) from master..sysdatabases where name = 'AdventureWorksPTO')"  > NUL
IF %errorlevel%==0 (
  @ECHO.
  @ECHO ERROR: Restore failed
  GOTO :ManualAWInstructions
)
REM Done. 
EXIT /B 0

:ManualAWInstructions
@ECHO You can manually install "AdventureWorksDB.msi" from: 
@ECHO    http://www.codeplex.com/MSFTDBProdSamples/Release/ProjectReleases.aspx?ReleaseId=5705
EXIT /B 1
GOTO :eof
