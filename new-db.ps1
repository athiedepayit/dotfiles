param (
	[Parameter(Mandatory)]
	[string[]]$dbs,

	[Parameter(Mandatory)]
	[string]$dbhost,

	[Parameter(Mandatory)]
	[string]$dbuser,

	[Parameter(Mandatory)]
	[string]$dbpass
)

function Create-Subscriber
{
	param (
		[Parameter(Mandatory)]
		[string]$name
	)
	$name_pub="${name}_pub"
	$query="
use [$name]
exec sp_addsubscription @publication = N'$name_pub', @subscriber = N'base-sql-development.d17cfdc1fe68.database.windows.net', @destination_db = N'$name', @subscription_type = N'Push', @sync_type = N'automatic', @article = N'all', @update_mode = N'read only', @subscriber_type = 0
exec sp_addpushsubscription_agent @publication = N'$name_pub', @subscriber = N'base-sql-development.d17cfdc1fe68.database.windows.net', @subscriber_db = N'$name', @job_login = null, @job_password = null, @subscriber_security_mode = 0, @subscriber_login = N'$dbuser', @subscriber_password = N'$dbpass', @frequency_type = 64, @frequency_interval = 0, @frequency_relative_interval = 0, @frequency_recurrence_factor = 0, @frequency_subday = 0, @frequency_subday_interval = 0, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 20241120, @active_end_date = 99991231, @enabled_for_syncmgr = N'False', @dts_package_location = N'Distributor'
GO
"
	Invoke-Sqlcmd -ServerInstance "localhost" -Database master -EncryptConnection -Query "$query" -QueryTimeout 120 -ConnectionTimeout 120

}

function Check-DbExists
{
	param (
		[Parameter(Mandatory)]
		[string]$name
	)
	$query="IF DB_ID('$name') IS NOT NULL print 'true' ELSE print 'false'"
	Invoke-Sqlcmd -ServerInstance $dbhost -Database master -Username $dbuser -Password $dbpass -EncryptConnection -Query "$query" -QueryTimeout 120 -ConnectionTimeout 120
}

