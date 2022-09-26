/** https://learn.microsoft.com/en-us/sql/relational-databases/in-memory-oltp/the-memory-optimized-filegroup?view=sql-server-ver16 */

/** The container filegroup that hold memory_optimized_data */
ALTER DATABASE SabaDB ADD FILEGROUP inMemOpData CONTAINS MEMORY_OPTIMIZED_DATA;

/** Create folder */
EXECUTE	sys.xp_create_subdir 'G:\Billy\SabaDB\inMemOp';

/** Create memory_optimized_data container */
ALTER DATABASE SabaDB ADD FILE (
	NAME		= 'inMemOpData_01'
,	FILENAME	= 'G:\Billy\SabaDB\inMemOp\inMemOpData_01'
) TO FILEGROUP inMemOpData;
