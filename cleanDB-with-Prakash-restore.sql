kill 52
go


alter database apxfirm 
set multi_user with rollback immediate
go

select * from sysprocesses
where dbid = DB_ID ('apxfirm')