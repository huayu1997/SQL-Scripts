declare @NewPassword varchar(100) 
set @NewPassword = 'advs' 
DECLARE @NewPasswordEncrypted varbinary(260) 
EXEC master.dbo.xp_AdvPasswordEncrypt 'Rio.1', @NewPassword, @NewPasswordEncrypted output 
select @NewPasswordEncrypted 
begin transaction
EXEC pAdvAuditEventBegin @userID = -1001, @functionID=24 -- Manual change
update AOUser set EncryptedPassword = @NewPasswordEncrypted where userid not in (-1005,-41,-24)
EXEC pAdvAuditEventEnd
-- rollback tran
commit transaction 