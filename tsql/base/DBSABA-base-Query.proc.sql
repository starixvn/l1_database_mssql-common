SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

USE	SabaDB;
GO
DECLARE	@Object		SYSNAME
	,	@Version	SYSNAME		= N'0.0.2'
	;

SELECT	@Object		= N'base.Query'
EXECUTE	dbo.sp_MSR_InitProcedure @Object;
EXECUTE	dbo.sp_MSR_SetVersion @Object, @Version;

SELECT	@Object		= N'base.QueryQuiet'
EXECUTE	dbo.sp_MSR_InitProcedure @Object;
EXECUTE	dbo.sp_MSR_SetVersion @Object, @Version;
GO
ALTER PROCEDURE	base.Query
					@Query			NVARCHAR(MAX)	= NULL
				,	@L				TINYINT			= NULL
				,	@Type			TINYINT			= NULL
				,	@Env			TINYINT			= NULL
WITH ENCRYPTION
AS
/*
	Creator:		20220919@Billy
	Location:		DBSABA.SabaDB
	Description:	Execute query on Luminet system
	Version:		0.0.2
	Revision:
		- [0.0.2]	20221028@Billy		Using new BI Connector
		- [0.0.1]	20220919@Billy		Initialize from base.ExecuteSabaQuery@1.3.4
*/
BEGIN;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;

	DECLARE	@Platform	NVARCHAR(128)	= NULL
		,	@Label		NVARCHAR(20)	= N'Query'
		,	@Msg		NVARCHAR(MAX)
		;

	/** Platform check */
	SELECT	TOP(1)
			@Platform = host_platform
	FROM	sys.dm_os_host_info;

	/** Forward execution to Windows SQL Server instance due to lack of support for external linked server on Linux SQL Server */
	IF	@Platform = N'Linux'
	BEGIN;
		EXECUTE	logger.Info @label = @Platform, @subject = N'Forwading query to DBBRIDGE';
		EXECUTE	DBBRIDGE.SabaDB.base.Query @Query, @L, @Type, @Env;
		RETURN;
	END;

	/** Log error if platform is not Windows */
	IF	ISNULL(@Platform, N'') <> N'Windows'
	BEGIN;
		EXECUTE	logger.Error @label = @Platform, @subject = N'Invalid platform info. Terminating...';
		RETURN;
	END;

	/** Retry if error is non-critical */
	DECLARE	@Retry		INT				= 3
		;

	Retry:
	BEGIN TRY;
		/** PROD */
		IF	@L = 1 AND @Type = 0 AND @Env = 1
		BEGIN TRY;
			EXECUTE	(@Query) AT [L1_PRO-BI];
		END TRY BEGIN CATCH;
			/** Not found linked server, try local linked server */
			IF	ERROR_NUMBER() = 7202
				EXECUTE	(@Query) AT L1BI;
			/** Pass control to outer error handler */
			ELSE THROW;
		END CATCH;

		IF	@L = 2 AND @Type = 0 AND @Env = 1
		BEGIN TRY;
			EXECUTE	(@Query) AT [L2_PRO-BI];
		END TRY BEGIN CATCH;
			/** Not found linked server, try local linked server */
			IF	ERROR_NUMBER() = 7202
				EXECUTE	(@Query) AT L2BI;
			/** Pass control to outer error handler */
			ELSE THROW;
		END CATCH;


		/** UAT */
		IF	@L = 1 AND @Type IN (0, 1) AND @Env = 2
		BEGIN TRY;
			EXECUTE	(@Query) AT [L1_UAT-BI];
		END TRY BEGIN CATCH;
			/** Not found linked server, try local linked server */
			IF	ERROR_NUMBER() = 7202
				EXECUTE	(@Query) AT L1pBI;
			/** Pass control to outer error handler */
			ELSE THROW;
		END CATCH;

		IF	@L = 2 AND @Type IN (0, 1) AND @Env = 2
		BEGIN TRY;
			EXECUTE	(@Query) AT [L2_UAT-BI];
		END TRY BEGIN CATCH;
			/** Not found linked server, try local linked server */
			IF	ERROR_NUMBER() = 7202
				EXECUTE	(@Query) AT L2pBI;
			/** Pass control to outer error handler */
			ELSE THROW;
		END CATCH;


		/** SIT */
		IF	@L = 1 AND @Type IN (0, 1) AND @Env = 3
		BEGIN TRY;
			EXECUTE	(@Query) AT [L1_SIT-BI];
		END TRY BEGIN CATCH;
			/** Not found linked server, try local linked server */
			IF	ERROR_NUMBER() = 7202
				EXECUTE	(@Query) AT L1ppBI;
			/** Pass control to outer error handler */
			ELSE THROW;
		END CATCH;

		IF	@L = 2 AND @Type IN (0, 1) AND @Env = 3
		BEGIN TRY;
			EXECUTE	(@Query) AT [L2_SIT-BI];
		END TRY BEGIN CATCH;
			/** Pass control to outer error handler */
			THROW;
		END CATCH;

	END TRY BEGIN CATCH;
		/** If error is retryable, retry */
		IF	@Retry > 0
		AND	ERROR_NUMBER() IN (7303)
		BEGIN;
			SELECT	@Retry 	= @Retry - 1
				,	@Msg	= CONCAT(N'Encounter retryable error [', ERROR_NUMBER(), N'], retrying...')
				;
			EXECUTE	logger.Warning @label = @Label, @subject = @Msg;

			IF	@@TRANCOUNT > 0 ROLLBACK;

			EXECUTE	base.Wait @sec = 1;
			GOTO Retry;
		END;
		ELSE THROW;
	END CATCH;
END;
GO
ALTER PROCEDURE	base.QueryQuiet
					@Query			NVARCHAR(MAX)	= NULL
				,	@L				TINYINT			= NULL
				,	@Type			TINYINT			= NULL
				,	@Env			TINYINT			= NULL
WITH ENCRYPTION
AS
/*
	Creator:		20220919@Billy
	Location:		DBSABA.SabaDB
	Description:	Execute query on Luminet system but slient all errors
	Version:		0.0.1
	Revision:
		- [0.0.1]	20220919@Billy		Initialize
*/
BEGIN;
	DECLARE	@Label		NVARCHAR(20)	= N'Query!'
		,	@Msg		NVARCHAR(MAX)
		;

	BEGIN TRY;
		EXECUTE	base.Query @Query, @L, @Type, @Env;
	END TRY BEGIN CATCH;
		/** Log error */
		SELECT	@Msg = CONCAT(N'Failed to execute query for @L = ', @L, N', @Type = ', @Type, N', @Env = ', @Env)
			;
		EXECUTE	logger.Error @label = @Label, @subject = @Msg;

		IF	@@TRANCOUNT > 0 ROLLBACK;
	END CATCH;
END;
