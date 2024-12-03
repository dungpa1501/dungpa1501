declare @var nvarchar(100)
select @var =  [User Security ID]   from [dbo].[User] where [User Name] --= 'GALAXY\TIENPLM'
--select * 
delete from [dbo].[User] where [User Name] --= 'GALAXY\TIENPLM'
--select * 
delete from [dbo].[Access Control] where [User Security ID] = @var
--select * 
delete from [dbo].[User Property] where [User Security ID] = @var
--select * 
delete from [dbo].[Page Data Personalization] where [User SID] = @var
--select * 
delete from [dbo].[User Metadata] where [User SID] = @var
--select * 
delete from [dbo].[User Personalization] where [User SID] = @var
 
 
 