use APXFIrm
select (REPLACE(PropertyValue, 'vsacmhapp35-2', 'vSacMhDev1083-1'))  from AdvPortfolioProperty
where PropertyValue like '%vsacmhapp35-2%'

Use APXFirm
begin tran
exec pAdvAuditEventAdmin
update AdvPortfolioProperty
SET PropertyValue = REPLACE(PropertyValue, 'vsacmhapp35-2', 'vSacMhDev1083-1')
where PropertyValue like '%vsacmhapp35-2%'
exec pAdvAuditEventEnd
commit tran