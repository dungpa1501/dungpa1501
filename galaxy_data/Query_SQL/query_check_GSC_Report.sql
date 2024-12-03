-- BIDW

declare @from datetime , @to datetime 
set @from = cast(cast(getdate()-1 as date) as datetime)
set @to = cast(cast(getdate() as date) as datetime)

select sum(ADMITS_TOTAL) adm ,sum(BOX_NET)  BOX_NET
from W_HO_DAILY_PERFORMANCE_F
where BUSINESS_DATE >= @from and BUSINESS_DATE < @to

union all

select sum(ADMIT_QUANTITY) adm, sum(NET_SALES_VALUE) bo_net
from W_HO_SESSION_SUMMARY_F
where BUSINESS_DATE >= @from and BUSINESS_DATE < @to

-- HO

declare @from datetime , @to datetime 
set @from = cast(cast(getdate()-1 as date) as datetime)
set @to = cast(cast(getdate() as date) as datetime)

select sum(Performance_intTotalAdmits) adm, sum(Performance_curBoxNet)*1000 net_bo
from tblHODailyPerformance a 
join tblCinema_Operator b on a.CinOperator_strCode = b.CinOperator_strCode
where Performance_dtmBusinessDate >= @from
and Performance_dtmBusinessDate < @to

union all 

select sum(HOSessTTS_intQuantityOfAdmits) adm, sum(HOSessTTS_curNetSalesValue)*1000 as net_bo
from [tblHOSessionSummaryTT] 
where HOSessTTS_dtmBusinessDate >= @from
and HOSessTTS_dtmBusinessDate < @to





/* test lệch OCC% report GSC 
-- select Session_dtmBusinessDate,sum(Session_intQuantitySold) ,sum(Session_curTotalNet) from tblSessionPerformance
-- where year(Session_dtmBusinessDate) = 2024 and month(Session_dtmBusinessDate) = 3
-- and CinOperator_strCode = '0000000017'
-- group by  Session_dtmBusinessDate
-- 


-- HO

declare @from datetime , @to datetime 
set @from = cast(cast(getdate()-1 as date) as datetime)
set @to = cast(cast(getdate() as date) as datetime)

select a.CinOperator_strCode,sum(Performance_intTotalAdmits) adm, sum(Performance_intSessionSeats) sessionSeats, sum(Performance_curBoxNet)*1000 net_bo, sum(Performance_intTotalAdmits)*1.0*100/ sum(Performance_intSessionSeats) as occ
from tblHODailyPerformance a 
join tblCinema_Operator b on a.CinOperator_strCode = b.CinOperator_strCode
where Performance_dtmBusinessDate >= @from
and Performance_dtmBusinessDate < @to
group by a.CinOperator_strCode

union all 

select sum(HOSessTTS_intQuantityOfAdmits) adm, sum(HOSessTTS_curNetSalesValue)*1000 as net_bo
from [tblHOSessionSummaryTT] 
where HOSessTTS_dtmBusinessDate >= @from
and HOSessTTS_dtmBusinessDate < @to



declare @from datetime , @to datetime 
set @from = cast(cast(getdate()-1 as date) as datetime)
set @to = cast(cast(getdate() as date) as datetime)

select Film_strTitle,sum(HOSessTTS_intQuantityOfAdmits) adm, sum(HOSessTTS_curNetSalesValue)*1000 as net_bo, sum(Screen_intSeats)
from [tblHOSessionSummaryTT] 
where HOSessTTS_dtmBusinessDate >= @from
and HOSessTTS_dtmBusinessDate < @to
group by Film_strTitle




declare @from datetime , @to datetime 
set @from = cast(cast(getdate()-1 as date) as datetime)
set @to = cast(cast(getdate() as date) as datetime)

select 
CinOperator_strCode,sum(HOSessTTS_intQuantityOfAdmits) adm, sum(HOSessTTS_curNetSalesValue)*1000 as net_bo,sum(screenSeat) screenSeat, round(sum(HOSessTTS_intQuantityOfAdmits)*100.0/sum(screenSeat),2) OCC
from 
(
select 
case when rn = 1 then Screen_intSeats else 0 end screenSeat, *
from 
(
select ROW_NUMBER() over (partition by Session_lngSessionId order by Session_lngSessionId asc ) rn,*
from [tblHOSessionSummaryTT] 
where HOSessTTS_dtmBusinessDate >= @from
and HOSessTTS_dtmBusinessDate < @to
--and CinOperator_strCode  ='0000000001'
) A 
) B
group by CinOperator_strCode
order by CinOperator_strCode asc 
*/