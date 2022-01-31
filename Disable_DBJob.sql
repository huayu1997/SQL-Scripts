
USE msdb ;
GO

EXEC dbo.sp_update_job
    @job_name = N'DBA:New ReIndexes',
    --@new_name = N'DBA:New ReIndexes -- Disabled',
    @description = N'DBA:New ReIndexes disabled until further investigation.',
    @enabled = 0 ;
GO

select name, enabled, * from msdb.dbo.sysjobs where name = 'APXController:ArchivingAndPurgingData'