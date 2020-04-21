USE AdventureWorks2012
GO
/*
    When is an auto-update statistics triggered?
    AUTO_UPDATE_STATISTICS
  
   - If the cardinality of the table is less than six and the table is in tempdb database, auto-updates every six modifications to the table

   - If the cardinality of the table is greater than six and less than or equal to 500, then update the statistics after every 500 changes in the table

   - If the cardinality of the table is greater than 500, updates the statistics when 500 + 20% of the table is changed.
  
*/

-- Check if table exist, if yes, drop it.
IF OBJECT_ID('PersonBig') IS NOT NULL 
BEGIN
	DROP TABLE [PersonBig]
END
CREATE TABLE [dbo].[PersonBig](
	[PersonID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [int] NULL,
	[OrderDate] [date] NOT NULL,
	[Value] [numeric](18, 2) NOT NULL
) ON [PRIMARY]
GO

-- First Insert 
INSERT INTO [PersonBig] WITH (TABLOCK) ([CustomerID], OrderDate, Value) 
SELECT TOP 100000
       ABS(CHECKSUM(NEWID())) / 100000 AS CustomerID,
       ISNULL(CONVERT(Date, GETDATE() - (CheckSUM(NEWID()) / 1000000)), GetDate()) AS OrderDate,
       ISNULL(ABS(CONVERT(Numeric(18,2), (CheckSUM(NEWID()) / 1000000.5))),0) AS Value
  FROM Person.Person A
 CROSS JOIN Person.Person B
 CROSS JOIN Person.Person C
 CROSS JOIN Person.Person D
GO


-- Create Indexes
CREATE CLUSTERED INDEX [PK_PersonId] ON [PersonBig] ([PersonID]);
GO
CREATE NONCLUSTERED INDEX [IX_CustomerID] ON [PersonBig] ([CustomerID]);
GO

-- Get stats information
-- After running the code below you will be able to see the last updated date

SELECT
	OBJECT_NAME([sp].[object_id]),
	[sp].[stats_id] ,
	[s].[name] ,
	[sp].[last_updated] ,
	[sp].[rows],
	[sp].[rows_sampled],
	[sp].[unfiltered_rows],
	[sp].[modification_counter]  
FROM [sys].[stats] AS [s]
OUTER APPLY sys.dm_db_stats_properties ([s].[object_id],[s].[stats_id]) AS [sp]
WHERE [s].[object_id] = OBJECT_ID(N'PersonBig'); -- Table name
GO


-- Insert rows using Statistics Formula
-- Formula (100000 * 20%) + 500
DECLARE @Total      INT = 20500

-- Second Insert (
INSERT INTO [PersonBig] WITH (TABLOCK) ([CustomerID], OrderDate, Value) 
SELECT TOP (@Total)
       ABS(CHECKSUM(NEWID())) / 100000 AS CustomerID,
       ISNULL(CONVERT(Date, GETDATE() - (CheckSUM(NEWID()) / 1000000)), GetDate()) AS OrderDate,
       ISNULL(ABS(CONVERT(Numeric(18,2), (CheckSUM(NEWID()) / 1000000.5))),0) AS Value
  FROM Person.Person A
 CROSS JOIN Person.Person B
 CROSS JOIN Person.Person C
 CROSS JOIN Person.Person D
GO


-- Check Stats again (Modification_counter)
SELECT
	OBJECT_NAME([sp].[object_id]),
	[sp].[stats_id] ,
	[s].[name] ,
	[sp].[last_updated] ,
	[sp].[rows],
	[sp].[rows_sampled],
	[sp].[unfiltered_rows],
	[sp].[modification_counter]  
FROM [sys].[stats] AS [s]
OUTER APPLY sys.dm_db_stats_properties ([s].[object_id],[s].[stats_id]) AS [sp]
WHERE [s].[object_id] = OBJECT_ID(N'PersonBig');
GO

-- Involking the Automatic Update
SELECT * FROM PersonBig WHERE PersonID = 1 AND CustomerID = 10751

-- Run the query to check the stats again :)