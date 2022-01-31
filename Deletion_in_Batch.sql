a. --DELETE FROM calc.reconposition 
b. --DELETE FROM calc.reconportfolio 
c. --DELETE FROM calc.reconpositionhistory 


declare @rc bigint=1
while (@rc>0)
begin
delete top(100000) from calc.reconposition 
set @rc=@@ROWCOUNT
waitfor delay '00:00:05'
end