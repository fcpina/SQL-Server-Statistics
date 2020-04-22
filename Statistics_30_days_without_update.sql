-- ============================================================
-- Created by: Filipe Pina
-- Statistic with more than 30 days without update
-- ============================================================


SELECT 
	OBJECT_NAME(S.object_id)  [Table  Name],     -- Table Name
	C.name					  [Column Name],     -- Column Name
	S.name					  [Statistics Name], -- Name of the statistics. Is unique within the object.
	SP.last_updated			  [Last Updated],    -- Date and time the statistics object was last updated. 
	SP.rows					  [Rows],			 -- Total number of rows in the table or indexed view when statistics were last updated.   
	SP.steps				  [Steps],           -- Number of steps in the histogram.
	SP.modification_counter   [Modified Counter],-- Total number of modifications for the leading statistics column
	'DROP STATISTICS [' + OBJECT_SCHEMA_NAME(S.object_id) + '].[' + OBJECT_NAME(S.object_id) + '].['+ S.name + ']' [Drop Script]
FROM sys.stats S
INNER JOIN sys.stats_columns SC
	ON  S.object_id = SC.object_id 
	AND S.stats_id  = SC.stats_id
INNER JOIN sys.columns C
	ON SC.object_id = C.object_id 
	AND SC.column_id = C.column_id
CROSS APPLY sys.dm_db_stats_properties(S.object_id, S.stats_id) SP
WHERE 1 = 1 
AND S.auto_created     = 1   -- 1 = Statistics were automatically created by SQL Server.
AND SC.stats_column_id = 1
AND STATS_DATE(s.object_id, s.stats_id) < GETDATE() - 30
AND SUBSTRING(OBJECT_NAME(S.object_id) ,1, 3) NOT IN ('sys','dtp')  
AND SUBSTRING(OBJECT_NAME(S.object_id) , 1,1) <> '_' -- Eliminates Temp Tables
