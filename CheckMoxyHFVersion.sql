use Moxy
go

select * from MoxyInstallLog
where itemname like ('%HF%')
order by InstalledDate desc 