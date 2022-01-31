declare @date varchar (50)
set  @date = convert(DATE, GETDATE()-1, 120)
print @date

SELECT [rs].[destination_database_name], 
[rs].[restore_date], 
[bs].[backup_start_date], 
[bs].[backup_finish_date], 
[bs].[database_name] as [source_database_name], 
REPLACE([bmf].[physical_device_name], '\\sacbak05\SQLBackup\vSacAxDb18-1\', '') as [backup_file_used_for_restore]
FROM msdb..restorehistory rs
INNER JOIN msdb..backupset bs
ON [rs].[backup_set_id] = [bs].[backup_set_id]
INNER JOIN msdb..backupmediafamily bmf 
ON [bs].[media_set_id] = [bmf].[media_set_id] 
where Convert(DATE, [rs].[restore_date], 120) = @date
ORDER BY [rs].[restore_date] DESC