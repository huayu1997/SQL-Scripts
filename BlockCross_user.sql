
/****** Object:  Login [BlockCross]    Script Date: 03/02/2018 17:31:54 ******/
CREATE LOGIN [BlockCross] WITH PASSWORD=N'xxx', DEFAULT_DATABASE=[Moxy], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO



USE [Moxy]
GO

/****** Object:  User [BlockCross]    Script Date: 03/02/2018 17:37:42 ******/
GO

CREATE USER [BlockCross] FOR LOGIN [BlockCross] WITH DEFAULT_SCHEMA=[dbo]
GO



use [Moxy]
GO
GRANT EXECUTE ON [MxBc].[BCGetOrders] TO [BlockCross]
GO
