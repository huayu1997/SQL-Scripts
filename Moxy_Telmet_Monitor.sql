	 
if object_id('tempdb..tmpMxSecPrice') is not null drop table tempdb..tmpMxSecPrice
GO

select *
into tempdb..tmpMxSecPrice
from moxy.MxSec.Price where datepart(hh, pricedate) <> '00'
GO

--select * from tempdb..tmpMxSecPrice
--order by PriceDate desc


DECLARE @LastPriceDate Datetime
SELECT @LastPriceDate=max(PriceDate) from tempdb..tmpMxSecPrice

IF (DATEDIFF(minute, @LastPriceDate, getdate()) > 5)
      SELECT 'Status'='STATUS==ERROR', 'Message'='Last price update was ' + CAST(@LastPriceDate as char)
ELSE
      SELECT 'Status'='STATUS==NO_ERROR'
	 


