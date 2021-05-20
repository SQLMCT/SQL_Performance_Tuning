#Setting Execution Policy to RemoteSigned
# Set-ExecutionPolicy -ExecutionPolicy Unrestricted

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned

Add-Type -Path "C:\Program Files (x86)\Microsoft SQL Server Management Studio 18\Common7\IDE\Microsoft.SqlServer.Smo.dll"

# instantiate the base Server object
#
$SqlServerName = "SQLSecNode1"
$SqlServer = New-Object Microsoft.SqlServer.Management.Smo.Server($SqlServerName)

$NewLoginName = "SqlSecWorkshopLab2"
$NewLogin = New-Object Microsoft.SqlServer.Management.Smo.Login($SqlServer, $NewLoginName)
$NewLogin.LoginType = [Microsoft.SqlServer.Management.Smo.LoginType]::SqlLogin

# prompt the user for a securestring password
#
$NewPassword = (Get-Credential -Message "Enter the password for the following new login" -UserName $NewLoginName).Password

# create the new login
#
$NewLogin.Create($NewPassword)

# create a user in the AdventureWorks database for this login
#
$SqlDatabaseName = "AdventureWorks"
$NewUserName = "SqlSecWorkshopLab2User"
$NewUser = New-Object Microsoft.SqlServer.Management.Smo.User($SqlServer.Databases[$SqlDatabaseName], $NewUserName)
$NewUser.Login = $NewLoginName
$NewUser.Create()
$NewUser.AddToRole("db_datareader")

# verify by running SSMS and logging in as the new login
#