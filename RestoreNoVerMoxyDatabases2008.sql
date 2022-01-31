/*
This query will restore Moxy database. 
*/
DECLARE @filename VARCHAR(200)
DECLARE @dbname VARCHAR(200)
DECLARE @dbdata VARCHAR(200)
DECLARE @dblog VARCHAR(200)
DECLARE @backupdir VARCHAR(500)
DECLARE @archivedata VARCHAR(500)
DECLARE @archivelog VARCHAR(500)
DECLARE @restoredata VARCHAR(500)
DECLARE @restorelog VARCHAR(500)
DECLARE @datato VARCHAR(max)
DECLARE @logto VARCHAR(max)
DECLARE @MoxyBAKPath VARCHAR(max)
DECLARE @MoxyDB VARCHAR(max)
DECLARE @DropRTM VARCHAR(1)

SET @backupdir = 'C:\Backup\' --Set the backup directory here
SET @MoxyBAKPath = @backupdir + 'Moxy60.BAK' -- Moxy Database Backup File Path
SET @datato = 'C:\Data\' -- Where the main Moxy DB mdf and ndf files should be restored
SET @logto = @datato --Where the ldf files should go. Default is same as mdf/ndf location
SET @archivedata = @datato --Set the archive restore path here
SET @archivelog = @logto --Set the archive log restore path. Default is main Moxy DB log location
SET @DropRTM = 'y' --If set to 'y' then restore will drop RTM tables


USE master
DECLARE @datasys VARCHAR(max)
DECLARE @datadata VARCHAR(max)
DECLARE @dataix VARCHAR(max)
DECLARE @datalog VARCHAR(max)
DECLARE @logsys VARCHAR(max)
DECLARE @logdata VARCHAR(max)
DECLARE @logix VARCHAR(max)
DECLARE @loglog VARCHAR(max)
DECLARE @tsql VARCHAR(max)
DECLARE @tsql2 VARCHAR(max)
DECLARE @backup_filelistm TABLE (
	LogicalName NVARCHAR(128)
	,PhysicalName NVARCHAR(260)
	,Type CHAR(1)
	,FileGroupName NVARCHAR(128)
	,Size NUMERIC(20, 0)
	,MaxSize NUMERIC(20, 0)
	,FileId BIGINT
	,CreateLSN NUMERIC(25, 0)
	,DropLSN NUMERIC(25, 0) NULL
	,UniqueId UNIQUEIDENTIFIER
	,readonlyLSN NUMERIC(25, 0) NULL
	,readwriteLSN NUMERIC(25, 0) NULL
	,BackupSizeInBytes BIGINT
	,SourceBlockSize INT
	,FileGroupId INT
	,LogGroupGuid UNIQUEIDENTIFIER NULL
	,DifferentialBaseLsn NUMERIC(25, 0) NULL
	,DifferentialBaseGuid UNIQUEIDENTIFIER
	,IsReadOnly BIT
	,IsPresent BIT
	,TDEThumbprint VARBINARY(32)
	)
DECLARE @cmdstr VARCHAR(255)

SELECT @cmdstr = 'restore filelistonly from disk=' + '''' + @MoxyBAKPath + ''''

INSERT INTO @backup_filelistm
EXEC (@cmdstr)

SET @datasys = @datato + 'MoxySys.mdf'
SET @datadata = @datato + 'MoxyData.ndf'
SET @dataIx = @datato + 'MoxyIx.ndf'
SET @datalog = @logto + 'MoxyLog.ldf'
SET @logsys = (
		SELECT logicalname
		FROM @backup_filelistm
		WHERE logicalname LIKE '%Sys'
		)
SET @logdata = (
		SELECT logicalname
		FROM @backup_filelistm
		WHERE logicalname LIKE '%data'
		)
SET @logix = (
		SELECT logicalname
		FROM @backup_filelistm
		WHERE logicalname LIKE '%ix'
		)
SET @loglog = (
		SELECT logicalname
		FROM @backup_filelistm
		WHERE logicalname LIKE '%log'
		)
