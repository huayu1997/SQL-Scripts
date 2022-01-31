/*
To determine the person that ran a report, place the report
filename in the @reportfilename variable.
Example: To find the users that ran the standard appraisal,
insert %car.rep% inside the single quotes.
*/ 

declare @reportfilename varchar(15)
set @reportfilename='%%@lg7_AUM_FFT%'

select Login,
  Obj.DisplayName,
  Adv.ComputerName,
  StartTime,
  CompletionTime,
  DATEDIFF (ss, StartTime, CompletionTime) as DurationinSec,
  ProcessDescription,
  adv.processid
from apxcontroller.dbo.advprocess Adv
join apxcontroller.dbo.adveventlog Eve on Adv.processid=Eve.processid
join APXFirm.dbo.AoUser Auser on Eve.UserID=Auser.UserID
join APXFirm.dbo.AoObject Obj on Auser.UserID=Obj.ObjectID
where Adv.componentid=16
and processdescription like @reportfilename
order by Adv.processid desc
