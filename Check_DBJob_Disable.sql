
-- Jobs that have been recently disabled
select
  [name], [enabled], [date_created], [date_modified]
from sysjobs
where [date_modified] > '2013-09-30' and enabled = 0
order by [date_modified] desc
go


-- Schedules that have been recently disabled
select
  [name], [enabled], [date_created], [date_modified]
from sysschedules
where [date_modified] > '2013-09-30' and enabled = 0
order by [date_modified] desc