/***** object:	Table [dbo].[RowsinAdvPorcess]  ****/
	set ansi_nulls on
	go

	set quoted_IDENTIFIER ON
	GO
	SET ANSI_PADDING ON
	GO

	use AdvsDiag
	GO

	IF OBJECT_ID('AdvsDiag..UserSessions') is NULL

	Create TABLE [dbo].[UserSessions] (
			id_num int IDENTITY(1,1)
			, [date]  [datetime] NOT NULL
			, [SessionID]	int NOT NULL
			, [CREATED]	[datetime] NOT NULL
			, [LastTouched]	[datetime] NOT NULL
			, [InstanceCount]	[int] NOT NULL
			, [LicensePoolID] [int] NOT NULL
			, [UserID]	[int] NOT NULL
			, [IPAddress]	[varchar](56) NOT NULL
			, [Name]	[nvarchar](32) NOT NULL
			, [FullName]	[nvarchar](100) NOT NULL	
	) ON [PRIMARY]
	GO

	IF OBJECT_ID('AdvsDiag.dbo.TotalSessions') = NULL

	Create TABLE [dbo].[TotalSessions] (
			id_num int IDENTITY(1,1)
			, [date]  [datetime] NOT NULL
			, [TotalCount]	[int] NOT NULL
	) ON [PRIMARY]
	GO

--- List Rows in AdvProcess  ----
Insert into AdvsDiag.[dbo].[UserSessions]
select GETDATE() as [Data]
		,[SessionID]
      ,[Created]
      ,[LastTouched]
      ,[InstanceCount]
      ,[LicensePoolID]
      ,[UserID]
      ,[IPAddress]
      ,[Name]
      ,[FullName]
 FROM [APXFirm].[AdvApp].[vUserSession]

 --- List Total Rows in AdvProcess  ----
Insert into AdvsDiag.[dbo].[TotalSessions]
select GETDATE() as [Data]
		, COUNT (*)
from APXFirm.AdvApp.vUserSession
GO