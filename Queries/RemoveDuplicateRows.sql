--Удаляет дубли строк в таблице без поля id
--Remove duplicate rows

-->> тестовый набор данных содержит 5ть уникальных записей
declare @tbl table (
	fname nvarchar(15),
	iname nvarchar(15),
	oname nvarchar(15)
)
insert into @tbl values
('Акулова', 'Марина', 'Сергеевна'), --3и вхождения
('Алимова','Наталья','Ивановна'), --1
('Ветрова', 'Ксения', 'Игоревна'), --2
('Акулова', 'Ксения', 'Сергеевна'), --1
('Акулова', 'Марина', 'Ивановна'), --1
('Акулова', 'Марина', 'Сергеевна'),
('Акулова', 'Марина', 'Сергеевна'),
('Ветрова', 'Ксения', 'Игоревна')
--<< end тестовый набор данных

DELETE tb FROM (
	SELECT DupRank = ROW_NUMBER() OVER (
				  PARTITION BY fname, iname, oname
				  ORDER BY (SELECT NULL)
				)
	FROM @tbl
) AS tb
WHERE DupRank > 1

select * from @tbl
