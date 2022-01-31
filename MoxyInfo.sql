SELECT Setting
	,VarcharValue
FROM moxysettings
WHERE Setting IN (
		'FullName'
		,'Schema Build Number'
		,'DBLocation'
		,'AXMLSchemaDoc'
		)

EXEC pmxpatchgetcomponents

DECLARE @moxydb TABLE (
	DatabaseName VARCHAR(21)
	,[Size(MB)] INT
	)

INSERT INTO @moxydb
SELECT convert(VARCHAR(21), d.NAME)
	,convert(FLOAT, size) * .008
FROM sys.master_files f
JOIN sys.databases d ON d.database_id = f.database_id
WHERE f.type = 0

SELECT DatabaseName AS 'Database Name'
	,SUM([Size(MB)]) AS 'Data Size(MB)'
FROM @moxydb
WHERE DatabaseName LIKE 'Moxy%'
	AND DatabaseName NOT LIKE '%TempDb'
GROUP BY DatabaseName

UNION

SELECT 'Total'
	,sum([Size(MB)]) AS 'Total Size(MB)'
FROM @moxydb
WHERE DatabaseName LIKE 'Moxy%'
	AND DatabaseName NOT LIKE '%TempDb'
ORDER BY DatabaseName

IF EXISTS (
		SELECT 1
		FROM sys.schemas
		WHERE NAME = 'xr'
		)
BEGIN
	SELECT TOP 1 'Moxy Rules Manager is version ' + productversion AS 'Rules Version'
	FROM xr.productversion
	ORDER BY completedinstall DESC
END
ELSE
BEGIN
	SELECT 'Moxy Rules Manager is not installed' AS 'Rules Version'
END
