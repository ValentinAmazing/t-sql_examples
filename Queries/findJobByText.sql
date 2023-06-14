--Ищет имя job по содержимому в задании
--Looks up job name by content in job

declare @findText nvarchar(100) = 'some text'

select jo.*, ob.*
from msdb.dbo.sysjobsteps ob(nolock)
	join msdb.dbo.sysjobs jo(nolock)
			on jo.job_id = ob.job_id
where ob.command like '%'+ @findText +'%'
