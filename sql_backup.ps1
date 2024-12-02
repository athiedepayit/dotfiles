param (
	[Parameter(Mandatory=$true)]
	$Databases,
	[Parameter(Mandatory=$true)]
	$Server,
	[Parameter(Mandatory=$true)]
	$StorageAccount,
	[Parameter(Mandatory=$true)]
	$BlobContainer,
	[Parameter(Mandatory=$true)]
	$User,
	[Parameter(Mandatory=$true)]
	$Pass
)

function CheckDatabaseExists
{
	param (
		$Database,
		$Server
	)
	write-host "Checking for database '$Database'"
	$dbCheckQuery = "SELECT name FROM sys.databases WHERE state = 0 AND name IN ('$Database')"
	$databases = Invoke-Sqlcmd -ServerInstance "$Server" -Database "master" -Query $dbCheckQuery

	if ($databases.ItemArray.Length -lt 1 )
	{
		write-host "Database '$Database' NOT FOUND."
		return $false
	} elseif ($databases["name"] -eq $Database)
	{
		$founddb=$databases["name"]
		write-host "Found database '$Database':$founddb"
		return $true
	} else
	{
		write-host "Database '$Database' NOT FOUND."
		return $false
	}
}

# dbo.Cache_MobileLookup is a memory-optimized table and can't be pulled over to standard-tier SQL Managed Instance
function DropTableFromDatabase
{
	param (
		$Database,
		$Server
	)
	$dropTableQuery = "drop table dbo.Cache_MobileLookup"
	Invoke-Sqlcmd -ServerInstance $Server -Database $Database -QueryTimeout 3600 -Query $dropTableQuery
}

# recreate dbo.Cache_MobileLookup
function CreateTableNewDatabase
{
	param (
		$Database,
		$Server,
		$Username,
		$Password
	)
	$ConnectionString="Server=tcp:$Server,1433;Initial Catalog=$Database;Persist Security Info=False;User ID=$Username;Password=$Password;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;"
	$createDatabaseQuery = "SET ANSI_NULLS ON SET QUOTED_IDENTIFIER ON CREATE TABLE [dbo].[Cache_MobileLookup]([Type] [char](4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL, [AddedDate] [datetime] NOT NULL, [ExpiresDate] [datetime] NOT NULL, [Data] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL, INDEX [IX_Cache_MobileLookup] NONCLUSTERED ([Type]))"
	Invoke-Sqlcmd -ConnectionString $ConnectionString -Query $createDatabaseQuery
}

function BackupDatabases
{
	param (
		$Database,
		$Server,
		$StorageAccount,
		$StorageBlob
	)

	$BackupFileName="$(get-date -Format '%y%M%d-%H%m')-$Database.bak"
	write-host "backing up database $Database to $BackupFileName"
	$BackupUrl="https://$StorageAccount.blob.core.windows.net/$StorageBlob/$BackupFileName"

	$blobBackupQuery = "USE [master] BACKUP DATABASE [$Database] TO  URL = N'$BackupUrl' WITH  COPY_ONLY"

	Invoke-Sqlcmd -ServerInstance $Server -QueryTimeout 3600 -Query $blobBackupQuery
	return $BackupUrl
}

function RestoreDatabase
{
	param (
		$Database,
		$Server,
		$BackupFileUrl,
		$Username,
		$Password
	)
	$restoreDatabaseQuery="USE [master] RESTORE DATABASE [$Database] FROM  URL = N'$BackupFileUrl'"
	$ConnectionString="Server=tcp:$Server,1433;Persist Security Info=False;User ID=$Username;Password=$Password;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;"
	Invoke-Sqlcmd -ConnectionString $ConnectionString -QueryTimeout 120 -Query "IF NOT EXISTS(SELECT * FROM sys.databases WHERE name = '$Database') begin create database [$Database] end"
	Invoke-Sqlcmd -ConnectionString $ConnectionString -QueryTimeout 3600 -Query $restoreDatabaseQuery
	Start-Sleep -Seconds 10
}

<#
- split the databases input on commas, and loop through that
- for each of those databases, check if it exists on localhost (the SQL server we're running this on)
- Drop the dbo.Cache_MobileLookup table from the source database
- Back up the database to a storage blob
- Restore the database to the new instace from a storage blob
#>
foreach ($Database in $Databases.split(","))
{
	if (CheckDatabaseExists -Database $Database -Server localhost)
	{
		DropTableFromDatabase -Database $Database -Server localhost
		$BackupUrl = BackupDatabases -Database $Database -StorageAccount $StorageAccount -StorageBlob $BlobContainer -Server localhost
		$BackupUrl = 'https://s3sql.blob.core.windows.net/backupcontainer/24122-1544-mo-qa2.bak'
		write-host "Restoring from $BackupUrl"
		RestoreDatabase -Server $Server -Database $Database -BackupFileUrl $BackupUrl -Username $User -Password $Pass
		CreateTableNewDatabase -Database $Database -Server $Server -Username $User -Password $Pass
	}
}



