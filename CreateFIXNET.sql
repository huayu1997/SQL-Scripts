DECLARE @path varchar(500)
DECLARE @tsql varchar(max)
 
SET @path = 'E:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA'
--Set the path of the FIXNET data files 
 
SET @TSQL = 'CREATE DATABASE FIXNET
ON 
 ( NAME = FIXNET_Data,
FILENAME = '''+@path+'\FIXNET_Data.mdf'',
SIZE = 50,
FILEGROWTH = 10% )
LOG ON
( NAME = FIXNET_Log,
FILENAME = '''+@path+'\FIXNET_Log.ldf'',
SIZE = 50,
FILEGROWTH = 10% )'
EXEC (@TSQL);
GO 
