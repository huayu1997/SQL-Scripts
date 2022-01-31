USE [tempdb]
GO

/****** Object:  Table [dbo].[RowsinAdvProcess]    Script Date: 06/04/2014 01:09:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF OBJECT_ID('tempdb..RowsinAdvProcess') is null
CREATE TABLE [dbo].[RowsinAdvProcess](
	id_num int IDENTITY(1,1),
	[Date] [datetime] NOT NULL,
	[NULLrowsinAdvProcess] [int] NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[ProcessDetails]    Script Date: 06/04/2014 01:15:55 ******/

IF OBJECT_ID('tempdb..ProcessDetails') is null
CREATE TABLE [dbo].[ProcessDetails](
	id_num int IDENTITY(1,1),
	[Date] [datetime] NOT NULL,
	[ProcessID] [int] NOT NULL,
	[OSProcessID] [int] NULL,
	[JobName] [nvarchar](72) NULL,
	[TimeRunStarted] [datetime] NULL,
	[ProcessDescription] [nvarchar](72) NOT NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[ShutdownQueues]    Script Date: 06/04/2014 01:24:14 ******/

IF OBJECT_ID('tempdb..ShutdownQueues') is null
CREATE TABLE [dbo].[ShutdownQueues](
	id_num int IDENTITY(1,1),
	[Date] [datetime] NOT NULL,
	[name] [sysname] NOT NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[QueueRowCounts]    Script Date: 06/04/2014 01:28:27 ******/

IF OBJECT_ID('tempdb..QueueRowCounts') is null
CREATE TABLE [dbo].[QueueRowCounts](
	id_num int IDENTITY(1,1),
	[Date] [datetime] NOT NULL,
	[QueueName] [varchar](50) NOT NULL,
	[RowCount] [int] NULL
) ON [PRIMARY]
GO

SET ANSI_PADDING OFF
GO

-- list null rows in AdvProcess...
Insert into  tempdb.[dbo].[RowsinAdvProcess]
select 
	 GETDATE() as [Date]
	,count(*) as NULLrowsinAdvProcess
from APXController.dbo.AdvProcess p
left join APXController.dbo.JobLog jl on jl.JobLogID = p.JobLogID
left join APXController.dbo.JobBase jb on jb.JobID = jl.JobID
where p.ProcessStatusCode in ('R', 'K')	 -- R=Running, K=Cancel Requested
	and ( len(p.ProcessDescription) + len(isnull(jb.JobName, '')) ) = 0
	go

 --list running processes in AdvProcess tha have details
Insert into  tempdb.[dbo].[ProcessDetails]
select 
	 GETDATE() as [Date]
	,p.ProcessID, p.OSProcessID, jb.JobName, jl.TimeRunStarted, p.ProcessDescription
from APXController.dbo.AdvProcess p
left join APXController.dbo.JobLog jl on jl.JobLogID = p.JobLogID
left join APXController.dbo.JobBase jb on jb.JobID = jl.JobID
where p.ProcessStatusCode in ('R', 'K')	 -- R=Running, K=Cancel Requested
	and ( len(p.ProcessDescription) + len(isnull(jb.JobName, '')) ) > 0
go

-- list queues that are shut down
Insert into  tempdb.[dbo].[ShutdownQueues]
select 
	GETDATE() as [Date]
	,name
from APXFirm.sys.service_queues  
where activation_procedure is not null
	and is_activation_enabled = 0
go

-- list row counts in each queue
Insert into  tempdb.[dbo].[QueueRowCounts]
select GETDATE() as [Date], 'QueueName'='qCalcDataRequest', 'RowCount'=count(*) 
--into  tempdb.[dbo].[QueueRowCounts_prep] 
from APXFirm.APX.qCalcDataRequest

Insert into  tempdb.[dbo].[QueueRowCounts]
select GETDATE() as [Date],'qCalcDataRequestInitiator', count(*) from APXFirm.APX.qCalcDataRequestInitiator
Insert into  tempdb.[dbo].[QueueRowCounts]
select GETDATE() as [Date],'qDataCacheTime', count(*) from APXFirm.APX.qDataCacheTime
Insert into  tempdb.[dbo].[QueueRowCounts]
select GETDATE() as [Date],'qFireAndForgetResponse', count(*) from APXFirm.APX.qFireAndForgetResponse
Insert into  tempdb.[dbo].[QueueRowCounts]
select GETDATE() as [Date],'qHoldingHistoryUpdate', count(*) from APXFirm.APX.qHoldingHistoryUpdate
Insert into  tempdb.[dbo].[QueueRowCounts]
select GETDATE() as [Date], 'qMoxyNotifyPublish', count(*) from APXFirm.MxApx.qMoxyNotifyPublish
Insert into  tempdb.[dbo].[QueueRowCounts]
select GETDATE() as [Date], 'qRowChange', count(*) from APXFirm.APX.qRowChange
Insert into  tempdb.[dbo].[QueueRowCounts]
select GETDATE() as [Date], 'qRowChangeCalcData', count(*) from APXFirm.APX.qRowChangeCalcData
Insert into  tempdb.[dbo].[QueueRowCounts]
select GETDATE() as [Date], 'qRowChangePortfolioGroupMembership', count(*) from APXFirm.APX.qRowChangePortfolioGroupMembership




