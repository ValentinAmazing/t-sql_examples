--- описание
-- таблицы data_set_minor и data_set_priority имитируют реальные данные в БД.
-- для объединения периодов в функции используются таблицы minor_table и priority_table.
-- необходимые периоды вставляются из первых таблиц во вторые.
-- затем результат функции соединяется с сотояниями системы по id.

--таблица штатных непреРывных периодов
drop table if exists data_set_minor
create table data_set_minor(
	id int,
	d_from datetime,
	d_to datetime,
	--exception_period bit,
	somedata varchar(256) 
)
--генерация штатных периодов для тестового набора данных
--для простоты периоды будут длительностью один месяц от 1го чисала до последноего в месяце.
declare @start_period datetime = '20210101';
declare @end_period datetime = '20211212';
with cte as(
	select dateadd(d, 1, EOMONTH(@start_period, -1)) m_st, EOMONTH(@start_period) m_end
	union all
	select dateadd(m, 1, m_st), EOMONTH(dateadd(m, 1, m_end)) from cte
	where m_st < @end_period
)
insert into data_set_minor(id, d_from, d_to, somedata)
select ROW_NUMBER() over(order by m_st) id, m_st, m_end, 'состояние системы '+ convert(varchar(3), ROW_NUMBER() over(order by m_st))
from cte


--таблица непреДвиденных периодов, которые необходимо встроить в штатные периоды
drop table if exists data_set_priority
create table data_set_priority(
	id int identity(1,1),
	d_from datetime,
	d_to datetime,
	somedata varchar(256)
)

insert into data_set_priority(d_from, d_to, somedata)
values
	 ('20210110','20210115','середина')
	,('20210201','20210207','середина включая начало')
	,('20210222','20210228','середина включая окончание')
	,('20210301','20210331','совпадение периода')
	,('20210402','20210429','совпадение периода, кроме крайних дней')
	,('20210515','20210610','начало в одном, окончание в другом')
	,('20210621','20210808','начало в одном, окончание в 3-м, т.е. ч/з один')
	,('20210812','20210821','еще середина, после окончания priority, т.е для состояния системы minor даты начала и окончания гененрируются')
	,('20210901','20210901','один день вместо начала')
	,('20210914','20210914','один день всерединке')
	,('20210930','20210930','один день вместо окончания')
	,('20211001','20211010','начинается сразу после окончания другого приоритетного, в дату начала minor')


--1 проверка.
drop table if exists priority_table
drop table if exists minor_table

--положим данные из основных таблиц в промежутоные
select id, d_from, d_to, 0 as exception_period 
into priority_table
from data_set_priority

select id, d_from, d_to 
into minor_table
from data_set_minor

select * from priority_table
select * from minor_table

--1 проверка. Результат.
select merged.*, isnull(minor.somedata, priority.somedata) 
from [dbo].[merge_periods]() merged
	left join data_set_minor minor on minor.id = merged.id_period and merged.t_name = 'minor'
	left join data_set_priority priority on priority.id = merged.id_period and merged.t_name = 'priority'
order by merged.d_from


--2 проверка. ИСКЛЮЧЕНИЯ. Пометим некоторые кортежи в таблице штатных периодов исключительными
drop table if exists priority_table
drop table if exists minor_table

select id, d_from, d_to, iif(month(d_from) in (5,8), 1,0) as exception_period 
into priority_table
from data_set_priority

select id, d_from, d_to 
into minor_table
from data_set_minor

select * from priority_table
select * from minor_table

--2 проверка. Результат.
select merged.*, isnull(minor.somedata, priority.somedata) 
from [dbo].[merge_periods]() merged
	left join data_set_minor minor on minor.id = merged.id_period and merged.t_name = 'minor'
	left join data_set_priority priority on priority.id = merged.id_period and merged.t_name = 'priority'
order by merged.d_from
