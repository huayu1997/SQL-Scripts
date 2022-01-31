/*DTCC Archiving Script

Before you beging update the tradedate depending on the history business days setting of DTCC

1. First query returns unreconciled/pending confirm transactions and exclude them.
2. 2nd query returns unreconciled/pending in srmatch that are in srconfirmmatch and exclude them
3. Last checks/delets the srconfirmtransactions for records not in srconfirmmatch this is to archive records in
srconfirmdata. 
*/


DECLARE @tradedate datetime
set @tradedate='2013-2-28' -- Set the date going back from today based on the business history days setting.


/*Run this to check if there are any records on srconfirmtransaction that are not reconciled*/
select ConfirmTransactionID,reconcode,TradeDate 
from srconfirmtransaction 
where reconcode not in ('y','x')
and tradedate < @tradedate 

/*Run the below script to update the unreconciled/pending confirm transactions to be excluded*/

/*
update srconfirmtransaction
set reconcode='x'
where reconcode not in ('y','x')
and tradedate < @tradedate 
*/


/*Find records in srmatch that are in srconfirmmatch and srconfirmtransaction*/

select srmatchid,ReconCode from srmatch
where SRMatchID in
(select SRMatchID from SRConfirmMatch where tradematchid in (
select tradematchid from srconfirmtransaction
where reconcode not in ('y','x')
and tradedate < @tradedate))

/*
update srmatch
set reconcode='x'
where srmatchid in
(select srmatchid from srconfirmmatch
where tradematchid in
(select tradematchid from srconfirmtransaction
where tradedate < @tradedate) and reconcode not in ('y','x'))
*/

/*Look for records SrConfirmTransaction that's not in srconfirmmatch*/

select DtcControlNumber,TradeDate 
from SRConfirmTransaction
where TradeMatchID not in 
(select TradeMatchID from SRConfirmMatch)
and TradeDate < @tradedate

/*delete records in SRConfirmTransaction to archive srconfirmdata */

/*
delete from SRConfirmTransaction
where TradeMatchID not in 
(select TradeMatchID from SRConfirmMatch)
and TradeDate < @tradedate
*/

