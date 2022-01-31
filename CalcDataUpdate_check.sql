--Check CalcDataUpdate related report runs
use APXController

select
	StartTime
	, CompletionTime
	, ProcessDescription
from AdvProcess
where ComponentID = 16
and ProcessDescription like '%\[mode\], \_%' ESCAPE '\'
--and StartTime between '2020-05-26' and '2020-05-27'
order by StartTime desc

--Check when the settings of CalcDataUpdate was changed
use APXFirm

select *
from calc.Schedule s
join AdvAuditEvent a on a.AuditEventID = s.AuditEventID
where s.RecalcMode <> 'N'
order by AuditEventTime desc