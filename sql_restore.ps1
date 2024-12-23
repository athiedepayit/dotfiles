 param(
	[Parameter(Mandatory=$true)][string]$SourceDB,
    [Parameter(Mandatory=$true)][string]$TargetDB
)
$ErrorActionPreference="stop"

$global:Server = "S3-DEV3-VM" #S3-DEV1-VM, S3-DEV2-VM, S3-SQL-LoadTesting, Tribes-TEST, S3-SQL-DWH
$global:UserId = "svc-devsql"
$global:Password = "SGdBf1wxwwnnPoMMlvRz"
$global:Path = "D:\temp"

$global:DBList = Invoke-Sqlcmd -ServerInstance $global:Server -Database "master" -Query "SELECT name FROM sys.databases WHERE state = 0"

if ($Global:DBList.name -contains $SourceDB) {
    Write-Host "$SourceDB does exist."
} else {
    Write-Error "$SourceDB does not exist."
    exit
}
if ($Global:DBList.name -contains $TargetDB) {
    Write-Host "$TargetDB does exist."
} else {
    Write-Error "$TargetDB does not exist"
    exit
}


function getDataDrive($db) {
    $datafiles=@{}
    $getdatafiles="SELECT db.name AS DBName,type_desc AS FileType, Physical_Name AS Location FROM sys.master_files mf INNER JOIN sys.databases db ON db.database_id = mf.database_id where db.name = '$db'"
    $dbfiles=Invoke-Sqlcmd -Query $getdatafiles -ServerInstance $global:Server -Database "master"
    $dataFile=$($dbfiles|Where-Object "FileType" -eq "ROWS"|select -ExpandProperty "Location")
    $dataDrive=$dataFile.Substring(0,1)
    return $dataDrive
}

function takeBackup($SourceDB)
{
	Write-Host "Taking Backup..."
	If(!(test-path -PathType container $global:Path))
	{
		New-Item -ItemType Directory -Path $global:Path
	}

    $dt=date -Format "%y-%m-%d_%H-%M_"
    $backuppath=$global:Path+"\"+$dt+$SourceDB+".bak"
    $bkupQuery="BACKUP DATABASE [$SourceDB] TO DISK = '$backuppath' WITH COPY_ONLY;"
    write-host $bkupQuery
	invoke-sqlcmd -Query $bkupQuery -ServerInstance $global:Server -Database "master" -QueryTimeout 3600
    return $backuppath
}

function restoreBackup($backupFile, $targetDB)
{
	Write-Host "Restoring $backupFile to $targetDB ..."

}

function getDiskMBFree($drive) {
    $space=Get-Volume -DriveLetter $drive
    return $space.SizeRemaining/(1024*1024)
}

function getDbSize($db)
{
	$fileDataQuery="SELECT D.name, F.Name AS FileType, F.physical_name AS PhysicalFile, F.state_desc AS OnlineStatus, CAST((F.size*8)/1024 AS VARCHAR(26)) AS FileSizeMB FROM  sys.master_files F INNER JOIN sys.databases D ON D.database_id = F.database_id ORDER BY D.name"
	$fileData = Invoke-Sqlcmd -Query $fileDataQuery -ServerInstance $global:Server -Database "master"
    $dbData=$($fileData | Where-Object "name" -eq "$db" | measure-object "FileSizeMB" -sum).sum
	return $dbData
}

# obtain sizes and data file location for source and dest db

$srcSize=getDbSize($SourceDB)
$srcFiles=getDataDrive($SourceDB)
write-host $SourceDb "size" $srcSize "Located on drive" $srcFiles
$dstSize=getDbSize($TargetDB)
$dstFiles=getDataDrive($TargetDB)
write-host $TargetDB "size" $dstSize "Located on drive" $dstFiles

# basic free space check on dest drive
$mbFree=getDiskMBFree($dstFiles)
if ($mbFree -gt $srcSize) {
    write-host "Yep, enough space"
}
else {
    write-host "not enough space"
    exit 1
}

$bkupfile=takeBackup($SourceDB)

restoreBackup($bkupfile, $TargetDB)

