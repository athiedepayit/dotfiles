#Requires –Modules ActiveDirectory
<#
Version 1.0
#>
param(
	[string]$MappingFile
)

$SecurityGroupOU="S3_Security_Groups"
$EntraGroupOU="AADDC Users"
$DC="DC=s3gov,DC=com"

$SecurityGroups=Get-ADGroup -Filter 'GroupCategory -eq "Security"' -SearchBase "OU=$SecurityGroupOU,$DC"|select-object -ExpandProperty Name
$EntraGroups=Get-ADGroup -Filter 'GroupCategory -eq "Security"' -SearchBase "OU=$EntraGroupOU,$DC"|select-object -ExpandProperty Name

function Sync-Groups
{
	param (
		[Parameter(Mandatory=$true)][string]$SourceGroup,
		[Parameter(Mandatory=$true)][string]$DestinationGroup
	)
	write-host "Synchronizing members of $SourceGroup and $DestinationGroup"
	$SourceUsers = Get-ADGroupMember -Identity $SourceGroup
	$DestUsers = Get-ADGroupMember -Identity $DestinationGroup

	$SourceUserNames=$SourceUsers.Name
	$DestUserNames=$DestUsers.Name

	foreach ($SrcUser in $SourceUsers)
	{
		$SrcUserName=$SrcUser.Name
		$SrcUserAccount=$SrcUser.SamAccountName
		if ($DestUserNames -contains $SrcUserName)
		{
			Write-Host " - $SrcUserName already in $DestinationGroup"
		} else
		{

			Write-Host " - Adding $SrcUserName to $DestinationGroup"
			Add-ADGroupMember -Identity $DestinationGroup -Members $SrcUserAccount -Confirm:$False

		}
	}

	foreach ($DestUser in $DestUsers)
	{
		$DestUserName=$DestUser.Name
		$DestUserAccount=$DestUser.SamAccountName
		if ($SourceUserNames -notcontains $DestUserName)
		{
			Write-Host " - Removing $DestUserName from $DestinationGroup"
			Remove-ADGroupMember -Identity $DestinationGroup -Members $DestUserAccount -Confirm:$False
		}
	}

	Write-Host "---"
}

function Read-MapFile
{
	param(
		[Parameter(Mandatory=$true)]
		[string]$Path
	)
	# Reads a mapping file of Cloud Group -> AD group
	# File should be one mapping per line, colon-delimited
	# example line:
	# sqladmin:SQL admin

	$GroupMaps=@{}

	if (!(Test-Path $Path -PathType Leaf))
	{
		Write-Host "File not found: $Path"
		return $GroupMaps
	}

	$MapFile=Get-Content -Path $Path
	foreach ($line in $MapFile)
	{
		$LineSplit=$line.Split(":")
		$Key=$LineSplit[0]
		$Value=$LineSplit[1]
		$GroupMaps[$Key]=$Value
	}

	foreach ($Key in $GroupMaps.Keys)
	{
		Write-host $Key -> $GroupMaps[$Key]
	}
	return $GroupMaps
}

function Update-Groups
{
	param (
		[Hashtable]$GroupMap
	)

	# Go over "found" groups
	foreach ($Group in $EntraGroups)
	{
		$GroupName=$Group
		$DSGroupName="${GroupName}-ds"
		if ($GroupName -notcontains "-ds" -and $SecurityGroups -contains $DSGroupName)
		{
			Write-Host "$GroupName corresponding $DSGroupName in Active Directory"
			Sync-Groups -SourceGroup $GroupName -DestinationGroup $DSGroupName
		}
	}

	# Go over manually provided group mappings file
	if ($null -ne $GroupMap)
	{
		foreach ($Key in $GroupMap.Keys)
		{
			$GroupName=$Key
			$DSGroupName=$GroupMap[$Key]
			#Don't need to check for existence since this is the manual map
			Sync-Groups -SourceGroup $GroupName -DestinationGroup $DSGroupName
		}
	}
}

if ($null -eq $MappingFile -or $MappingFile -eq "")
{
	write-host "Group mapping file not supplied."
	Update-Groups
} else
{
	Write-Host "Group mapping file supplied: $MappingFile"
	$GroupMap=Read-MapFile -Path $MappingFile
	Update-Groups -GroupMap $GroupMap
}


