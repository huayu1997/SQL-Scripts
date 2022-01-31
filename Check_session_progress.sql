--get session id (actvie-only)
sp who2 --active (session-only)

--put session id here to get percentage in progression
select percent_complete from sys.dm_exec_requests where session_id=113