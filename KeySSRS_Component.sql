use APXController

select * from CtrlServerProxyUser cspu
join CtrlProxyUserType cput on cspu.ProxyUserTypeID = cput.ProxyUserTypeID

select * from apxfirm.dbo.AoProperty
where PropertyName = 'SSRS Server URL'


