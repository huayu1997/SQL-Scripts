/*
APXInfo.sql, Created by Remote Upgrade Services.
Run against APX db.
*/

/*
This section will display the versions of APX installed and when they were installed.
As well it will show if add on products, like Rex, are installed.
*/

SELECT CONVERT(VARCHAR(30), m.ModuleDescription) AS 'Product'
	,CONVERT(VARCHAR(15), m.ModuleVersion) AS 'Version'
	,CONVERT(VARCHAR, min(a.AuditEventTime), 101) AS 'Installed on'
FROM dbo.AoModule_Audit m
JOIN dbo.AdvAuditEvent a ON m.AuditEventIDIn = a.auditeventid
WHERE m.installed = 1
GROUP BY m.ModuleDescription
	,m.ModuleVersion
ORDER BY m.ModuleDescription, m.ModuleVersion DESC

/*
This section will show if exchange sync is installed
*/

IF EXISTS (select ExchangeWebServicesURL from APX.SyncConfig)
BEGIN
SELECT 'Yes' AS 'Exchange Sync Installed'
END
ELSE
BEGIN
SELECT 'No' AS 'Exchange Sync Installed'
END


/*
This section will show the size of all APX databases, including log files
*/

DECLARE @apxdb TABLE (
	dbname SYSNAME
	,db_size NVARCHAR(13)
	,OWNER SYSNAME
	,dbid SMALLINT
	,created NVARCHAR(11)
	,STATUS NVARCHAR(600) NULL
	,compatibility_level TINYINT
	)

INSERT INTO @apxdb
EXEC sp_helpdb

SELECT dbname AS 'Database Name (Including Logs)'
	,db_size AS 'Total Size'
FROM @apxdb
WHERE dbname IN (
		'AOController'
		,'AOController_Archive'
		,'AOFirm'
		,'AOFirm_Archive'
		,'APXController'
		,'APXController_Archive'
		,'APXFirm'
		,'APXFirm_Archive'
		,'MDM'
		,'APXFirm_Doc'
		)
ORDER BY 'Total Size' DESC

/*
This section will show the size of the 10 largest tables and the Percent of the Database they make up.
*/

IF EXISTS (
		SELECT 1
		FROM APX.TableStats
		WHERE DATE BETWEEN getdate() - 7
				AND GETDATE()
		)
BEGIN
	SELECT TOP (10) CONVERT(VARCHAR, DATE, 101) AS DATE
		,NAME
		,Rows
		,ReservedMB AS 'Size MB'
		,PctMB AS 'PctOfDB'
	FROM APX.TableStats
	WHERE DATE IN (
			SELECT max(DATE)
			FROM APX.TableStats
			)
	ORDER BY PctMB DESC
END
ELSE
BEGIN
	EXEC APX.pTableSizes

	SELECT TOP (10) CONVERT(VARCHAR, DATE, 101) AS DATE
		,NAME
		,Rows
		,ReservedMB AS 'Size MB'
		,PctMB AS 'PctOfDB'
	FROM APX.TableStats
	WHERE DATE IN (
			SELECT max(DATE)
			FROM APX.TableStats
			)
	ORDER BY PctMB DESC
END

/*
This section will show if any of the indexes need to be rebuilt prior to the upgrade.
If you return results please run the RebuildAPXIndexes.sql script.
*/


SELECT schema_name(obj.schema_id) + '.' + obj.NAME AS 'Table'
	,ind.NAME AS 'Index'
	,avg_fragmentation_in_percent
	,fragment_count
FROM sys.dm_db_index_physical_stats(db_id(), DEFAULT, DEFAULT, DEFAULT, 'SAMPLED') f
JOIN sys.objects obj ON obj.object_id = f.object_id
JOIN sys.indexes ind ON ind.object_id = f.object_id
	AND ind.index_id = f.index_id
WHERE obj.type = 'U'
	AND alloc_unit_type_desc != 'LOB_DATA' -- skip overflow pages for ntext, nvarchar(max), etc.
	AND index_level = 0 -- only consider leaf level
	AND page_count > 32 -- Footnote [1].
	AND ind.fill_factor > 0 -- ignore dumb heaps
	AND fragment_count > 1 -- leave alone if only one fragment
	AND (
		--	rebuild if fill is less than 90% each page having room for 1 row
		avg_page_space_used_in_percent < 0.90 * (1.0 - avg_record_size_in_bytes / 8060.0)
		OR avg_fragmentation_in_percent >= 10
		)
	AND f.index_id != 255 -- skip text data

