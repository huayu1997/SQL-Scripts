USE master;  
GO  
ALTER DATABASE FIXNET SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
ALTER DATABASE FIXNET MODIFY NAME = FIXNET_081320191831 ;
GO  
ALTER DATABASE FIXNET_081320191831 SET MULTI_USER
GO

ALTER DATABASE FIXNET_081320191831 SET SINGLE_USER WITH ROLLBACK IMMEDIATE
go

ALTER DATABASE FIXNET_081320191831 SET OFFLINE
go

ALTER DATABASE FIXNET_081320191831 MODIFY FILE (Name='FIXNET', FILENAME='E:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\\FIXNET_081320191831_FIXNET_Data_Data_1.mdf')
GO

ALTER DATABASE FIXNET_081320191831 MODIFY FILE (Name='FIXNET_log', FILENAME='E:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\\FIXNET_FIXNET_log_Log_2.ldf')
GO

ALTER DATABASE FIXNET_081320191831 SET ONLINE
Go
ALTER DATABASE FIXNET_081320191831 SET MULTI_USER
Go