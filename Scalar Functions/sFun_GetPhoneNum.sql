
CREATE function [dbo].[sfun_GetPhoneNum] (@phone nvarchar(512), @s int=0)
RETURNS nvarchar(512)
--возврвщает строку цифр (номер тлф) без "лишних" символов
AS
begin
  -- @s=0 удалять все не буквы, кроме #,*
  -- @s=1 удалять все, кроме #,*,(),+," "

	declare @cnt_ int, @i_ int = 0
	declare @strout nvarchar(512)= '', @ch nvarchar(1) = ''

	if 0 < patindex('%[а-я]%',@phone)
	  set @phone = substring(@phone, 1, patindex('%[а-я]%',@phone)-1)
	set @cnt_ = len(@phone)

	while (0 < @cnt_) and (@i_ <= @cnt_)
	begin
		set @i_ = @i_ + 1
		set @ch = substring(@phone, @i_,1)

		if 0 = isnumeric(@ch)
		or (isnumeric(@ch)=1 and @s in (0) and @ch in ('+','-','.','/'))
		and not (    (@s in (0) and @ch in ('#','*')) or (@s in (1) and @ch in ('(',')',' ','+','-'))     )
			set @ch = ''
		set @strout = @strout + @ch
	end

	set @phone = @strout
	set @phone = replace(@phone, '()','')
	if substring(@phone,len(@phone),1)='('
		set @phone = substring(@phone,1,len(@phone)-1)
	return @phone
end