/*
This section will return all APX labels that reference a path.
*/
	
	
SELECT CASE 
		WHEN AoClass.ClassName = 'Firmwide'
			THEN 'User'
		WHEN AoClass.ClassName = 'Netwide'
			THEN 'Global Settings'
		ELSE AoClass.ClassName
		END AS 'Type'
	,vQbRowDefPortfolioBaseLabel.PortfolioBaseCode
	,vQbRowDefPortfolioBaseLabel.PropertyName
	,vQbRowDefPortfolioBaseLabel.PropertyDesc
	,vQbRowDefPortfolioBaseLabel.PropertyValue
FROM AoClass
INNER JOIN AoObject ON AoClass.ClassID = AoObject.ClassID
INNER JOIN vQbRowDefPortfolioBaseLabel ON AoObject.ObjectID = vQbRowDefPortfolioBaseLabel.PortfolioBaseID
WHERE vQbRowDefPortfolioBaseLabel.PropertyValue LIKE '\\%\%'
	OR vQbRowDefPortfolioBaseLabel.PropertyValue LIKE '_:\%\%'
ORDER BY Type

/*
This section will return all Packager and Print Merge Content that reference a path other than Default.
*/

SELECT ContentName AS 'Packager/PrintMerge Content'
	,ContentCategory
	,FileLocation
FROM APXFirm.dbo.PkgContent
WHERE FileLocation LIKE '\\%\%'
	OR FileLocation LIKE '_:\%\%'
	
/*
This section will return all scripts that reference a path.
*/
	
SELECT AoObject.NAME
	,AdvScript.ScriptText
FROM AdvScript
INNER JOIN AoObject ON AdvScript.ScriptID = AoObject.ObjectID
WHERE AdvScript.ScriptText LIKE '%\\%\%'
	OR AdvScript.ScriptText LIKE '%:\%\%'

/*
This section is based on the new Security Type Definition validation
performed in APX 4.0 and above. This information can be found on page 88 of the
Installing and Maintaining Guide. Fixed Income Security types should have the
following settings:
-“Can Mature” = Yes
-“Can Be Bought/Sold” = Yes
-“Income Type” = Interest
-“Fixed Income Type” = any fixed income type other than None
*/
SELECT variant.SecTypeCode 'Security Type Variant'
	,type.SecTypeBaseCode 'Security Type Base'
	,CASE 
		WHEN type.IncomeTypeCode = 'd'
			THEN 'Dividend'
		WHEN type.IncomeTypeCode = 'i'
			THEN 'Interest'
		ELSE 'None'
		END 'Income Type'
	,fixed.FixedIncomeTypeName 'Fixed Income Type'
	,CASE 
		WHEN type.CanBeBoughtSold = 1
			THEN 'Yes'
		ELSE 'No'
		END 'Can Be Bought\Sold'
	,CASE 
		WHEN type.CanMature = 1
			THEN 'Yes'
		ELSE 'No'
		END 'Can Mature'
	,CASE 
		WHEN fixed.FixedIncomeTypeName = 'none'
			AND type.canmature = 1
			AND type.CanBeBoughtSold = 1
			AND type.IncomeTypeCode = 'i'
			THEN 'Review. Change the Fixed Income Type to a value other than "none". Upgrade will change Fixed Income Type to "Bond".'
		WHEN fixed.FixedIncomeTypeName <> 'none'
			AND (
				type.IncomeTypeCode <> 'i'
				OR type.canmature = 0
				OR type.CanBeBoughtSold = 0
				)
			THEN 'Review CanMature, CanBeBoughtSold and IncomeType fields. Upgrade will change Fixed Income Type to "none".'
		ELSE 'No Known Upgrade Changes'
		END 'Resolution Suggestion'
FROM AdvSecTypeBase type
JOIN AdvFixedIncomeType fixed ON fixed.FixedIncomeTypeCode = type.FixedIncomeTypeCode
JOIN AdvSecTypeVariant variant ON type.SecTypeBaseCode = variant.SecTypeBaseCode
WHERE (
		(
			fixed.FixedIncomeTypeName = 'none'
			AND type.canmature = 1
			AND type.CanBeBoughtSold = 1
			AND type.IncomeTypeCode = 'i'
			)
		OR (
			fixed.FixedIncomeTypeName <> 'none'
			AND (
				type.IncomeTypeCode <> 'i'
				OR type.canmature = 0
				OR type.CanBeBoughtSold = 0
				)
			)
		)

