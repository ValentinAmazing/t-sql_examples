-- If you have  SQL Server 2022 (16.x)  use the GENERATE_SERIES() function
--https://learn.microsoft.com/en-us/sql/t-sql/functions/generate-series-transact-sql?view=sql-server-ver16

WITH 
     t10 AS (SELECT n FROM (VALUES(0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) t(n))
    ,t1k AS (SELECT 0 AS n FROM t10 AS a CROSS JOIN t10 AS b CROSS JOIN t10 AS c)
    ,t100k AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS n FROM t1k AS a CROSS JOIN t10 AS b CROSS JOIN t10 AS c)
SELECT n
FROM t100k
