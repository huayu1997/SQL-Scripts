USE APXFirm

GO

DECLARE @DBName VARCHAR(100) = N'APXFIrm', @objName VARCHAR(100)=N'[dbo].[pAxPriceHistoryPutBulk]', @handle VARBINARY(64)

--Assign Plan_handle to variable @handle
SELECT @handle = Plan_handle FROM sys.dm_exec_procedure_stats ps WHERE ps.database_id = DB_ID(@DBName) and object_id = OBJECT_ID(@objName)

--EXTRACT the Execution Plan
--SELECT * FROM sys.dm_exec_query_plan(@handle)

select @handle
--DBCC FREEPROCCACHE @handle