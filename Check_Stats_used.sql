-- ============================================================
-- Created by: Filipe Pina
-- Description: Check which stats the optimizer chose to use
-- ============================================================ 

--Removes all elements from the plan cache
DBCC FREEPROCCACHE

-- Simple query
SELECT  P.FirstName, P.LastName, E.EmailAddress, PP.PhoneNumber
FROM Person.Person P
JOIN Person.EmailAddress E ON P.BusinessEntityID = E.BusinessEntityID
JOIN Person.PersonPhone PP ON P.BusinessEntityID = PP.BusinessEntityID


SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO
-- Start Trace Flag
DBCC TRACEON (8666);
GO
-- Show which stats were used on the query Plan
WITH XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/showplan' as p)
SELECT qt.text AS SQLCommand,
qp.query_plan,
StatsUsed.XMLCol.value('@FieldValue','NVarChar(500)') AS StatsName
FROM sys.dm_exec_cached_plans cp
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) qp
CROSS APPLY sys.dm_exec_sql_text (cp.plan_handle) qt
CROSS APPLY query_plan.nodes('//p:Field[@FieldName="wszStatName"]') StatsUsed(XMLCol)
WHERE  qt.text NOT LIKE '%sys.%'
GO
DBCC TRACEOFF(8666);
GO