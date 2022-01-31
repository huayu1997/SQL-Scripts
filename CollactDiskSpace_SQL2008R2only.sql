USE [msdb]
GO

/****** Object:  Job [DBA_CollectDBSpace]    Script Date: 8/23/2012 1:50:05 PM ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA_CollectDBSpace')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA_CollectDBSpace', @delete_unused_schedule=1
GO

/****** Object:  Job [DBA_CollectDBSpace]    Script Date: 8/23/2012 1:50:05 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 8/23/2012 1:50:05 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA_CollectDBSpace', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [CollectSpaceStats]    Script Date: 8/23/2012 1:50:05 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'CollectSpaceStats', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE MASTER 
GO 
IF OBJECT_ID(''master..DatabaseSpace'') is null
CREATE TABLE master.[dbo].[DatabaseSpace](
	[DRIVE] [char](1) NULL,
	[DISKSPACEFREE] [decimal](15, 2)  NULL,
	[DATABASENAME] [sysname] NOT NULL,
	[FILENAME] [sysname] NOT NULL,
	[FILETYPE] [nvarchar](60) NULL,
	[FILESIZE] [decimal](15, 2)  NULL,
	[SPACEFREE] [decimal](15, 2) NULL,
	[PHYSICAL_NAME] [nvarchar](260) NOT NULL,
	runtime datetime default getdate()
) ON [PRIMARY]
GO

CREATE TABLE #TMPFIXEDDRIVES ( 
  DRIVE  CHAR(1), 
  MBFREE INT) 

INSERT INTO #TMPFIXEDDRIVES 
EXEC xp_FIXEDDRIVES 

CREATE TABLE #TMPSPACEUSED ( 
  DBNAME    VARCHAR(50), 
  FILENME   VARCHAR(50), 
  SPACEUSED FLOAT) 

INSERT INTO #TMPSPACEUSED 
EXEC( ''sp_msforeachdb''''use ?; Select ''''''''?'''''''' DBName, Name FileNme, fileproperty(Name,''''''''SpaceUsed'''''''') SpaceUsed from sysfiles'''''') 

insert into master.[dbo].[DatabaseSpace]
SELECT   C.DRIVE, 
        CAST(CAST((C.MBFREE) AS DECIMAL(18,2)) AS BIGINT) AS DISKSPACEFREE, 
         A.NAME AS DATABASENAME, 
         B.NAME AS FILENAME, 
         CASE B.TYPE  
           WHEN 0 THEN ''DATA'' 
           ELSE TYPE_DESC 
         END AS FILETYPE, 
		CAST(CAST((B.SIZE * 8 / 1024.0) AS DECIMAL(18,2)) AS BIGINT) AS FILESIZE, 
         CAST((B.SIZE * 8 / 1024.0) - (D.SPACEUSED / 128.0) AS DECIMAL(15,2)) SPACEFREE, 
         B.PHYSICAL_NAME,
		 getdate() 
FROM     SYS.DATABASES A 
         JOIN SYS.MASTER_FILES B 
           ON A.DATABASE_ID = B.DATABASE_ID 
         JOIN #TMPFIXEDDRIVES C 
           ON LEFT(B.PHYSICAL_NAME,1) = C.DRIVE 
         JOIN #TMPSPACEUSED D 
           ON A.NAME = D.DBNAME 
              AND B.NAME = D.FILENME 
ORDER BY DISKSPACEFREE, 
         SPACEFREE DESC 
          
DROP TABLE #TMPFIXEDDRIVES 

DROP TABLE #TMPSPACEUSED', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 1 min', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20120823, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959 
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


