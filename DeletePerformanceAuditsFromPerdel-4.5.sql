-- Edit the following line for the desired cutoff date -- 4.0 VERSION
declare @cutoff datetime
set @cutoff = '2017-06-12'	-- time portion is irrelevant, if entered it will be stripped off

-- DO NOT EDIT BELOW THIS LINE
set nocount on

-- make sure cutoff date doesn't have a time portion
set @cutoff = DATEADD(dd, DATEDIFF(dd,0,@cutoff), 0)
print 'Deleting performance audit data deleted by Rep before ' + convert(varchar(20), @cutoff)
print ''

-- get the max audit event ids for this date range
declare @maxAuditEventID int

select @maxAuditEventID = MAX(AuditEventID)
from dbo.AdvAuditEvent
where AuditEventTime < @cutoff
	and	FunctionID = 4 /* Rep */
	
-- Get rid of rows caused by deleting performance with perdel.rep

declare @startCount int
declare @count int
declare @deletedCount int
declare @ID1 int, @ID2 int

/*
APX.Performance_Audit
APX.PerformanceSecurity_Audit

a) Rows may be here because Rep put them there.  In this case, the audit in/out codes are I/D and both in/out function ids are 4.
b) Rep put the rows in (as in (a)) but then the user editted the row manually. In this case, there will be I/U and U/D rows.
c) Rep didn't write the rows, they were entered manually.  In this case, there is an I/D but only the D function id is 4.

Delete (a) and (c) - that is, all rows that have I/D and the out function id is 4.
*/

select @startCount=count(*) from APX.Performance_Audit
print convert(varchar, getdate(), 121) + ': Cleaning APX.Performance_Audit, starting with ' + convert(varchar(10), @startCount) + ' rows'
set @ID2 = 0
set @deletedCount = 0
while (1=1)
begin
	select @ID1= min(PerformanceID), @ID2=max(PerformanceID)
	from (
		select top 100000 p.PerformanceID
		from APX.Performance_Audit p
		where PerformanceID > @ID2
		order by PerformanceID
	) Q

	if (@ID1 is null) break;
	 
	delete tbl
	from APX.Performance_Audit tbl
	join dbo.AdvAuditEvent evOut on tbl.AuditEventIDOut = evOut.AuditEventID
	where
		tbl.PerformanceID between @ID1 and @ID2 and
		tbl.AuditTypeCodeIn = 'I' and
		tbl.AuditTypeCodeOut = 'D' and
		tbl.AuditEventIDOut <= @maxAuditEventID and
		evOut.FunctionID = 4

	set @count = @@rowcount
	print convert(varchar, getdate(), 121) +  ':     deleted ' + convert(varchar(10), @count) + ' rows'
	set @deletedCount = @deletedCount + @count
end
print convert(varchar, getdate(), 121) + ': Deleted a total of ' + convert(varchar(10), @deletedCount) + ' rows from APX.Performance_Audit, leaving ' + convert(varchar(10), @startCount-@deletedCount) + ' rows (' + convert(varchar(10), convert(decimal(10,2), case when @startCount > 0 then @deletedCount * 100.0 / @startCount else 0 end)) + '% deleted)'

print ''

select @startCount=count(*) from APX.PerformanceSecurity_Audit
print convert(varchar, getdate(), 121) + ': Cleaning APX.PerformanceSecurity_Audit, starting with ' + convert(varchar(10), @startCount) + ' rows'
set @ID2 = 0
set @deletedCount = 0
while (1=1)
begin
	select @ID1= min(PerformanceSecurityID), @ID2=max(PerformanceSecurityID)
	from (
		select top 100000 p.PerformanceSecurityID 
		from APX.PerformanceSecurity_Audit p
		where PerformanceSecurityID  > @ID2
		order by PerformanceSecurityID 
	) Q

	if (@ID1 is null) break;
	 
	delete tbl
	from APX.PerformanceSecurity_Audit tbl
	join dbo.AdvAuditEvent evOut on tbl.AuditEventIDOut = evOut.AuditEventID
	where
		tbl.PerformanceSecurityID between @ID1 and @ID2 and
		tbl.AuditTypeCodeIn = 'I' and
		tbl.AuditTypeCodeOut = 'D' and
		tbl.AuditEventIDOut <= @maxAuditEventID and
		evOut.FunctionID = 4

	set @count = @@rowcount
	print convert(varchar, getdate(), 121) +  ':     deleted ' + convert(varchar(10), @count) + ' rows'
	set @deletedCount = @deletedCount + @count
end
print convert(varchar, getdate(), 121) + ': Deleted a total of ' + convert(varchar(10), @deletedCount) + ' rows from APX.PerformanceSecurity_Audit, leaving ' + convert(varchar(10), @startCount-@deletedCount) + ' rows (' + convert(varchar(10), convert(decimal(10,2), case when @startCount > 0 then  @deletedCount * 100.0 / @startCount else 0 end)) + '% deleted)'
go