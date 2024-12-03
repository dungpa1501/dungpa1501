select 'union all\nSELECT "============'  + table_Name + '.sql===== as TextData"\n' +
	'union all
select TextData from [' + table_Name + ']
where TextData not like @%network protocol%@ and  TextData not like @%exec sp_reset_connection %@'
FROM 
(select distinct table_Name from INFORMATION_SCHEMA.COLUMNS) a