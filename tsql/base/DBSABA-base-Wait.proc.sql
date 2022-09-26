SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

USE	SabaDB;
GO
DECLARE	@Object		SYSNAME		= N'base.Wait'
	,	@Version	SYSNAME		= N'0.0.1'
	;
EXECUTE	dbo.sp_MSR_InitProcedure @Object;
EXECUTE	dbo.sp_MSR_SetVersion @Object, @Version;
GO
ALTER PROCEDURE	base.Wait
					@sec			INT			= NULL
WITH ENCRYPTION
AS
/*
	Creator:		20220919@Billy
	Location:		DBSABA.SabaDB
	Description:	Wait for random duration
	Version:		0.0.1
	Revision:
		- [0.0.1]	20220919@Billy		Initialize
*/
BEGIN;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;

	BEGIN TRY;
	DECLARE	@WaitFor	VARCHAR(16)		= CONCAT('00:00:0',  CAST(ABS(CHECKSUM(NEWID())) % ISNULL(ABS(@Sec), 3) AS CHAR(1)), '.', CAST(ABS(CHECKSUM(NEWID())) % 1000 AS CHAR(3)))
		;
	WAITFOR DELAY @WaitFor;
	END TRY BEGIN CATCH;
		EXECUTE	logger.Warning @label = N'Wait', @subject = N'Something is wrong while executing wait';
	END CATCH;
END;
GO
