USE [APXController]
GO
CREATE USER [AMDAUTO] FOR LOGIN [AMDAUTO]
GO
USE [APXController]
GO
ALTER ROLE [db_owner] ADD MEMBER [AMDAUTO]
GO
USE [APXFirm]
GO
CREATE USER [AMDAUTO] FOR LOGIN [AMDAUTO]
GO
USE [APXFirm]
GO
ALTER ROLE [db_owner] ADD MEMBER [AMDAUTO]
GO
USE [APXFirm_Temp]
GO
CREATE USER [AMDAUTO] FOR LOGIN [AMDAUTO]
GO
USE [APXFirm_Temp]
GO
ALTER ROLE [db_owner] ADD MEMBER [AMDAUTO]
GO
