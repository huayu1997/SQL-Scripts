USE [msdb]
GO

DECLARE @sch INT
SET @sch = 
	(
	SELECT [schedule_id] 
	FROM msdb.dbo.[sysjobschedules] js 
	INNER JOIN msdb.dbo.sysjobs j 
		ON [js].[job_id] = [j].[job_id]
	WHERE 
		j.[name] = 'DBA:New ReIndexes'
	);

		EXEC msdb.dbo.sp_update_schedule @schedule_id=@sch, 
		@freq_type=8, 
		@freq_interval=64, 
		@freq_recurrence_factor=1, 
		@active_start_time=190000
GO


USE [msdb]
GO
EXEC msdb.dbo.sp_update_jobstep @job_id=N'2e0f2670-48e7-458b-9871-e064da7449cb', @step_id=7 , 
		@flags=16
GO
