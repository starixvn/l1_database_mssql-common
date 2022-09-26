SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

USE	SabaDB;
GO
DECLARE	@Object		SYSNAME		= N'gfn.TimePicker'
	,	@Version	SYSNAME		= N'0.0.1'
	;
EXECUTE	dbo.sp_MSR_InitProcedure @Object;
EXECUTE	dbo.sp_MSR_SetVersion @Object, @Version;
GO
ALTER PROCEDURE	gfn.TimePicker
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

	DECLARE	@UnixEpoch	DATETIME	= '1970-01-01'
		,	@Now		DATETIME	= GETUTCDATE()
		,	@Today		DATETIME	= CAST(GETUTCDATE() AS DATE)
		;

	SELECT	is_primary, name
		,	[time_from]	= DATEDIFF_BIG(MILLISECOND, @UnixEpoch, time_from)
		,	[time_to]	= DATEDIFF_BIG(MILLISECOND, @UnixEpoch, time_to)
	FROM	(VALUES
		(0, 'Today so far', @Today    , @Now      )
	,	(1, 'Yesterday'   , @Today - 1, @Today    )
	,	(0, '2 days ago'  , @Today - 2, @Today - 1)
	,	(0, '3 days ago'  , @Today - 3, @Today - 2)
	,	(0, 'Last 2 days' , @Today - 2, @Today    )
	,	(0, 'Last 3 days' , @Today - 3, @Today    )
	) AS tbl (is_primary, name, time_from, time_to)
END;
GO
