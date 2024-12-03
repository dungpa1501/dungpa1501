SELECT distinct 
[User Name],	[Full Name],ur.[Role ID], ob.Name as 'Table', ur.[Company Name], [Read Permission],	[Insert Permission], [Modify Permission],	[Delete Permission],	[Execute Permission]
FROM 
    [dbo].[User] AS u
JOIN 
   [dbo].[Access Control] AS ur ON u.[User Security ID] = ur.[User Security ID]
JOIN [Permission ] p ON p.[Role ID] = ur.[Role ID]
JOIN [Object] ob ON ob.ID = p.[Object ID]