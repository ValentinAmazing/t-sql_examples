--Все индексы выбранной таблицы
--Shows all indexes of the selected table
---для наглядности и отладки в студии переключить в режим Results to text (Ctrl + T) и закоментировать вывод поля ix_name. 

--use [dbName]
declare @table_name varchar(120) = N'phones'
declare @SCHEMA_NAME varchar(60) = N'dbo'

;with cte_ix as(
	select 
		i.is_primary_key
		, '['+i.name+']' as ix_name
		, ic.key_ordinal
		, iif(0<ic.key_ordinal, '['+clmns.name+']'+ iif(0=is_descending_key,' ACS',' DESC'), null)  as 'in_index'
		, ic.is_included_column
		, iif(0<ic.is_included_column, '['+clmns.name+']',null) as 'included'
		, i.filter_definition
		--, STRING_AGG(iif(0<ic.key_ordinal, '['+clmns.name+']'+ iif(0=is_descending_key,' ACS',' DESC'), ''),  char(10) ) +char(10)+
		-- 'INCLUDE('+ iif(0<ic.is_included_column, string_agg('['+clmns.name+']',','), '')+')' as 'included'
		--, ic.* , clmns.*
	FROM
		sys.tables AS tbl
		JOIN sys.indexes AS i ON  (i.object_id=tbl.object_id)
		JOIN sys.index_columns AS ic ON (ic.column_id > 0 and (ic.key_ordinal > 0 or ic.partition_ordinal = 0 or ic.is_included_column != 0)) AND (ic.index_id=CAST(i.index_id AS int) AND ic.object_id=i.object_id)
		JOIN sys.columns AS clmns ON clmns.object_id = ic.object_id and clmns.column_id = ic.column_id
	WHERE tbl.name=@table_name
		and  SCHEMA_NAME(tbl.schema_id)=@SCHEMA_NAME
)
--select * from cte_ix
 select 
	ix_name,
	--для наглядности и отладки в студии переключить в режим Results to text (Ctrl + T) и закоментировать вывод поля ix_name. 
	string_agg(in_index,','+char(10)) WITHIN GROUP ( ORDER BY key_ordinal )
	+isnull(char(10)+ 'INCLUDE('+ string_agg(included, ',') +')','' )
	+isnull(char(10)+ 'WHERE'+ filter_definition, '')
	+char(10) as idx
 from cte_ix
 group by is_primary_key,ix_name,filter_definition
 order by is_primary_key desc, ix_name
