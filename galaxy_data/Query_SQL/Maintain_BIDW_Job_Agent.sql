-- maintain job ssis

SELECT
    ja.job_id,
    j.name AS job_name,
    ja.start_execution_date,      
    ISNULL(last_executed_step_id,0)+1 AS current_executed_step_id,
    Js.step_name,
		   COALESCE(CONVERT(VARCHAR(5),ABS(DATEDIFF(DAY,(GETDATE()-ja.start_execution_date),'1900-01-01'))) + ' '
               +CONVERT(VARCHAR(10),(GETDATE()-ja.start_execution_date),108),'00 00:00:00') AS [Duration] 
FROM msdb.dbo.sysjobactivity ja 
LEFT JOIN msdb.dbo.sysjobhistory jh ON ja.job_history_id = jh.instance_id
JOIN msdb.dbo.sysjobs j ON ja.job_id = j.job_id
JOIN msdb.dbo.sysjobsteps js
    ON ja.job_id = js.job_id
    AND ISNULL(ja.last_executed_step_id,0)+1 = js.step_id
WHERE
  ja.session_id = (
    SELECT TOP 1 session_id FROM msdb.dbo.syssessions ORDER BY agent_start_date DESC
  )
AND start_execution_date is not null
AND stop_execution_date is null;