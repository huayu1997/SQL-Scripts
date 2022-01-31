Declare @ActiveProcess table (

session_id int NOT NULL,

kpid int null,

cmd varchar(2000) null,

open_tran tinyint,

lastwaittype varchar(2000) null,

waitresource varchar(2000) null,

blocked int,

sql_handle varbinary (4000) null,

stmt_start int,

stmt_end int,

waittime int,

physical_io bigint,

memusage int

) 

insert into @ActiveProcess

select 

distinct spid,kpid,cmd,open_tran,lastwaittype,waitresource,blocked,[sql_handle],stmt_start,stmt_end,waittime,physical_io,memusage

from sys.sysprocesses b with (nolock)

where (open_tran>0 

or blocked >0) and spid <> @@spid

or spid in (select blocked from sys.sysprocesses b with (nolock) where blocked >0)

-- select * from @ActiveProcess

select 

s.session_id as SessionID, 

p.kpid as Kpid,

blocked as BlockingSession,

SUBSTRING(qt.text, (p.stmt_start/2)+1, 

((CASE p.stmt_end

WHEN -1 THEN DATALENGTH(qt.text)

WHEN 0 THEN DATALENGTH(qt.text)

ELSE p.stmt_end

END - p.stmt_start)/2) + 1) AS QueryExecuted,

datediff(ss, COALESCE(t.transaction_begin_time,s.last_request_end_time,r.start_time), getdate()) as SessionIdleSec,

s.host_name as HostName,

convert(varchar(2000),s.program_name) as ProgramName, 

s.login_name as LoginName,

convert(varchar(2000),s.status) as SessionStatus, 

convert(varchar(2000),p.cmd) as Command,

convert(varchar(2000),coalesce(r.last_wait_type,p.lastwaittype)) as WaitType, 

convert(varchar(2000),coalesce(r.wait_resource, p.waitresource)) as WaitResource, 

p.waittime/1000 as WaitTimeSec, 

convert(int, p.open_tran) as OpenTransactionCount,

t.transaction_begin_time as TransactionBeginTime,

case

when t.transaction_type <> 4 

then 

case t.transaction_state 

when 0 then 'Invalid' 

when 1 then 'Initialized' 

when 2 then 'Active' 

when 3 then 'Ended' 

when 4 then 'Commit Started' 

when 5 then 'Prepared' 

when 6 then 'Committed' 

when 7 then 'Rolling Back' 

when 8 then 'Rolled Back' 

end 

when t.transaction_type <> 4 

then 

case t.dtc_state 

when 1 then 'Active' 

when 2 then 'Prepared' 

when 3 then 'Committed' 

when 4 then 'Aborted' 

when 5 then 'Recovered' 

end 

else 

'Not Active' 

end as TransactionStatus,

CASE 

WHEN coalesce(r.transaction_isolation_level, s.transaction_isolation_level) = 0 THEN 'Unspecified' 

WHEN coalesce(r.transaction_isolation_level, s.transaction_isolation_level) = 1 THEN 'ReadUncommitted' 

WHEN coalesce(r.transaction_isolation_level, s.transaction_isolation_level) = 2 THEN 'ReadCommitted' 

WHEN coalesce(r.transaction_isolation_level, s.transaction_isolation_level) = 3 THEN 'Repeatable' 

WHEN coalesce(r.transaction_isolation_level, s.transaction_isolation_level) = 4 THEN 'Serializable' 

WHEN coalesce(r.transaction_isolation_level, s.transaction_isolation_level) = 5 THEN 'Snapshot' 

END AS TransactionIsolationLevel,

case st.is_user_transaction 

when 0 then 'User Transaction' 

when 1 then 'System Transaction' 

end as IsUserTransaction,

case t.transaction_type

when 1 then 'Read/write transaction' 

when 2 then 'Read-only transaction' 

when 3 then 'System transaction' 

when 4 then 'Distributed transaction' 

end as TransactionType,

coalesce(r.transaction_id, st.transaction_id) as TransactionId, 

case t.transaction_state

when 0 then 'The transaction has not been completely initialized yet' 

when 1 then 'The transaction has been initialized but has not started' 

when 2 then 'The transaction is active' 

when 3 then 'The transaction has ended. This is used for read-only transactions' 

when 4 then 'The commit process has been initiated on the distributed transaction' 

when 5 then 'The transaction is in a prepared state and waiting resolution' 

when 6 then 'The transaction has been committed' 

when 7 then 'The transaction is being rolled back' 

when 8 then 'The transaction has been rolled back' 

end as TransactionState,

st.enlist_count as EnlistCount, 

r.percent_complete as PercentComplete,

r.estimated_completion_time as EstimatedCompletionTime,

r.cpu_time/1000 as CpuConsumedSec,

r.total_elapsed_time/1000 as TimeConsumedSec,

coalesce((r.reads+r.writes),p.physical_io) as PhysicalIO,

coalesce(granted_query_memory,p.memusage) as MemUsage,

s.last_request_start_time as LastRequestStartTime,

s.last_request_end_time as LastRequestEndTime

from @ActiveProcess p

left join sys.dm_exec_sessions s with (nolock) on s.session_id = p.session_id

left join sys.dm_exec_requests r with (nolock) on s.session_id = r.session_id

left join sys.dm_tran_session_transactions st with (nolock) on s.session_id = st.session_id

left join sys.dm_tran_active_transactions t with (nolock)on t.transaction_id = st.transaction_id

outer apply sys.dm_exec_sql_text(p.sql_handle) as qt
 