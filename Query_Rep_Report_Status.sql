declare @date varchar (50)
set  @date = convert(DATE, GETDATE(), 120)
print @date


Use APXController

select starttime, completiontime,  DATEDIFF (ss, StartTime, CompletionTime) as DurationinSec, computerName, processdescription, OSProcessID, ProcessId,ProcessStatusCode 
from advprocess
where componentID = 16 and StartTime > @date
-- processdescription like '%packager%'
order by ProcessStatusCode desc

--select * from advcomponent /*Component ID Info */

SELECT LEFT(CONVERT(CHAR, StartTime, 120), 10) as ReportDate, DurationinSec, ProcessDescription
into AdvsDiag.dbo.Hua_test_1
from AdvsDiag.dbo.Hua_test
where ProcessStatusCode != 'NULL'
   
select ReportDate, COUNT(*) 
from AdvsDiag.dbo.Hua_test_1
group by ReportDate

select * from apxcontroller..advprocess where OSProcessId = 58672 -- from query return above
-- order by ProcessID desc