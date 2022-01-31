	--sp_help_jobschedule @job_name = 'DBA:New ReIndexes'

	--sp_help_jobschedule @job_name = 'DBA:Defrag Indexes'

	--select name, enabled, * from msdb.dbo.sysjobs where enabled = 1 and name = 'DBA:New ReIndexes'

	SELECT j.name, j.enabled, js.next_run_date, js.next_run_time
	FROM msdb.dbo.[sysjobschedules] js 
	INNER JOIN msdb.dbo.sysjobs j 
		ON [js].[job_id] = [j].[job_id]
	WHERE 
		j.[name] = 'DBA:Defrag Indexes' and j.enabled = 1--or j.name = 'DBA:New ReIndexes'--and j.enabled = 1
		go
		
		
SELECT j.name, j.enabled, js.command, js.output_file_name 
	FROM msdb.dbo.[sysjobsteps] js 
	INNER JOIN msdb.dbo.sysjobs j 
		ON [js].[job_id] = [j].[job_id]
	WHERE 
		j.[name]  like  '%DBA%' 
		go
		

--Change the command file used for a sql job.
--EXEC msdb.dbo.sp_update_jobstep
    @job_name = N'DBA:New ReIndexes',
    @step_id = 1,
    @command=N'powershell.exe d:\dbabin\DBReindex_NoReady_Only.ps1' ;
GO

USE [msdb]
GO
EXEC msdb.dbo.sp_update_jobstep @job_Name=N'DBA:Performance Audit Delete', @step_id=6 , 
		@command=N'--Start LOG Backup Job
Print ''********Start LOG Backup Job********''
print '' ''
print '' ''
EXEC msdb.dbo.sp_start_job ''DBA_BackupDB.LogBackup''
GO
print '' ''
print '' '''
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_update_jobstep @job_Name=N'DBA:Performance Audit Delete', @step_id=6, @step_name=N'Start LOG Backup Job'
GO

USE [msdb]
GO
EXEC msdb.dbo.sp_update_jobstep @job_name=N'DBA:Performance Audit Delete', @step_id=6 , 
		@command=N'--Start FULL Backup Job
Print ''********Start FULL Backup Job********''
print '' ''
print '' ''
EXEC msdb.dbo.sp_start_job ''DBA_BackupDB.FullBackup''
GO
print '' ''
print '' '''
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_update_jobstep @job_name=N'DBA:Performance Audit Delete', @step_id=6, @step_name=N'Start FULL Backup Job'
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_update_jobstep @job_name=N'DBA:Performance Audit Delete', @step_id=8 , 
		@command=N'cmd.exe /c "postie -host:sacmail.prod.dx -to:hyu@Advent.COM -from:%computername%@advent.com -s:"Performance Audit Table Cleanup on %computername%" -nomsg -file:D:\DBABIN\logs\email_PerformanceAuditDelete.txt"'
GO
