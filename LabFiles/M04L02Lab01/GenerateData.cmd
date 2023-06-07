IF "%SQLSERVER%"=="" (
  SET SQLSERVER=SQLPTO
)


start sqlcmd -S%SQLSERVER% -dAdventureWorksPTO -i"E:\LabFiles\M04L02Lab01\AddTables.SQL"
start sqlcmd -S%SQLSERVER% -dAdventureWorksPTO -i"E:\LabFiles\M04L02Lab01\AddData.SQL"

