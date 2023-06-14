CREATE
function [dbo].[merge_periods] ()
--объединение двух периодов. один приоритетный - перекрывает другой при пересечении дат.
--прдварительно положить данные в таблицы priority_table, minor_table
--требования к данным
--1) в таблице minor_table периоды следуют друг за другом без перерывов.
--2) в таблице priority_table периоды могут, как следовать друг за другом, так и прерываться.
--3) некоторые периоды в таблице priority_table могут быть не приоритетными, в такие периоды предпочтение отдается периоду из таблицы minor_table. Такие периоды помечены флагом 1 в отдельном поле exception_period. остальные - 0.
RETURNS @tbl_merged TABLE (
	id_period int,
	d_from datetime,
	d_to datetime,
	t_name varchar(50)
)
AS
BEGIN

declare @priority varchar(50) = 'priority';
declare @minor varchar(50) = 'minor';

declare @tbl_p table (
	id int,
	d_from datetime,
	d_to datetime,
	t_name varchar(50),
	exception_period bit
)

declare @tbl_m table (
	id int,
	d_from datetime,
	d_to datetime,
	t_name varchar(50)
)

insert into @tbl_p( id, d_from, d_to, t_name, exception_period )
select id, d_from, d_to, @priority as t_name, isnull(exception_period,0)
from priority_table; 

insert into @tbl_m( id, d_from, d_to, t_name )
select id, d_from, d_to, @minor as t_name
from minor_table;

------------------------------------
declare @c table (
	id int,
	fd datetime,
	td datetime,
	tbl varchar(50)
);
declare @p_id int, @p_df date, @p_dt date, @exception_period bit;
declare @m_id int, @m_df date, @m_dt date;

declare cur_p cursor for
	select id, d_from, d_to, t_name, exception_period from @tbl_p
	order by d_from;

declare cur_m cursor for
	select id, d_from, d_to, t_name from @tbl_m
	order by d_from;
-------------------------

OPEN cur_p;
while 1=1
begin
	FETCH NEXT FROM cur_p
	INTO @p_id, @p_df, @p_dt, @priority, @exception_period;
	if @@FETCH_STATUS = 0  AND  @exception_period = 1
		continue --пропуск исключительных периодов. В таблице приоритетных периодов, могут быть периоды исключения.
	else break;
end;

if @@FETCH_STATUS <> 0 begin
	--если приоритетная таблица оказалась пустой или в ней только периоды исключения, то вернем вторую таблицу, что бы в ней ни было.
	--print 'Error fetch cur_P'; --dbg
	insert into @tbl_merged(id_period, d_from, d_to)
	select id, d_from, d_to
	from @tbl_m;
	GOTO QUIT;
end


OPEN cur_m;
FETCH NEXT FROM cur_m   
INTO @m_id, @m_df, @m_dt, @minor;
if @@FETCH_STATUS <> 0 begin
	--если таблица minor оказалась пустой, то вернем все данные, без изменений, из приоритетной
	--print 'Error fetch cur_M'; --dbg
	insert into @tbl_merged(id_period, d_from, d_to)
	select id, d_from, d_to
	from @tbl_p;
	GOTO QUIT;
end;
--------------

WHILE @@FETCH_STATUS = 0
BEGIN 
	--print cast(@p_df as varchar) +' '+ cast(@p_dt as varchar) +' '+ cast(@t_id as varchar) +' | '+ cast(@p_id as varchar) +' '+ cast(@m_df as varchar) +' '+ cast(@m_dt as varchar); --dbg

	if @m_df < @p_df and @p_df <= @m_dt and @m_dt < @p_dt begin --1
		--print '1'; --dbg
		insert into @c values(@m_id, @m_df, dateadd(day,-1,@p_df), @minor);
	end
	else if @p_df < @m_df and @m_df <= @p_dt and @p_dt < @m_dt begin --2
		--print '2'; --dbg
		set @m_df = dateadd(day,+1,@p_dt);
	end
	else if @m_df <= @p_df and @p_dt <= @m_dt begin --3
		--print '3'; --dbg
		if(@m_df <> @p_df) 
			insert into @c values(@m_id, @m_df, dateadd(day,-1,@p_df), @minor);
		if(@m_dt <> @p_dt)
			set @m_df = dateadd(day,+1,@p_dt);
	end
	-- else if @p_df <= @m_df and @m_dt <= @p_dt --4 сдвиг cur_m будет по условию ниже
	else if @m_dt < @p_df begin --5
		--print '5'; --dbg
		insert into @c values(@m_id, @m_df, @m_dt, @minor);
	end
	--else if @p_df < @m_dt  --6 сдвиг cur_p будет по условию ниже
	--else impossible

	---сдвиг одного из периодов
	if @m_dt <= @p_dt begin
		FETCH NEXT FROM cur_m
		INTO @m_id, @m_df, @m_dt, @minor
	end
	else begin
		while 1=1 begin
			FETCH NEXT FROM cur_p
			INTO @p_id, @p_df, @p_dt, @priority, @exception_period;
			if @@FETCH_STATUS = 0  AND  @exception_period = 1
				continue --пропускаем исключительные периоды
			else break;
		end
	end
END;
--------------

if @p_dt < @m_dt
	insert into @c values(@m_id, @m_df, @m_dt, @minor); --дописываем хвост последнего неприоритетного периода

--дописываем приоритетные периоды и оставшиеся из minor
insert into @c
select id, d_from, d_to, t_name
from @tbl_p
where exception_period <> 1
union all 
select id, d_from, d_to, t_name
from @tbl_m
where @m_dt < d_from
;

insert into @tbl_merged (id_period, d_from, d_to, t_name)
select id, fd, td, tbl
from @c;

--------------
QUIT:
if CURSOR_STATUS('global','cur_m') = 1
	CLOSE cur_m;
if CURSOR_STATUS('global','cur_m') = -1
	DEALLOCATE cur_m;
if CURSOR_STATUS('global','cur_p') = 1
	CLOSE cur_p;
if CURSOR_STATUS('global','cur_p') = -1
	DEALLOCATE cur_p;

RETURN
end
