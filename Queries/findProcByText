--Ищет имя процедуры по тексту внутри. Ищет в текущей БД.
--Searches for the name of the procedure by text inside. Searches the current database.

--use [dbName]
declare @findText nvarchar(100) = 'some text'

select OBJECT_NAME(OBJECT_ID)
from sys.sql_modules
where 1 = OBJECTPROPERTY(object_id, 'IsProcedure')
	and definition like '%'+ @findText +'%'