SET @MoxyDB = 'Moxy'
SET @tsql = 'RESTORE DATABASE Moxy FROM DISK = ''' + @MoxyBAKPath + '''
WITH MOVE ''' + @logsys + ''' TO ''' + @datasys + ''',
MOVE ''' + @logdata + ''' TO ''' + @datadata + ''',
MOVE ''' + @logix + ''' TO ''' + @dataix + ''',
MOVE ''' + @loglog + ''' TO ''' + @datalog + ''',
STATS = 1,
REPLACE'
SET @tsql2 = 'ALTER DATABASE ' + @moxydb + ' MODIFY FILE (NAME=' + '''' + @logsys + '''' + ',NEWNAME=' + '''' + 'MoxySys' + '''' + ') ' + 'ALTER DATABASE ' + @moxydb + ' MODIFY FILE (NAME=' + '''' + @logdata + '''' + ',NEWNAME=' + '''' + 'MoxyData' + '''' + ') ' + 'ALTER DATABASE ' + @moxydb + ' MODIFY FILE (NAME=' + '''' + @logIx + '''' + ',NEWNAME=' + '''' + 'MoxyIx' + '''' + ') ' + 'ALTER DATABASE ' + @moxydb + ' MODIFY FILE (NAME=' + '''' + @logLog + '''' + ',NEWNAME=' + '''' + 'MoxyLog' + '''' + ') '

EXEC (@tsql)

EXEC (@tsql2)

IF @DropRTM = 'y'
BEGIN
	SET @tsql2 = ' 
drop table ' + @Moxydb + '.dbo.mxsrvcsqueue
drop table ' + @Moxydb + '.dbo.mxsrvcsqueuetype
drop table ' + @Moxydb + '.dbo.mxsrvcsfixconnection
drop table ' + @Moxydb + '.dbo.mxsrvcsServicedatabase
drop table ' + @Moxydb + '.dbo.mxsrvcsService
drop table ' + @Moxydb + '.dbo.mxsrvcsServicetype
drop table ' + @Moxydb + '.dbo.mxsrvcsdatabase'

	EXEC (@tsql2)
END

DECLARE @files TABLE (
	fname VARCHAR(200)
	,depth INT
	,file_ INT
	)

INSERT @files
EXECUTE master.dbo.xp_dirtree @backupdir
	,1
	,1

DECLARE files CURSOR LOCAL
FOR
SELECT fname
FROM @files
WHERE fname LIKE '%Moxy__[_]%.bak'

OPEN files

FETCH NEXT
FROM files
INTO @filename

WHILE (@@FETCH_STATUS = 0)
BEGIN
	SET @dbname = 'Moxy' + SUBSTRING(REPLACE(@filename, '.bak', ''), 7, 50)
	SET @restoredata = @archivedata + '\Moxy' + SUBSTRING(@dbname, 5, 50) + '_Data.MDF'
	SET @restorelog = @archivelog + '\Moxy' + SUBSTRING(@dbname, 5, 50) + '_Log.LDF'
	SET @MoxyBAKPath = @backupdir + '\' + @filename

	DECLARE @backup_filelista TABLE (
		LogicalName NVARCHAR(128)
		,PhysicalName NVARCHAR(260)
		,Type CHAR(1)
		,FileGroupName NVARCHAR(128)
		,Size NUMERIC(20, 0)
		,MaxSize NUMERIC(20, 0)
		,FileId BIGINT
		,CreateLSN NUMERIC(25, 0)
		,DropLSN NUMERIC(25, 0) NULL
		,UniqueId UNIQUEIDENTIFIER
		,readonlyLSN NUMERIC(25, 0) NULL
		,readwriteLSN NUMERIC(25, 0) NULL
		,BackupSizeInBytes BIGINT
		,SourceBlockSize INT
		,FileGroupId INT
		,LogGroupGuid UNIQUEIDENTIFIER NULL
		,DifferentialBaseLsn NUMERIC(25, 0) NULL
		,DifferentialBaseGuid UNIQUEIDENTIFIER
		,IsReadOnly BIT
		,IsPresent BIT
		,TDEThumbprint VARBINARY(32)
		)

	SELECT @cmdstr = 'restore filelistonly from disk=' + '''' + @MoxyBAKPath + ''''

	INSERT INTO @backup_filelista
	EXEC (@cmdstr)

	SET @dbdata = (
			SELECT LogicalName
			FROM @backup_filelista
			WHERE LogicalName LIKE '%Data'
			)
	SET @dblog = (
			SELECT LogicalName
			FROM @backup_filelista
			WHERE LogicalName LIKE '%Log'
			)

	PRINT @dbname

	RESTORE DATABASE @dbname
	FROM DISK = @MoxyBAKPath
	WITH MOVE @dbdata TO @restoredata
		,MOVE @dblog TO @restorelog
		,REPLACE
		,STATS = 10

	SET @tsql = 'ALTER DATABASE ' + @dbname + ' MODIFY FILE (NAME=' + '''' + @dbdata + '''' + ',NEWNAME=' + '''' + 'Moxy' + SUBSTRING(@dbname, 7, 50) + '_Data' + '''' + ') ' + 'ALTER DATABASE ' + @dbname + ' MODIFY FILE (NAME=' + '''' + @dblog + '''' + ',NEWNAME=' + '''' + 'Moxy' + SUBSTRING(@dbname, 7, 50) + '_Log' + '''' + ')'

	EXEC (@tsql)

	DELETE
	FROM @backup_filelista

	FETCH NEXT
	FROM files
	INTO @filename
END
