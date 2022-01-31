declare @DBname varchar (50)
declare @servername varchar (50)
declare @date varchar (50)
declare @time1 varchar (max)
declare @time varchar (max)
declare @disk varchar (max)
declare @filename varchar (50)

-- ONLY need to set the Database name  to @DBname
set @DBname = 'Your DB Name Here'

-- No need to enter anything from here on
set @servername = @@SERVERNAME 
set @filename = @DBname + '-' + 'Full Database Backup'

-- Getting Date in YYYY_MM_DD format
select @date = (SELECT REPLACE(CONVERT(DATE, GETDATE(), 120), '-', '_'))

-- Getting Time stamp and get rid of :, change . to _
select @time1 = (SELECT REPLACE(LTRIM(RIGHT(CONVERT(TIME, GETDATE()), 16)), ':', '')) 
select @time = (SELECT REPLACE(@time1, '.', '_'))

-- Combine backupdir and backup file name
set @disk = '\\SACBAK05\SQLBackup\' + @servername + '\' + @DBname + '_backup_' + @date + '_' + @time + '.bak'

BACKUP DATABASE @DBname TO  DISK = @disk  WITH NOFORMAT, NOINIT,  NAME = @filename, SKIP, NOREWIND, NOUNLOAD,  STATS = 10
