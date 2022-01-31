USE [Abox]

GO

-- Begin spSecListSearch

if exists (select * from sysobjects 
		where id = object_id('spSecListSearch') 
			and sysstat & 0xf = 4)
	drop procedure spSecListSearch
GO

--$Header: /Base/DX/ABOS/AboxConsoleSolution/AboxConsole/SQL/AboxConsole_APXv3Tov4UpgradeScript_Abox.sql 2     3/08/12 12:33p Jworster $

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO

/*
   This stored proc will query the AdvPosition table to get a list of clients that
   hold a particular symbol that is passed as a parameter.
   
   Parameters: Symbol

   Created by: John Vandaveer 10/16/2006

   Sample Usage:
		exec spSecListSearch 'csco', 0
		exec spSecListSearch 'xxx', 1
*/

CREATE proc [dbo].[spSecListSearch]
	@Symbol as varchar(25),
	@EverHeld as bit

as

IF @EverHeld = 0
-- Search seclist2 (currently held) --
	BEGIN
		SELECT distinct o2.[name] AS ownedBy
			,o.name AS port
			,p.securityID
			,p.SecTypeCode as sectypebasecode
			,principalcurrencycode
			,symbol
			,cusip
			,fullname
			,'' as InBlotter
			,case 
				when l.[Value] is NULL then ''
				else l.[Value]
			end as AwsLabel,
			'' as InCustodialPositions
		FROM
		APXFirm..AdvPosition p 
		JOIN APXFirm.AdvApp.vSecurity s
		ON p.SecurityID = s.SecurityID
		JOIN APXFirm..AoObject o
		ON o.objectid = p.portfolioid
		LEFT JOIN APXFirm.AdvApp.vPortfolioBaseCustomLabels l
		ON l.PortfolioBaseID = p.portfolioid
		AND l.Label = '$aws'
		JOIN APXFirm..AoObject o2
		ON o.ownedby = o2.objectid
		WHERE s.symbol = @symbol

		UNION

		SELECT o2.[name] as ownedBy
			,'In ' + c.ClassDisplayName as port
			,s.securityID
			,s.SecTypeBaseCode
			,s.PrincipalCurrencyCode
			,s.symbol
			,s.cusip
			,s.fullname
			,o.[name] as InBlotter
			,'' as AwsLabel
			,'' as InCustodialPositions
		FROM APXFirm.AdvApp.vSecurity s
		JOIN APXFirm..AdvTradeBlotterLine b 
		ON (b.SecurityID1 = s.SecurityID or b.SecurityID2 = s.SecurityID)
		JOIN APXFirm..AoObject o 
		ON o.objectID = b.blotterID
		JOIN APXFirm..AoObject o2
		ON o.ownedby = o2.objectid
		JOIN APXFirm..AoClass c 
		ON c.classID = o.classID
		WHERE symbol = @symbol
		AND (o.classid = 105 or o.classid=222)
		
		UNION
		
		SELECT distinct o2.[name] AS ownedBy
			,o.name AS port
			,r.securityID
			,r.SecTypeCode as sectypebasecode
			,principalcurrencycode
			,symbol
			,cusip
			,fullname
			,'' as InBlotter
			,'' as AwsLabel
			,'Yes' as InCustodialPositions
		FROM APXFirm..AdvPositionRecon r 
		JOIN APXFirm.AdvApp.vSecurity s
		ON r.SecurityID = s.SecurityID
		JOIN APXFirm..AoObject o
		ON o.objectid = r.portfolioid
		JOIN APXFirm..AoObject o2
		ON o.ownedby = o2.objectid
		WHERE s.symbol = @symbol

	END
ELSE
-- Search seclist (ever held) --
	BEGIN
		SELECT distinct o2.name AS ownedBy
			,o.name AS port
			,p.securityID1 as securityID
			,SecTypeCode1 as sectypebasecode
			,principalcurrencycode
			,symbol
			,cusip
			,fullname
			,'' as InBlotter
			,case 
				when l.[Value] is NULL then ''
				else l.[Value]
			end as AwsLabel
			,'' as InCustodialPositions
		FROM APXFirm.Advapp.vPortfolioTransaction p 
		JOIN APXFirm.AdvApp.vSecurity s
		ON p.SecurityID1 = s.SecurityID
		JOIN APXFirm..AoObject o
		ON o.objectid = p.portfolioid
		LEFT JOIN APXFirm.AdvApp.vPortfolioBaseCustomLabels l
		ON l.PortfolioBaseID = p.portfolioid
		AND l.Label = '$aws'
		JOIN APXFirm..AoObject o2
		ON o.ownedby = o2.objectid
		WHERE s.symbol = @symbol

		UNION

		SELECT o2.name as ownedBy
			,'In ' + c.ClassDisplayName as port
			,s.securityID
			,s.SecTypeBaseCode
			,s.PrincipalCurrencyCode
			,s.symbol
			,s.cusip
			,s.fullname
			,o.name as InBlotter
			,'' as AwsLabel
			,'' as InCustodialPositions
		FROM ApxFirm.AdvApp.vSecurity s
		JOIN ApxFirm..AdvTradeBlotterLine b 
		ON (b.SecurityID1 = s.SecurityID or b.SecurityID2 = s.SecurityID)
		JOIN ApxFirm..AoObject o 
		ON o.objectID = b.blotterID
		JOIN APXFirm..AoObject o2
		ON o.ownedby = o2.objectid
		JOIN ApxFirm..AoClass c 
		ON c.classID = o.classID
		WHERE symbol = @symbol
		AND (o.classid = 105 or o.classid=222)
		
		UNION
		
		SELECT distinct o2.[name] AS ownedBy
			,o.name AS port
			,r.securityID
			,r.SecTypeCode as sectypebasecode
			,principalcurrencycode
			,symbol
			,cusip
			,fullname
			,'' as InBlotter
			,'' as AwsLabel
			,'Yes' as InCustodialPositions
		FROM APXFirm..AdvPositionRecon r 
		JOIN APXFirm.AdvApp.vSecurity s
		ON r.SecurityID = s.SecurityID
		JOIN APXFirm..AoObject o
		ON o.objectid = r.portfolioid
		JOIN APXFirm..AoObject o2
		ON o.ownedby = o2.objectid
		WHERE s.symbol = @symbol

	END

GO

-- End spSecListSearch