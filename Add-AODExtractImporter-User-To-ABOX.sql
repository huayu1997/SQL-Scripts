/*

Author		: Patrick Nackord
Name		: Add-AODExtractImporter-User-To-ABOX.sql
Date		: January 22, 2011
Version		: 1.0.0.1
Dependacies	: AODExtractImport.exe v1.0 
			: APX 3.0
Description	: Create the Extract Importer login and user for the ABOX and ApxFirm DB. Script also sets up permissions
Notes		: ****** SET THE @Domain and @User variables *********    

*/
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
--This script is reserved for APX 3.0 Databases or Above. 
--If you try to execute the script in 2.0, it will raise a critical error 
--    and disconnect so none of the procedures are updated.
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
DECLARE @Product varchar(72)
DECLARE @Version varchar(72)
SET @Product = 'APX'
SELECT @Version = (SELECT MAX (ModuleVersion) FROM APXFirm..AoModule WHERE [ModuleName] = @Product)
IF LEFT(@Version, 2) = '2.'
BEGIN
      -- This will raise a Critical Error that will disconnect the database so no
      -- further statements will be executed. 
      RaisError('This script for for APX 3.0 and Above, this appears to be a 2.0 Database', 20, -1) WITH LOG
END
GO




/*********************************************************************/
/****************** BEGIN - SET LOCAL VARIABLES **********************/
/*********************************************************************/
declare @Domain varchar(50)
declare @User varchar(50)
declare @FullUsername varchar(32)

set @Domain = 'qa'
set @User = 'ApxAuto0'
set @FullUsername = @Domain + '\' + @User
/*********************************************************************/
/******************* END - SET LOCAL VARIABLES ***********************/
/*********************************************************************/



declare @Lock bit
set @Lock = 0

IF (@Lock = 0)
BEGIN

	BEGIN TRANSACTION;
	BEGIN TRY

		-- BEGIN CREATE ExtractImporter LOGIN AND USER  --
		use Abox
		DECLARE @AppID int;
		SET @AppID = (SELECT AppID FROM tAppSettings WHERE AppName = 'AODExtractImporter.exe');

		IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N'' + @User + '')
			execute('DROP USER [' + @User + ']')
			
		IF  EXISTS (SELECT * FROM sys.server_principals WHERE name = N'' + @Domain + '\' + @User + '')
			execute('DROP LOGIN [' + @Domain + '\' + @User + ']')	
			
		execute ('CREATE LOGIN [' + @Domain + '\' + @User + '] FROM WINDOWS WITH DEFAULT_DATABASE=[ABOX], DEFAULT_LANGUAGE=[us_english]')							
		execute ('CREATE USER  [' + @User + '] FOR LOGIN [' + @Domain + '\' + @User + '] WITH DEFAULT_SCHEMA=[ExImp]')

		execute ('grant select on schema :: dbo TO [' + @Domain + '\' + @User + ']')	
		execute ('grant alter on schema :: ExImp TO [' + @Domain + '\' + @User + ']')	
		execute ('grant select on schema :: ExImp TO [' + @Domain + '\' + @User + ']')	
		execute ('grant execute on schema :: ExImp TO [' + @Domain + '\' + @User + ']')	
		execute ('grant insert on schema :: ExImp TO [' + @Domain + '\' + @User + ']')	
		execute ('grant update on schema :: ExImp TO [' + @Domain + '\' + @User + ']')	
		execute ('grant delete on schema :: ExImp TO [' + @Domain + '\' + @User + ']')	


		USE APXFIRM

		IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N'' + @User + '')
			execute('DROP USER [' + @User + ']')
			
		execute ('CREATE USER  [' + @User + '] FOR LOGIN [' + @Domain + '\' + @User + '] WITH DEFAULT_SCHEMA=[ExImp]')

		execute ('grant select on schema :: dbo TO [' + @Domain + '\' + @User + ']')	
		execute ('grant select on schema :: AdvApp TO [' + @Domain + '\' + @User + ']')	
		execute ('grant select on schema :: APX TO [' + @Domain + '\' + @User + ']')	
		execute ('grant update on [dbo].[AoObject] ([name]) TO [' + @Domain + '\' + @User + ']')	
		execute ('grant execute on [dbo].[pAdvAuditEventBeginWithTran] TO [' + @Domain + '\' + @User + ']')	
		execute ('grant execute on [dbo].[pAdvAuditEventBegin] TO [' + @Domain + '\' + @User + ']')	
		execute ('grant execute on [dbo].[pAdvAuditEventEnd] TO [' + @Domain + '\' + @User + ']')	
		execute ('grant execute on [dbo].[pAdvTotalMarketValueUpdate] TO [' + @Domain + '\' + @User + ']') -- needed for fidelity extract: Account Master

		SELECT 'Successfully updated user: ' + @Domain + '\' + @User + '.' as [Message]
		
		
		USE msdb

		IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N'' + @User + '')
			execute('DROP USER [' + @User + ']')
		-- END CREATE ExtractImporter LOGIN AND USER  --
		
	END TRY
	BEGIN CATCH
		IF (XACT_STATE()) <> 0		
			ROLLBACK TRANSACTION	

		INSERT INTO Abox..tEventLog VALUES ( @@SERVERNAME , suser_name() , @AppID , 3 , GETDATE() , 'Source: Add Windows User, Message: ' + ERROR_MESSAGE() + ', Line: ' + CAST(ERROR_LINE() AS varchar) , 1 );
		GOTO spException;
	END CATCH
END
ELSE
BEGIN
	SELECT 'Please unlock the script by setting the variable ''@Lock'' equal to 0.' as [Message]
	GOTO spException;
END

/******* Final Execution to commit the installation*******/
	COMMIT TRANSACTION;
/******* Final Execution to commit the installation*******/

spException:
SET NOCOUNT OFF;