function Add-Tables
{
	param (
		[Parameter(Mandatory)]
		[string]$name
	)

	$query="
USE [$name]
GO

/****** Object:  UserDefinedTableType [dbo].[AgentsList]    Script Date: 11/20/2024 2:38:01 PM ******/
CREATE TYPE [dbo].[AgentsList] AS TABLE(
	[AgentId] [int] NOT NULL
)
GO

/****** Object:  UserDefinedTableType [dbo].[AgentUsersList]    Script Date: 11/20/2024 2:38:17 PM ******/
CREATE TYPE [dbo].[AgentUsersList] AS TABLE(
	[UserId] [int] NOT NULL
)
GO

/****** Object:  UserDefinedTableType [dbo].[ProductsList]    Script Date: 11/20/2024 2:38:41 PM ******/
CREATE TYPE [dbo].[ProductsList] AS TABLE(
	[ProductId] [int] NOT NULL
)
GO

/****** Object:  UserDefinedTableType [dbo].[SurveyHarvestReporTableType]    Script Date: 11/20/2024 2:38:51 PM ******/
CREATE TYPE [dbo].[SurveyHarvestReporTableType] AS TABLE(
	[SurveyResponseId] [int] NULL,
	[Age] [varchar](max) NULL,
	[County] [varchar](max) NULL,
	[Harvest Date] [varchar](max) NULL,
	[Sex] [varchar](max) NULL,
	[Zone] [varchar](max) NULL,
	[Weapon Type] [varchar](max) NULL
)
GO

/****** Object:  UserDefinedTableType [dbo].[SurveyResponseAnswerAudit]    Script Date: 11/20/2024 2:39:00 PM ******/
CREATE TYPE [dbo].[SurveyResponseAnswerAudit] AS TABLE(
	[AuditType] [char](1) NOT NULL,
	[SurveyResponseAnswerId] [int] NOT NULL,
	[SurveyResponseId] [int] NOT NULL,
	[QuestionId] [int] NOT NULL,
	[Value] [varchar](max) NOT NULL,
	[PageId] [int] NULL,
	[AnswerOrder] [int] NULL,
	[PageGuid] [uniqueidentifier] NULL,
	[PreviousPageGuid] [uniqueidentifier] NULL
)
GO

/****** Object:  UserDefinedTableType [dbo].[SurveyResponseAnswerSubAnswerAudit]    Script Date: 11/20/2024 2:39:11 PM ******/
CREATE TYPE [dbo].[SurveyResponseAnswerSubAnswerAudit] AS TABLE(
	[AuditType] [char](1) NOT NULL,
	[SurveyResponseAnswerSubAnswerId] [int] NOT NULL,
	[SurveyResponseAnswerId] [int] NULL,
	[SurveyResponseAnswerSubAnswerTypeId] [int] NULL,
	[Value] [nvarchar](max) NULL
)
GO

/****** Object:  UserDefinedTableType [dbo].[SurveyResponseAudit]    Script Date: 11/20/2024 2:47:03 PM ******/
CREATE TYPE [dbo].[SurveyResponseAudit] AS TABLE(
	[AuditType] [char](1) NOT NULL,
	[SurveyResponseId] [int] NOT NULL,
	[CustomerId] [int] NULL,
	[DateCompleted] [datetime] NOT NULL,
	[CompletedByUsername] [varchar](50) NOT NULL,
	[ProductId] [int] NULL,
	[ProductCode] [varchar](8) NULL,
	[IsDeleted] [bit] NOT NULL,
	[TrxDetailId] [int] NULL,
	[IsSkipped] [bit] NOT NULL,
	[Module] [char](4) NULL,
	[Agent] [char](1) NULL,
	[ConfirmationNumber] [varchar](50) NULL,
	[SurveyScheduleId] [int] NULL,
	[DateModified] [datetime] NULL,
	[SurveyType] [char](2) NULL,
	[HipDataSentDate] [datetime] NULL
)
GO

/****** Object:  UserDefinedTableType [dbo].[VehicleAttributeAudit]    Script Date: 11/20/2024 2:47:29 PM ******/
CREATE TYPE [dbo].[VehicleAttributeAudit] AS TABLE(
	[AuditType] [char](1) NOT NULL,
	[VehicleAttributeId] [int] NOT NULL,
	[VehicleId] [int] NOT NULL,
	[VehicleTypeAttributeId] [int] NOT NULL,
	[VehicleAttributeValue] [nvarchar](250) NOT NULL
)
GO

/****** Object:  UserDefinedTableType [dbo].[VehicleAudit]    Script Date: 11/20/2024 2:47:40 PM ******/
CREATE TYPE [dbo].[VehicleAudit] AS TABLE(
	[AuditType] [char](1) NOT NULL,
	[VehicleId] [int] NOT NULL,
	[VehicleTypeId] [int] NOT NULL,
	[DateCreated] [datetime] NOT NULL
)
GO

/****** Object:  UserDefinedTableType [dbo].[VehicleCategoryAudit]    Script Date: 11/20/2024 2:54:54 PM ******/
CREATE TYPE [dbo].[VehicleCategoryAudit] AS TABLE(
	[AuditType] [char](1) NOT NULL,
	[VehicleCategoryId] [int] NOT NULL,
	[VehicleId] [int] NOT NULL,
	[VehicleTypeCategoryId] [int] NOT NULL
)
GO

/****** Object:  UserDefinedTableType [dbo].[VehicleCustomerAudit]    Script Date: 11/20/2024 2:55:03 PM ******/
CREATE TYPE [dbo].[VehicleCustomerAudit] AS TABLE(
	[AuditType] [char](1) NOT NULL,
	[VehicleCustomerId] [int] NOT NULL,
	[VehicleId] [int] NOT NULL,
	[CustomerId] [int] NOT NULL,
	[IsCurrentOwner] [bit] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[UpdatedDate] [datetime] NOT NULL
)
GO

/****** Object:  UserDefinedTableType [dbo].[VehicleCustomerChangeReasonAudit]    Script Date: 11/20/2024 2:55:11 PM ******/
CREATE TYPE [dbo].[VehicleCustomerChangeReasonAudit] AS TABLE(
	[AuditType] [char](1) NOT NULL,
	[VehicleCustomerChangeReasonId] [int] NOT NULL,
	[VehicleCustomerId] [int] NOT NULL,
	[VehicleChangeReasonId] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedByUsername] [varchar](100) NOT NULL
)
GO

/****** Object:  UserDefinedTableType [dbo].[VehicleWorkflowApplicationAudit]    Script Date: 11/20/2024 2:55:23 PM ******/
CREATE TYPE [dbo].[VehicleWorkflowApplicationAudit] AS TABLE(
	[AuditType] [char](1) NOT NULL,
	[WorkflowApplicationId] [int] NOT NULL,
	[TrxDetailId] [int] NOT NULL,
	[CustomerId] [int] NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[ProductId] [int] NOT NULL,
	[SurveyResponseId] [int] NULL,
	[ApplicationType] [varchar](4) NOT NULL
)
GO

