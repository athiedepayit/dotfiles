#Requires –Modules ActiveDirectory
<#
Version 1.0
#>
param(
	[string]$MappingFile
)

$SecurityGroupOU="AADDC Users"
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
	foreach ($SrcUser in $SourceUsers)
	{
		$SrcUserName=$SrcUser.Name
		$SrcUserAccount=$SrcUser.SamAccountName
		if ($DestUsers -contains $SrcUser)
		{
			Write-Host " - $SrcUserName alread in $DestinationGroup"
		} else
		{

			Write-Host " - Adding $SrcUserName to $DestinationGroup"
			# TODO: Remove -whatif
			Add-ADGroupMember -Identity $DestinationGroup -Members $SrcUserAccount -Whatif

		}
	}
	# no need to re-evaluate destusers, just need to remove ones that aren't in sourceusers
	foreach ($DestUser in $DestUsers)
	{
		$DestUserName=$DestUser.Name
		$DestUserAccount=$DestUser.SamAccountName
		if ($SourceUsers -notcontains $DestUser)
		{
			Write-Host " - Removing $DestUserName from $DestinationGroup"
			# TODO: Remove -whatif
			Remove-ADGroupMember -Identity $DestinationGroup -Members $DestUserAccount -Whatif
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

	$GroupMaps=@{}

	if (!Test-Path $Path -PathType Leaf)
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
