use APXController

Select base.JobID
, attr.AttributeName 
, base.JobName
, log.TimeRunStarted
, base.CompletionTime
, DATEDIFF (ss, log.TimeRunStarted, base.CompletionTime) as DurationinSec
, stat.CompletionStatusName
From JobBase base
Join JobRunAttribute jobattr on jobattr.RunInstructionID = base.RunInstructionID
Join JobAttribute attr on attr.AttributeID = jobattr.AttributeID
Join JobLog log on log.JobID = base.JobID
Join JobCompletionStatus stat on stat.CompletionStatusCode = log.CompletionStatusCode
--Where base.JobName = 'RepRun' -- Add or remove this where clause if you want to narrow down to specific types of jobs
Order by base.JobID Desc


--select * from apxcontroller..advprocess where OSProcessId = 58672 -- from the query before
--order by ProcessID desc