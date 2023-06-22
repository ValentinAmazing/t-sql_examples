--Выводит поля и тип данных таблицы по ее имени.
--Shows the fields and data type of a table by its name.
---в confluence копируется ч/з excel сразу всё

--use [dbName]
declare @table_name varchar(100) = 'Classes' --Имя таблицы
declare @SCHEMA_NAME varchar(60) = N'dbo'
declare
	 @type_varchar   int = 167
	, @type_nvarchar int = 231
	, @type_DataType int = 61; 

select
	c.name as 'Имя поля'
	, t.name+ (
		case c.system_type_id
		when @type_varchar  then '('+convert(varchar(10), c.max_length)+')'
		when @type_nvarchar then '('+convert(varchar(10), c.max_length/2)+')'
		else ''
		end
	) as 'Тип значения'
  --, '' as 'Расшифровка', '' as 'Пример значения'
	,c.system_type_id
	,t.xtype , t.*
from 
	sys.objects o
	join sys.columns c on c.object_id = o.object_id
	join sys.systypes t on t.xtype = c.system_type_id
where SCHEMA_NAME(o.schema_id)=@SCHEMA_NAME
	and o.name = @table_name
	and t.name <> 'sysname'
	--and c.system_type_id = @type_DataType
order by c.column_id
