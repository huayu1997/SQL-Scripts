USE [tempdb]
GO

/****** Object:  Table [dbo].[TestHua]    Script Date: 06/11/2013 15:08:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF OBJECT_ID('tempdb..TestHua') is null
CREATE TABLE tempdb.[dbo].[TestHua](
	id_num int IDENTITY(1,1),
	[Date] [datetime] NOT NULL,
	[SESSION ID] [smallint] NOT NULL,
	[DATABASE Name] [nvarchar](128) NULL,
	[System Name] [nvarchar](128) NULL,
	[Program Name] [nvarchar](128) NULL,
	[USER Name] [nvarchar](128) NOT NULL,
	[status] [nvarchar](30) NOT NULL,
	[CPU TIME (in milisec)] [int] NOT NULL,
	[Total Scheduled TIME (in milisec)] [int] NOT NULL,
	[Elapsed TIME (in milisec)] [int] NOT NULL,
	[Memory USAGE (in KB)] [int] NULL,
	[SPACE Allocated FOR USER Objects (in KB)] [bigint] NULL,
	[SPACE Deallocated FOR USER Objects (in KB)] [bigint] NULL,
	[SPACE Allocated FOR Internal Objects (in KB)] [bigint] NULL,
	[SPACE Deallocated FOR Internal Objects (in KB)] [bigint] NULL,
	[SESSION Type] [varchar](14) NULL,
	[ROW COUNT] [bigint] NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


Insert into  tempdb.[dbo].[TestHua]
SELECT
	GETDATE() as [Date],
  sys.dm_exec_sessions.session_id AS [SESSION ID]
  ,DB_NAME(database_id) AS [DATABASE Name]
  ,HOST_NAME AS [System Name]
  ,program_name AS [Program Name]
  ,login_name AS [USER Name]
  ,status
  ,cpu_time AS [CPU TIME (in milisec)]
  ,total_scheduled_time AS [Total Scheduled TIME (in milisec)]
  ,total_elapsed_time AS    [Elapsed TIME (in milisec)]
  ,(memory_usage * 8)      AS [Memory USAGE (in KB)]
  ,(user_objects_alloc_page_count * 8) AS [SPACE Allocated FOR USER Objects (in KB)]
  ,(user_objects_dealloc_page_count * 8) AS [SPACE Deallocated FOR USER Objects (in KB)]
  ,(internal_objects_alloc_page_count * 8) AS [SPACE Allocated FOR Internal Objects (in KB)]
  ,(internal_objects_dealloc_page_count * 8) AS [SPACE Deallocated FOR Internal Objects (in KB)]
  ,CASE is_user_process
             WHEN 1      THEN 'user session'
             WHEN 0      THEN 'system session'
  END         AS [SESSION Type], row_count AS [ROW COUNT]
FROM 
  sys.dm_db_session_space_usage
INNER join
  sys.dm_exec_sessions
ON  sys.dm_db_session_space_usage.session_id = sys.dm_exec_sessions.session_id
--order by [SPACE Deallocated FOR USER Objects (in KB)] --4.16425 GB
--order by [SPACE Deallocated FOR Internal Objects (in KB)] --1.25952 GB 
--order by [SPACE Allocated FOR USER Objects (in KB)] --4.16425 GB
order by [SPACE Allocated FOR Internal Objects (in KB)] --0.28693 GB
desc
