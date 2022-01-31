//All the SQL Server examples in this post only use the DATEADD and DATEDIFF functions to calculate our desired date. //	 //Each example will do this by calculating date intervals from the current date, //and then adding or subtracting intervals to arrive at the desired calculated date. //	 //The technique shown here for calculating a date interval between the current date //and the year "1900-01-01," and then adding the calculated number of interval to "1900-01-01," //to calculate a specific date, can be used to calculate many different dates. The next four examples //use this same technique to generate different dates based on the current date.

--First and Last Day of Previous Month
02.
select
03.
DATEADD(mm, DATEDIFF(mm,0,getdate())-1, 0) as FirstDayPrevMo
04.
,DATEADD(mm, DATEDIFF(mm,0,getdate()), 0)-1 as LastDayPrevMo
05.
 
06.
--First Day of Month
07.
select DATEADD(mm, DATEDIFF(mm,0,getdate()), 0) as FirstDayCurrMo
08.
 
09.
--Monday of the Current Week with Sunday as first day of week
10.
select DATEADD(wk, DATEDIFF(wk,0,getdate()), 0)
11.
 
12.
--Monday of the Current Week with Monday as first day of week
13.
set DATEFIRST 1
14.
select DATEADD(dd, 1 - DATEPART(dw, getdate()), getdate())
15.
 
16.
--First Day of the Year
17.
select DATEADD(yy, DATEDIFF(yy,0,getdate()), 0)
18.
 
19.
--Last Day of Prior Year
20.
select dateadd(ms,-3,DATEADD(yy, DATEDIFF(yy,0,getdate()  ), 0))
21.
 
22.
--Last Day of Current Year
23.
select dateadd(ms,-3,DATEADD(yy, DATEDIFF(yy,0,getdate()  )+1, 0))
24.
 
25.
--First Monday of the Month
26.
select DATEADD(wk, DATEDIFF(wk,0,dateadd(dd,6-datepart(day,getdate()),getdate())), 0)     
27.
 
28.
 
29.
--Last Day of Current Month
30.
select dateadd(ms,-3,DATEADD(mm, DATEDIFF(m,0,getdate()  )+1, 0))
31.
 
32.
--First Day of the Current Quarter
33.
select DATEADD(qq, DATEDIFF(qq,0,getdate()), 0)
34.
 
35.
--Midnight for the Current Day
36.
select DATEADD(dd, DATEDIFF(dd,0,getdate()), 0)
37.
 
38.
--Last Day of Prior Month (3 Milisecond Method
39.
select dateadd(ms,-3,DATEADD(mm, DATEDIFF(mm,0,getdate()  ), 0))