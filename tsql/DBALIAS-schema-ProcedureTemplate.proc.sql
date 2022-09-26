SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

USE	SabaDB;
GO
DECLARE	@Object		SYSNAME		= N'<schema>.<procedure>'
	,	@Version	SYSNAME		= N'0.0.1'
	;
EXECUTE	dbo.sp_MSR_InitProcedure @Object;
EXECUTE	dbo.sp_MSR_SetVersion @Object, @Version;
GO
ALTER PROCEDURE	<schema>.<procedure>
WITH ENCRYPTION
AS
/*
	Creator:		20220919@Billy
	Location:		DBSABA.SabaDB
	Description:	
	Version:		0.0.1
	Revision:
		- [0.0.1]	20220919@Billy		Initialize
*/
BEGIN;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
END;
GO
