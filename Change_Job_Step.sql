USE [msdb]
GO

DECLARE @step nvarchar(50)
SET @step = 
	(
	SELECT j.[job_id] 
	FROM msdb.dbo.sysjobs j
	INNER JOIN msdb.dbo.[sysjobschedules] js 
		ON [js].[job_id] = [j].[job_id]
	WHERE 
		j.[name] = 'DBA:Performance Audit Delete'
	);
	
EXEC msdb.dbo.sp_update_jobstep @job_id=@step, @step_id=7 , 
		@flags=16
GO
