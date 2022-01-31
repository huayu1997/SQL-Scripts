
USE [master]
GO
CREATE LOGIN [KnowItAll] WITH PASSWORD=N'p)rC)zZJf7I9', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=ON
GO

USE [Abox]
GO
CREATE USER [KnowItAll] FOR LOGIN [KnowItAll]
GO
USE [Abox]
GO
EXEC sp_addrolemember N'db_datareader', N'KnowItAll'
GO

USE [ABOXGICS]
GO
CREATE USER [KnowItAll] FOR LOGIN [KnowItAll]
GO
USE [ABOXGICS]
GO
EXEC sp_addrolemember N'db_datareader', N'KnowItAll'
GO

USE [AboxHFRX]
GO
CREATE USER [KnowItAll] FOR LOGIN [KnowItAll]
GO
USE [AboxHFRX]
GO
EXEC sp_addrolemember N'db_datareader', N'KnowItAll'
GO

USE [AODDivAcc]
GO
CREATE USER [KnowItAll] FOR LOGIN [KnowItAll]
GO
USE [AODDivAcc]
GO
EXEC sp_addrolemember N'db_datareader', N'KnowItAll'
GO

USE [ABOXMorningstar]
GO
CREATE USER [KnowItAll] FOR LOGIN [KnowItAll]
GO
USE [ABOXMorningstar]
GO
EXEC sp_addrolemember N'db_datareader', N'KnowItAll'
GO

USE [Moxy]
GO
CREATE USER [KnowItAll] FOR LOGIN [KnowItAll]
GO
USE [Moxy]
GO
EXEC sp_addrolemember N'db_datareader', N'KnowItAll'
GO
USE [rcData]
GO
CREATE USER [KnowItAll] FOR LOGIN [KnowItAll]
GO
USE [rcData]
GO
EXEC sp_addrolemember N'db_datareader', N'KnowItAll'
GO
USE [FixNet]
GO
CREATE USER [KnowItAll] FOR LOGIN [KnowItAll]
GO
USE [FixNet]
GO
EXEC sp_addrolemember N'db_datareader', N'KnowItAll'
Go
USE [APXFirm]
GO
CREATE USER [KnowItAll] FOR LOGIN [KnowItAll]
GO
USE [APXFirm]
GO
EXEC sp_addrolemember N'db_datareader', N'KnowItAll'
GO
USE [DTCC]
GO
CREATE USER [KnowItAll] FOR LOGIN [KnowItAll]
GO
USE [DTCC]
GO
EXEC sp_addrolemember N'db_datareader', N'KnowItAll'
GO
USE [GLX]
GO
CREATE USER [KnowItAll] FOR LOGIN [KnowItAll]
GO
USE [GLX]
GO
EXEC sp_addrolemember N'db_datareader', N'KnowItAll'
GO