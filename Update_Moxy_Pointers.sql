--update moxysettings
set VarcharValue = Replace (varcharvalue, 'vSacMhApp48-1', 'vSacMhStg48-1') 
where varcharvalue like '%\\vsacmhapp48-1%'
