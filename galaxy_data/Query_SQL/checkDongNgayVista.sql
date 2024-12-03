SELECT 'Business day is not closed for ' + CONVERT(varchar(10), POSS_dtmBusinessDate, 101)
FROM tblPOS_Sess
WHERE POSS_dtmBusinessDate = '2024-05-05'
AND POSS_dtmBusinessDate NOT IN (SELECT DCJ_dtmBusinessDate FROM tblDailyCashJournal   
WHERE DCJ_strStatus = 'C' AND DCJ_dtmBusinessDate = '2024-05-05')



SELECT * FROM tblDailyCashJournal   
WHERE 1=1 
--DCJ_strStatus = 'C' 
AND DCJ_dtmBusinessDate >= '2024-05-05'

