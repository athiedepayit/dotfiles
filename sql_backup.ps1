param (
	[Parameter(Mandatory=$true)]
	$Databases,
	[Parameter(Mandatory=$true)]
	$Server,
	[Parameter(Mandatory=$true)]
	$StorageAccount,
	[Parameter(Mandatory=$true)]
	$BlobContainer
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
	$dropDatabseQuery = "drop table dbo.Cache_MobileLookup"
	Invoke-Sqlcmd -ServerInstance $Server -Database $Database -QueryTimeout 3600 -Query $dropDatabseQuery
}

# recreate dbo.Cache_MobileLookup
function CreateTableNewDatabase
{
	param (
		$Database,
		$Server
	)
	$createDatabaseQuery = "SET ANSI_NULLS ON SET QUOTED_IDENTIFIER ON CREATE TABLE [dbo].[Cache_MobileLookup]([Type] [char](4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL, [AddedDate] [datetime] NOT NULL, [ExpiresDate] [datetime] NOT NULL, [Data] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL, INDEX [IX_Cache_MobileLookup] NONCLUSTERED ([Type]))"
	Invoke-Sqlcmd -ServerInstance $Server -Database $Database -QueryTimeout 3600 -Query $createDatabaseQuery
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

	$blobBackupQuery = "USE [master] BACKUP DATABASE [$Database] TO  URL = N'https://$StorageAccount.blob.core.windows.net/$StorageBlob/$BackupFileName' WITH  COPY_ONLY"

	Invoke-Sqlcmd -ServerInstance $Server -QueryTimeout 3600 -Query $blobBackupQuery
}

foreach ($Database in $Databases.split(","))
{
	if (CheckDatabaseExists -Database $Database -Server $Server)
	{
		DropTableFromDatabase -Database $Database -Server $Server
		BackupDatabases -Database $Database -StorageAccount $StorageAccount -StorageBlob $BlobContainer -Server $Server
	}
}

