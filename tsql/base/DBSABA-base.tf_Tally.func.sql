SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

USE	SabaDB;
GO
DECLARE	@Object		SYSNAME		= N'base.tf_Tally'
	,	@Version	SYSNAME		= N'0.0.1'
	;
EXECUTE	dbo.sp_MSR_InitInlineTableFunction @Object;
EXECUTE	dbo.sp_MSR_SetVersion @Object, @Version;
GO
ALTER FUNCTION	base.tf_Tally (
					@Top			BIGINT
				)
RETURNS TABLE
WITH ENCRYPTION
AS
/*
	Creator:		20220921@Billy
	Location:		DBSABA.SabaDB
	Description:	
	Version:		0.0.1
	Revision:
		- [0.0.1]	20220919@Billy		Initialize
*/
RETURN (
	SELECT	TOP(ISNULL(@Top, 10))
			[n] = ROW_NUMBER() OVER(ORDER BY (SELECT 0))
	FROM		(
		SELECT	0
		FROM		(VALUES (0), (0), (0), (0), (0), (0), (0), (0), (0), (0)) AS x10(n)
		CROSS APPLY	(VALUES (0), (0), (0), (0), (0), (0), (0), (0), (0), (0)) AS x100(n)
		CROSS APPLY	(VALUES (0), (0), (0), (0), (0), (0), (0), (0), (0), (0)) AS x1000(n)
	) AS x10e3(n)
	CROSS APPLY	(
		SELECT	0
		FROM		(VALUES (0), (0), (0), (0), (0), (0), (0), (0), (0), (0)) AS x10(n)
		CROSS APPLY	(VALUES (0), (0), (0), (0), (0), (0), (0), (0), (0), (0)) AS x100(n)
		CROSS APPLY	(VALUES (0), (0), (0), (0), (0), (0), (0), (0), (0), (0)) AS x1000(n)
	) AS x10e9(n)
);
GO
