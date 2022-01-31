select * from sys.dm_broker_activated_tasks

Use APXFirm

select count ( * ) from apx.qrowchangecalcdata

select * from apxfirm_temp.temp.sqlrepoutput  --- queued output/previous jobs/reports

--exec APXSys.pServiceBrokerConversationMaint @cleanup = 1, @doAll=1 
--delete from apxfirm_temp.temp.sqlrepoutput

select * from apxfirm.apx.debugmessage