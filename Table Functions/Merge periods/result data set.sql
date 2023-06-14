--результирующий правльный набор данных для теста 1
create table result_1_data_set(
	id_period int,
	d_from datetime,
	d_to datetime,
	t_name varchar(50),
	somedata varchar(128)
)

insert into result_1_data_set values
(1, '20210101','20210109','minor','состояние системы 1'),
(1, '20210110','20210115','priority','середина'),
(1, '20210116','20210131','minor','состояние системы 1'),
(2, '20210201','20210207','priority','середина включая начало'),
(2, '20210208','20210221','minor','состояние системы 2'),
(3, '20210222','20210228','priority','середина включая окончание'),
(4, '20210301','20210331','priority','совпадение периода'),
(4, '20210401','20210401','minor','состояние системы 4'),
(5, '20210402','20210429','priority','совпадение периода, кроме крайних дней'),
(4, '20210430','20210430','minor','состояние системы 4'),
(5, '20210501','20210514','minor','состояние системы 5'),
(6, '20210515','20210610','priority','начало в одном, окончание в другом'),
(6, '20210611','20210620','minor','состояние системы 6'),
(7, '20210621','20210808','priority','начало в одном, окончание в 3-м, т.е. ч/з один'),
(8, '20210809','20210811','minor','состояние системы 8'),
(8, '20210812','20210821','priority','еще середина, после окончания priority, т.е для состояния системы minor даты начала и окончания гененрируются'),
(8, '20210822','20210831','minor','состояние системы 8'),
(9, '20210901','20210901','priority','один день вместо начала'),
(9, '20210902','20210913','minor','состояние системы 9'),
(10,'20210914','20210914','priority','один день всерединке'),
(9, '20210915','20210929','minor','состояние системы 9'),
(11,'20210930','20210930','priority','один день вместо окончания'),
(12,'20211001','20211010','priority','начинается сразу после окончания другого приоритетного, в дату начала minor'),
(10,'20211011','20211031','minor','состояние системы 10'),
(11,'20211101','20211130','minor','состояние системы 11'),
(12,'20211201','20211231','minor','состояние системы 12')


--результирующий правльный набор данных для теста 2 ( с исключениями)
create table result_2_data_set(
	id_period int,
	d_from datetime,
	d_to datetime,
	t_name varchar(50),
	somedata varchar(128)
)