/****** Object:  UserDefinedTableType [dbo].[VehicleWorkflowApplicationStatusAudit]    Script Date: 11/20/2024 2:55:31 PM ******/
CREATE TYPE [dbo].[VehicleWorkflowApplicationStatusAudit] AS TABLE(
	[AuditType] [char](1) NOT NULL,
	[WorkflowApplicationStatusId] [int] NOT NULL,
	[WorkflowApplicationId] [int] NOT NULL,
	[ApplicationStatus] [varchar](25) NOT NULL,
	[UpdatedByUserName] [varchar](50) NULL,
	[UpdateNote] [varchar](100) NULL,
	[UpdatedByProcess] [varchar](50) NULL,
	[DateCreated] [datetime] NOT NULL
)
GO
"

	write-host "$name - Making User Defined Tables"
	Invoke-Sqlcmd -ServerInstance $dbhost -Username $dbuser -Password $dbpass -EncryptConnection -Query "$query" -QueryTimeout 120 -ConnectionTimeout 120

}

function New-Database
{

	param (
		[Parameter(Mandatory)]
		[string]$name
	)

	$query="CREATE DATABASE [$name]
 CONTAINMENT = NONE
 WITH LEDGER = OFF
GO
ALTER DATABASE [$name] SET COMPATIBILITY_LEVEL = 150
GO
ALTER DATABASE [$name] SET ANSI_NULL_DEFAULT OFF
GO
ALTER DATABASE [$name] SET ANSI_NULLS OFF
GO
ALTER DATABASE [$name] SET ANSI_PADDING OFF
GO
ALTER DATABASE [$name] SET ANSI_WARNINGS OFF
GO
ALTER DATABASE [$name] SET ARITHABORT OFF
GO
ALTER DATABASE [$name] SET AUTO_SHRINK OFF
GO
ALTER DATABASE [$name] SET AUTO_CREATE_STATISTICS ON(INCREMENTAL = OFF)
GO
ALTER DATABASE [$name] SET AUTO_UPDATE_STATISTICS ON
GO
ALTER DATABASE [$name] SET CURSOR_CLOSE_ON_COMMIT OFF
GO
ALTER DATABASE [$name] SET CURSOR_DEFAULT  GLOBAL
GO
ALTER DATABASE [$name] SET CONCAT_NULL_YIELDS_NULL OFF
GO
ALTER DATABASE [$name] SET NUMERIC_ROUNDABORT OFF
GO
ALTER DATABASE [$name] SET QUOTED_IDENTIFIER OFF
GO
ALTER DATABASE [$name] SET RECURSIVE_TRIGGERS OFF
GO
ALTER DATABASE [$name] SET AUTO_UPDATE_STATISTICS_ASYNC OFF
GO
ALTER DATABASE [$name] SET PARAMETERIZATION SIMPLE
GO
ALTER DATABASE [$name] SET READ_COMMITTED_SNAPSHOT OFF
GO
USE [$name]
GO
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = Off;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = Primary;
GO
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = On;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET PARAMETER_SNIFFING = Primary;
GO
ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = Off;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET QUERY_OPTIMIZER_HOTFIXES = Primary;
GO
USE [$name]
GO
IF NOT EXISTS (SELECT name FROM sys.filegroups WHERE is_default=1 AND name = N'PRIMARY') ALTER DATABASE [$name] MODIFY FILEGROUP [PRIMARY] DEFAULT
GO"

	write-host "$name - Creating DB"
	Invoke-Sqlcmd -ServerInstance $dbhost -Database master -Username $dbuser -Password $dbpass -EncryptConnection -Query "$query" -QueryTimeout 120 -ConnectionTimeout 120
}

foreach ($db in $dbs)
{
	write-host "New DB: $db"

	$existquery="IF DB_ID('$db') IS NOT NULL print 'true' ELSE print 'false'"
	$DbExists=$(Invoke-Sqlcmd -ServerInstance $dbhost -Username $dbuser -Password $dbpass -EncryptConnection -Query "$existquery" -QueryTimeout 120 -ConnectionTimeout 120 -Verbose 4>&1)
	write-host "DbExists: $DbExists"
	if ("$DbExists" -eq "true")
	{
		write-host "DB $db does exist"
	} else
	{
		write-host "DB $db does not exist. Creating"
		New-Database -name $db
		Add-Tables -name $db
	}
}

