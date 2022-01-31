-------- APX 2.0 & 3.0 -----------
-- Reset admin user password to advs based on local encryption key
----------------------------------
begin tran
declare @NewPassword varchar(100)
set @NewPassword = 'advs'

DECLARE @NewPasswordEncrypted varbinary(260)
EXEC master.dbo.xp_AdvPasswordEncrypt 'Rio.1', @NewPassword, @NewPasswordEncrypted output

select @NewPasswordEncrypted
EXEC pAdvAuditEventadmin
update AoUser set EncryptedPassword = @NewPasswordEncrypted
where userid = -1001
-- do not reset the password for these special system users or you cannot sign on.
commit tran

exec padvauditeventend
