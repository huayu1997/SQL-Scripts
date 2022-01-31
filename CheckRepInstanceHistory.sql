Use APXController

--select starttime, completiontime,  DATEDIFF (ss, StartTime, CompletionTime) as DurationinSec, processdescription, ComputerName, OSProcessID, ProcessId,ProcessStatusCode, *
select *
from adveventlog
where ComputerName = 'vSacAxWkr8-1' and eventtime > '2015-08-12' and ComponentID = 2
order by EventTime desc