
If(db_id(N'AdvsDiag') IS NULL)
    BEGIN
        CREATE DATABASE [AdvsDiag]
    END;

/****** Object:  Job [_DBA_APX_UserSessions]    Script Date: 7/21/2019 2:40:54 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Data Collector]    Script Date: 7/21/2019 2:40:54 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Data Collector' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Data Collector'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'_DBA_APX_UserSessions', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'Data Collector', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Collect APX User Session Information]    Script Date: 7/21/2019 2:40:54 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Collect APX User Session Information', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=1, 
		@retry_interval=5, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'/***** object:	Table [dbo].[RowsinAdvPorcess]  ****/
	set ansi_nulls on
	go

	set quoted_IDENTIFIER ON
	GO
	SET ANSI_PADDING ON
	GO


	IF OBJECT_ID(''AdvsDiag..APX_UserSessions'') is NULL

	Create TABLE AdvsDiag.[dbo].[APX_UserSessions] (
			id_num int IDENTITY(1,1)
			, [date]  [datetime] NOT NULL
			, [SessionID]	int NOT NULL
			, [CREATED]	[datetime] NOT NULL
			, [LastTouched]	[datetime] NOT NULL
			, [InstanceCount]	[int] NOT NULL
			, [LicensePoolID] [int] NOT NULL
			, [UserID]	[int] NOT NULL
			, [IPAddress]	[varchar](56) NOT NULL
			, [Name]	[nvarchar](32) NOT NULL
			, [FullName]	[nvarchar](100) NOT NULL	
	) ON [PRIMARY]
	GO

	IF OBJECT_ID(''AdvsDiag.dbo.APX_TotalSessions'') is NULL

	Create TABLE AdvsDiag.[dbo].[APX_TotalSessions] (
			id_num int IDENTITY(1,1)
			, [date]  [datetime] NOT NULL
			, [TotalCount]	[int] NOT NULL
	) ON [PRIMARY]
	GO

--- List Rows in AdvProcess  ----
Insert into AdvsDiag.[dbo].[APX_UserSessions]
select GETDATE() as [Data]
		,[SessionID]
      ,[Created]
      ,[LastTouched]
      ,[InstanceCount]
      ,[LicensePoolID]
      ,[UserID]
      ,[IPAddress]
      ,[Name]
      ,[FullName]
 FROM [APXFirm].[AdvApp].[vUserSession]

 --- List Total Rows in AdvProcess  ----
Insert into AdvsDiag.[dbo].[APX_TotalSessions]
select GETDATE() as [Data]
		, COUNT (*)
from APXFirm.AdvApp.vUserSession
GO', 
		@database_name=N'AdvsDiag', 
		@output_file_name=N'D:\dbabin\logs\_DBA_APXUserSessions.out', 
		@flags=2
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every Hour Daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20171128, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'5f1cb73d-9924-4328-93ac-37b4d1ab95ac'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


