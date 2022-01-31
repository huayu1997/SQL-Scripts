-- list null rows in AdvProcess...I have no idea what these are, but there are a lot of them!
select count(*) as NULLrowsinAdvProcess
from APXController.dbo.AdvProcess p
left join APXController.dbo.JobLog jl on jl.JobLogID = p.JobLogID
left join APXController.dbo.JobBase jb on jb.JobID = jl.JobID
where p.ProcessStatusCode in ('R', 'K')	 -- R=Running, K=Cancel Requested
	and ( len(p.ProcessDescription) + len(isnull(jb.JobName, '')) ) = 0
	go


 --list running processes in AdvProcess tha have details
select p.ProcessID, p.OSProcessID, jb.JobName, jl.TimeRunStarted, p.ProcessDescription
from APXController.dbo.AdvProcess p
left join APXController.dbo.JobLog jl on jl.JobLogID = p.JobLogID
left join APXController.dbo.JobBase jb on jb.JobID = jl.JobID
where p.ProcessStatusCode in ('R', 'K')	 -- R=Running, K=Cancel Requested
	and ( len(p.ProcessDescription) + len(isnull(jb.JobName, '')) ) > 0
go

-- list queues that are shut down
select name
from APXFirm.sys.service_queues  
where activation_procedure is not null
	and is_activation_enabled = 0
go



select 'QueueName'='qCalcDataRequest', 'RowCount'=count(*) from APXFirm.APX.qCalcDataRequest
union all
select 'qCalcDataRequestInitiator', count(*) from APXFirm.APX.qCalcDataRequestInitiator
union all
select 'qDataCacheTime', count(*) from APXFirm.APX.qDataCacheTime
union all
select 'qFireAndForgetResponse', count(*) from APXFirm.APX.qFireAndForgetResponse
union all
select 'qHoldingHistoryUpdate', count(*) from APXFirm.APX.qHoldingHistoryUpdate
union all
select 'qMoxyNotifyPublish', count(*) from APXFirm.MxApx.qMoxyNotifyPublish
union all
select 'qRowChange', count(*) from APXFirm.APX.qRowChange
union all
select 'qRowChangeCalcData', count(*) from APXFirm.APX.qRowChangeCalcData
union all
select 'qRowChangePortfolioGroupMembership', count(*) from APXFirm.APX.qRowChangePortfolioGroupMembership