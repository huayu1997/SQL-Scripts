--find entries in PkgContent that has 'vSacFs18'
select FileLocation  from dbo.PkgContent
where FileLocation like '%vsacfs18%'

--Testing replace function
select REPLACE(filelocation,'vSacFs18','vSacAxStg18-1') from dbo.PkgContent
where FileLocation like '%vsacfs18%'

--Begin Update script to change the setting
BEGIN TRAN

EXEC pAdvAuditEventAdmin
update dbo.pkgContent
set FileLocation = REPLACE(filelocation,'vSacFs18','vSacAxStg18-1') from dbo.PkgContent
where FileLocation like '%vsacfs18%'


EXEC pAdvAuditEventEnd

COMMIT TRAN



--find entries in AdvPortfolioProperty that has 'vSacFs18'
select PropertyValue from AdvPortfolioProperty
where PropertyValue like '%fs18%'

--Testing replace function
select REPLACE(PropertyValue,'vSacFs18','vSacAxStg18-1') from AdvPortfolioProperty
where PropertyValue like '%vsacfs18%'

--Begin Update script to change the setting
BEGIN TRAN

EXEC pAdvAuditEventAdmin
update AdvPortfolioProperty
set PropertyValue = REPLACE(PropertyValue,'vSacFs18','vSacAxStg18-1') from AdvPortfolioProperty
where PropertyValue like '%vsacfs18%'


EXEC pAdvAuditEventEnd

COMMIT TRAN


--find entries in AdvScript that has 'vSacFs18'
select * from AdvScript
where ScriptText like '%fs18%'

--Testing replace function
select REPLACE(scripttext,'vSacFs18','vSacAxStg18-1') from AdvScript
where ScriptText  like '%vsacfs18%'

--Begin Update script to change the setting
BEGIN TRAN

EXEC pAdvAuditEventAdmin
update AdvScript 
set ScriptText = REPLACE(scripttext,'vSacFs18','vSacAxStg18-1') from AdvScript
where ScriptText  like '%vsacfs18%'


EXEC pAdvAuditEventEnd

COMMIT TRAN

--find entries in AdvMacro that has 'vSacFs18'
select * from AdvMacro
where MacroText like '%fs18%'

--Testing replace function
select REPLACE(MacroText ,'vSacFs18','vSacAxStg18-1') from AdvMacro
where MacroText  like '%vsacfs18%'

--Begin Update script to change the setting
BEGIN TRAN

EXEC pAdvAuditEventAdmin
update AdvMacro
set MacroText = REPLACE(MacroText ,'vSacFs18','vSacAxStg18-1') from AdvMacro
where MacroText  like '%vsacfs18%'


EXEC pAdvAuditEventEnd

COMMIT TRAN
