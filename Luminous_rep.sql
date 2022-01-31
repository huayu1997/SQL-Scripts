if object_id('tempdb..##RepTime') is not null drop table tempdb..##RepTime
GO


Declare @Date datetime = getDate()
Declare @DayDate date = getDate()


select  
	convert(varchar,dateadd(DAY,0, datediff(day,0, starttime)),110)'Date' 
	,StartTime, CompletionTime, DATEDIFF(SECOND,starttime,completiontime) as 'Duration_InSeconds'
	, ProcessDescription,ProcessStatusCode
into ##RepTime
from APXController..AdvProcess
where componentID = 16 --and StartTime > @DayDate --and CompletionTime is NULL
--and ProcessDescription like '%Run Report:  persave.rep, @az, 12302000 03312014%'
--and ProcessDescription like '%perdel.rep'


go	



select * from tempdb..##RepTime
where DATE > GETDATE()-1
order by Duration_InSeconds desc
go