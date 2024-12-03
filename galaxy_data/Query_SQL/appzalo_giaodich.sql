-- BO

-- Theo loại doanh thu: BO, Concession, F&B ưu đãi VAT, F&B không ưu đãi VAT, Phụ thu lễ 10K, Phụ thu LAGOM-LAURUS

DECLARE @fromDate datetime, @toDate datetime 
SET @fromDate = '2024-04-22 06:00:00'
SET @toDate = '2024-05-01 06:00:00'

select 
A.Cinema,
cast(A.Transaction_date as date) Transaction_date,
sum(A.Admits_BO) as Admits_BO,
sum(A.BO_Gross) as BO_Gross
from 
(
SELECT 
CinOperator_strHOOperatorCode Cinema,
CASE 
		WHEN DATEPART(HOUR, T.TransT_dtmDateTime) >= 0 AND DATEPART(HOUR, T.TransT_dtmDateTime) < 6 
				THEN DATEADD(DAY, -1, CAST(T.TransT_dtmDateTime AS DATE))
		ELSE T.TransT_dtmDateTime END AS Transaction_date,
sum(T.TransT_intNoOfSeats) as Admits_BO,
SUM(TransT_intNoOfSeats * (CASE WHEN T.TransT_curRedempValueEach <> 0 THEN T.TransT_curRedempValueEach ELSE T.TransT_curValueEach END)) BO_Gross
-- sum (
--  ISNULL( ( CASE WHEN T.TransT_curRedempValueEach = 0 THEN TransT_intNoOfSeats * ( TransT_curValueEach - TransT_curTaxAmount -
-- 	ISNULL(TransT_curTaxAmount2,0) - ISNULL(TransT_curTaxAmount3,0) - ISNULL(TransT_curTaxAmount4,0) ) ELSE 0 END ), 0 ) 
-- 	+
--  ISNULL( ( CASE WHEN T.TransT_curRedempValueEach = 0 THEN 0 ELSE T.TransT_intNoOfSeats * ( TransT_curRedempValueEach - TransT_curRedempTaxEach -
-- 	ISNULL(TransT_curRedempTaxEach2,0) - ISNULL(TransT_curRedempTaxEach3,0) - ISNULL(TransT_curRedempTaxEach4,0) ) END ), 0 )
--  ) as BO_Net
FROM   tblSession S
INNER JOIN tblScreen_Layout sl ON S.ScreenL_intId = sl.ScreenL_intId
INNER JOIN tblCinema_Screen cs ON sl.Screen_bytNum = cs.Screen_bytNum AND sl.Cinema_strCode = cs.Cinema_strCode
LEFT JOIN tblTrans_Ticket T ON T.Session_lngSessionId = S.Session_lngSessionId
INNER JOIN (select distinct TransC_lgnNumber from tblTrans_Cash where TransC_strBKCardNo = '222222......2222') TC ON TC.TransC_lgnNumber = T.TransT_lgnNumber
INNER JOIN tblCinema_Operator Cin ON Cin.CinOperator_strCode = T.CinOperator_strCode
LEFT JOIN tblPrice P ON T.PGroup_strCode = P.PGroup_strCode AND T.Price_strCode = P.Price_strCode
WHERE  T.TransT_dtmDateTime >= @fromDate AND  T.TransT_dtmDateTime < @toDate
group by CinOperator_strHOOperatorCode, T.TransT_dtmDateTime
) A 
group by A.Cinema, cast(A.Transaction_date as date)
order by A.Cinema, cast(A.Transaction_date as date)

-- CO 

-- Theo loại doanh thu: BO, Concession, F&B ưu đãi VAT, F&B không ưu đãi VAT, Phụ thu lễ 10K, Phụ thu LAGOM-LAURUS

DECLARE @fromDate datetime, @toDate datetime 
SET @fromDate = '2024-04-22 06:00:00'
SET @toDate = '2024-05-01 06:00:00'

select 
A.Cinema,
cast(A.Transaction_date as date) Transaction_date,
sum(A.Admits_CO) as Admits_CO,
sum(A.CO_Gross) as CO_Gross
from 
(
SELECT
CinOperator_strHOOperatorCode Cinema,
CASE 
		WHEN DATEPART(HOUR, I.TransI_dtmDateTime) >= 0 AND DATEPART(HOUR, I.TransI_dtmDateTime) < 6 
				THEN DATEADD(DAY, -1, CAST(I.TransI_dtmDateTime AS DATE))
		ELSE I.TransI_dtmDateTime END AS Transaction_date,
sum(TransI_decNoOfItems) as Admits_CO,
sum(Round((TransI_decNoOfItems * TransI_curValueEach),6)) CO_Gross
-- sum(Case Item_curSaleUOMConv WHEN 0 THEN
-- 		(Round((TransI_decNoOfItems * TransI_curValueEach)             ,6) - 
-- 		(  Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach,0))  ,6)+ 
-- 			 Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach2,0)) ,6)+
-- 			 Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach3,0)) ,6)+ 
-- 			 Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach4,0)) ,6) 	
-- 		))
-- 				ELSE
-- 		(Round((TransI_decNoOfItems * TransI_curValueEach)             ,6) - 
-- 		(  Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach,0))  ,6)+ 
-- 			 Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach2,0)) ,6)+
-- 			 Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach3,0)) ,6)+ 
-- 			 Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach4,0)) ,6) 	
-- 		))
-- 	END) AS CO_Net
FROM tblTrans_Inventory I WITH(INDEX(indTransI_Type_DateTime)), tblItem T, tblCinema_Operator Cin 	
,(select distinct TransC_lgnNumber from tblTrans_Cash where TransC_strBKCardNo = '222222......2222') TC
WHERE I.Item_strItemId = T.Item_strItemId 
AND TC.TransC_lgnNumber = I.TransI_lgnNumber
AND Cin.CinOperator_strCode = I.CinOperator_strCode	
AND I.TransI_strType = 'S'
AND I.TransI_strStatus <> 'W'
-- AND T.Item_strReport <> 'Y'
AND I.TransI_dtmDateTime >= @fromDate
AND I.TransI_dtmDateTime < @toDate
group by CinOperator_strHOOperatorCode, I.TransI_dtmDateTime
) A 
group by A.Cinema, cast(A.Transaction_date as date)
order by A.Cinema, cast(A.Transaction_date as date)

-- PHUTHUPHONGVIP

-- Theo loại doanh thu: BO, Concession, F&B ưu đãi VAT, F&B không ưu đãi VAT, Phụ thu lễ 10K, Phụ thu LAGOM-LAURUS

DECLARE @fromDate datetime, @toDate datetime 
SET @fromDate = '2024-04-22 06:00:00'
SET @toDate = '2024-05-01 06:00:00'


select 
A.Cinema,
cast(A.Transaction_date as date) Transaction_date,
sum(A.Admits_CO) as Admits_CO,
sum(A.CO_Gross) as CO_Gross
from 
(
SELECT
CinOperator_strHOOperatorCode Cinema,
CASE 
		WHEN DATEPART(HOUR, I.TransI_dtmDateTime) >= 0 AND DATEPART(HOUR, I.TransI_dtmDateTime) < 6 
				THEN DATEADD(DAY, -1, CAST(I.TransI_dtmDateTime AS DATE))
		ELSE I.TransI_dtmDateTime END AS Transaction_date,
sum(TransI_decNoOfItems) as Admits_CO,
sum(Round((TransI_decNoOfItems * TransI_curValueEach),6)) CO_Gross
-- sum(Case Item_curSaleUOMConv WHEN 0 THEN
-- 		(Round((TransI_decNoOfItems * TransI_curValueEach)             ,6) - 
-- 		(  Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach,0))  ,6)+ 
-- 			 Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach2,0)) ,6)+
-- 			 Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach3,0)) ,6)+ 
-- 			 Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach4,0)) ,6) 	
-- 		))
-- 				ELSE
-- 		(Round((TransI_decNoOfItems * TransI_curValueEach)             ,6) - 
-- 		(  Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach,0))  ,6)+ 
-- 			 Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach2,0)) ,6)+
-- 			 Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach3,0)) ,6)+ 
-- 			 Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach4,0)) ,6) 	
-- 		))
-- 	END) AS CO_Net
FROM tblTrans_Inventory I WITH(INDEX(indTransI_Type_DateTime)), tblItem T, tblCinema_Operator Cin 	
,(select distinct TransC_lgnNumber from tblTrans_Cash where TransC_strBKCardNo = '222222......2222') TC
WHERE I.Item_strItemId = T.Item_strItemId 
AND TC.TransC_lgnNumber = I.TransI_lgnNumber
AND Cin.CinOperator_strCode = I.CinOperator_strCode	
AND I.TransI_strType = 'S'
AND I.TransI_strStatus <> 'W'
AND T.Item_strMasterItemCode in ('HOPHUTHU105KLL')
-- AND T.Item_strReport <> 'Y'
AND I.TransI_dtmDateTime >= @fromDate
AND I.TransI_dtmDateTime < @toDate
group by CinOperator_strHOOperatorCode, I.TransI_dtmDateTime
) A 
group by A.Cinema, cast(A.Transaction_date as date)

-- PHUTHULE

-- Theo loại doanh thu: BO, Concession, F&B ưu đãi VAT, F&B không ưu đãi VAT, Phụ thu lễ 10K, Phụ thu LAGOM-LAURUS

DECLARE @fromDate datetime, @toDate datetime 
SET @fromDate = '2024-04-22 06:00:00'
SET @toDate = '2024-05-01 06:00:00'


select 
A.Cinema,
cast(A.Transaction_date as date) Transaction_date,
sum(A.Admits_CO) as Admits_CO,
sum(A.CO_Gross) as CO_Gross
from 
(
SELECT
CinOperator_strHOOperatorCode Cinema,
CASE 
		WHEN DATEPART(HOUR, I.TransI_dtmDateTime) >= 0 AND DATEPART(HOUR, I.TransI_dtmDateTime) < 6 
				THEN DATEADD(DAY, -1, CAST(I.TransI_dtmDateTime AS DATE))
		ELSE I.TransI_dtmDateTime END AS Transaction_date,
sum(TransI_decNoOfItems) as Admits_CO,
sum(Round((TransI_decNoOfItems * TransI_curValueEach),6)) CO_Gross
-- sum(Case Item_curSaleUOMConv WHEN 0 THEN
-- 		(Round((TransI_decNoOfItems * TransI_curValueEach)             ,6) - 
-- 		(  Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach,0))  ,6)+ 
-- 			 Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach2,0)) ,6)+
-- 			 Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach3,0)) ,6)+ 
-- 			 Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach4,0)) ,6) 	
-- 		))
-- 				ELSE
-- 		(Round((TransI_decNoOfItems * TransI_curValueEach)             ,6) - 
-- 		(  Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach,0))  ,6)+ 
-- 			 Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach2,0)) ,6)+
-- 			 Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach3,0)) ,6)+ 
-- 			 Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach4,0)) ,6) 	
-- 		))
-- 	END) AS CO_Net
FROM tblTrans_Inventory I WITH(INDEX(indTransI_Type_DateTime)), tblItem T, tblCinema_Operator Cin 	
,(select distinct TransC_lgnNumber from tblTrans_Cash where TransC_strBKCardNo = '222222......2222') TC
WHERE I.Item_strItemId = T.Item_strItemId 
AND TC.TransC_lgnNumber = I.TransI_lgnNumber
AND Cin.CinOperator_strCode = I.CinOperator_strCode	
AND I.TransI_strType = 'S'
AND I.TransI_strStatus <> 'W'
AND T.Item_strMasterItemCode in ('HOPHUTHULE')
-- AND T.Item_strReport <> 'Y'
AND I.TransI_dtmDateTime >= @fromDate
AND I.TransI_dtmDateTime < @toDate
group by CinOperator_strHOOperatorCode, I.TransI_dtmDateTime
) A 
group by A.Cinema, cast(A.Transaction_date as date)


-- F&B ko uu dai VAT

-- Theo loại doanh thu: BO, Concession, F&B ưu đãi VAT, F&B không ưu đãi VAT, Phụ thu lễ 10K, Phụ thu LAGOM-LAURUS

DECLARE @fromDate datetime, @toDate datetime 
SET @fromDate = '2024-04-22 06:00:00'
SET @toDate = '2024-05-01 06:00:00'


select 
A.Cinema,
cast(A.Transaction_date as date) Transaction_date,
sum(A.Admits_CO) as Admits_CO,
sum(A.CO_Gross) as CO_Gross
from 
(
SELECT
CinOperator_strHOOperatorCode Cinema,
CASE 
		WHEN DATEPART(HOUR, I.TransI_dtmDateTime) >= 0 AND DATEPART(HOUR, I.TransI_dtmDateTime) < 6 
				THEN DATEADD(DAY, -1, CAST(I.TransI_dtmDateTime AS DATE))
		ELSE I.TransI_dtmDateTime END AS Transaction_date,
sum(TransI_decNoOfItems) as Admits_CO,
sum(Round((TransI_decNoOfItems * TransI_curValueEach),6)) CO_Gross
-- sum(Case Item_curSaleUOMConv WHEN 0 THEN
-- 		(Round((TransI_decNoOfItems * TransI_curValueEach)             ,6) - 
-- 		(  Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach,0))  ,6)+ 
-- 			 Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach2,0)) ,6)+
-- 			 Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach3,0)) ,6)+ 
-- 			 Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach4,0)) ,6) 	
-- 		))
-- 				ELSE
-- 		(Round((TransI_decNoOfItems * TransI_curValueEach)             ,6) - 
-- 		(  Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach,0))  ,6)+ 
-- 			 Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach2,0)) ,6)+
-- 			 Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach3,0)) ,6)+ 
-- 			 Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach4,0)) ,6) 	
-- 		))
-- 	END) AS CO_Net
FROM tblTrans_Inventory I WITH(INDEX(indTransI_Type_DateTime)), tblItem T, tblCinema_Operator Cin, tblSalesTax ST
,(select distinct TransC_lgnNumber from tblTrans_Cash where TransC_strBKCardNo = '222222......2222') TC
WHERE I.Item_strItemId = T.Item_strItemId 
AND TC.TransC_lgnNumber = I.TransI_lgnNumber
AND Cin.CinOperator_strCode = I.CinOperator_strCode	
AND I.TransI_strType = 'S'
AND T.STax_strCode = ST.STax_strCode
AND I.TransI_strStatus <> 'W'
AND T.Location_strCode = '0003' -- Dungpa 26/12/2023
AND ST.HOPK  = '0000000006'
and T.Item_strMasterItemCode <> 'HOGOISIEUVIETGP'
AND I.TransI_dtmDateTime >= @fromDate
AND I.TransI_dtmDateTime < @toDate
group by CinOperator_strHOOperatorCode, I.TransI_dtmDateTime
) A 
group by A.Cinema, cast(A.Transaction_date as date)

-- F&B uu dai VAT

-- Theo loại doanh thu: BO, Concession, F&B ưu đãi VAT, F&B không ưu đãi VAT, Phụ thu lễ 10K, Phụ thu LAGOM-LAURUS

DECLARE @fromDate datetime, @toDate datetime 
SET @fromDate = '2024-04-22 06:00:00'
SET @toDate = '2024-05-01 06:00:00'


select 
A.Cinema,
cast(A.Transaction_date as date) Transaction_date,
sum(A.Admits_CO) as Admits_CO,
sum(A.CO_Gross) as CO_Gross
from 
(
SELECT
CinOperator_strHOOperatorCode Cinema,
CASE 
		WHEN DATEPART(HOUR, I.TransI_dtmDateTime) >= 0 AND DATEPART(HOUR, I.TransI_dtmDateTime) < 6 
				THEN DATEADD(DAY, -1, CAST(I.TransI_dtmDateTime AS DATE))
		ELSE I.TransI_dtmDateTime END AS Transaction_date,
sum(TransI_decNoOfItems) as Admits_CO,
sum(Round((TransI_decNoOfItems * TransI_curValueEach),6)) CO_Gross
-- sum(Case Item_curSaleUOMConv WHEN 0 THEN
-- 		(Round((TransI_decNoOfItems * TransI_curValueEach)             ,6) - 
-- 		(  Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach,0))  ,6)+ 
-- 			 Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach2,0)) ,6)+
-- 			 Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach3,0)) ,6)+ 
-- 			 Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach4,0)) ,6) 	
-- 		))
-- 				ELSE
-- 		(Round((TransI_decNoOfItems * TransI_curValueEach)             ,6) - 
-- 		(  Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach,0))  ,6)+ 
-- 			 Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach2,0)) ,6)+
-- 			 Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach3,0)) ,6)+ 
-- 			 Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach4,0)) ,6) 	
-- 		))
-- 	END) AS CO_Net
FROM tblTrans_Inventory I WITH(INDEX(indTransI_Type_DateTime)), tblItem T, tblCinema_Operator Cin, tblSalesTax ST
,(select distinct TransC_lgnNumber from tblTrans_Cash where TransC_strBKCardNo = '222222......2222') TC
WHERE I.Item_strItemId = T.Item_strItemId 
AND TC.TransC_lgnNumber = I.TransI_lgnNumber
AND Cin.CinOperator_strCode = I.CinOperator_strCode	
AND I.TransI_strType = 'S'
AND T.STax_strCode = ST.STax_strCode
AND I.TransI_strStatus <> 'W'
AND T.Location_strCode = '0003' -- Dungpa 26/12/2023
AND ST.HOPK  <> '0000000006'
and T.Item_strMasterItemCode <> 'HOGOISIEUVIETGP'
AND I.TransI_dtmDateTime >= @fromDate
AND I.TransI_dtmDateTime < @toDate
group by CinOperator_strHOOperatorCode, I.TransI_dtmDateTime
) A 
group by A.Cinema, cast(A.Transaction_date as date)



--Query check giao dịch

--HO Total

select CinOperator_strHOOperatorCode,HOBank_dtmBusinessDate, sum(HOBank_curAmount) amt from tblHOBanking a 
join tblCinema_Operator b on a.CinOperator_strCode = b.CinOperator_strCode
where HOBank_dtmBusinessDate >= '2024-04-22' and HOBank_dtmBusinessDate < '2024-05-01'
and Card_strCardType = 'APPZALO'
group by HOBank_dtmBusinessDate,CinOperator_strHOOperatorCode,b.CinOperator_strCode
order by b.CinOperator_strCode,HOBank_dtmBusinessDate

-- HO Detail 

select a.*
from tblHOBanking a 
join tblCinema_Operator b on a.CinOperator_strCode = b.CinOperator_strCode
where HOBank_dtmBusinessDate >= '2024-04-28' and HOBank_dtmBusinessDate < '2024-04-29'
and Card_strCardType = 'APPZALO'
and CinOperator_strHOOperatorCode = 'KDV'

-- Site Detail

DECLARE @fromDate datetime, @toDate datetime 
SET @fromDate = '2024-04-28 06:00:00'
SET @toDate = '2024-04-29 06:00:00'

			
select 
TransID,	sum(BO_Gross) bo,	sum(CO_Gross) co,sum(BO_Gross) + sum(CO_Gross) total
from 
(
select 
T.TransT_lgnNumber TransID,
SUM(TransT_intNoOfSeats * (CASE WHEN T.TransT_curRedempValueEach <> 0 THEN T.TransT_curRedempValueEach ELSE T.TransT_curValueEach END)) BO_Gross,
0 as CO_Gross
-- sum (
--  ISNULL( ( CASE WHEN T.TransT_curRedempValueEach = 0 THEN TransT_intNoOfSeats * ( TransT_curValueEach - TransT_curTaxAmount -
-- 	ISNULL(TransT_curTaxAmount2,0) - ISNULL(TransT_curTaxAmount3,0) - ISNULL(TransT_curTaxAmount4,0) ) ELSE 0 END ), 0 ) 
-- 	+
--  ISNULL( ( CASE WHEN T.TransT_curRedempValueEach = 0 THEN 0 ELSE T.TransT_intNoOfSeats * ( TransT_curRedempValueEach - TransT_curRedempTaxEach -
-- 	ISNULL(TransT_curRedempTaxEach2,0) - ISNULL(TransT_curRedempTaxEach3,0) - ISNULL(TransT_curRedempTaxEach4,0) ) END ), 0 )
--  ) as BO_Net
FROM   tblSession S
INNER JOIN tblScreen_Layout sl ON S.ScreenL_intId = sl.ScreenL_intId
INNER JOIN tblCinema_Screen cs ON sl.Screen_bytNum = cs.Screen_bytNum AND sl.Cinema_strCode = cs.Cinema_strCode
LEFT JOIN tblTrans_Ticket T ON T.Session_lngSessionId = S.Session_lngSessionId
INNER JOIN (select distinct TransC_lgnNumber from tblTrans_Cash where TransC_strBKCardNo = '222222......2222') TC ON TC.TransC_lgnNumber = T.TransT_lgnNumber
INNER JOIN tblCinema_Operator Cin ON Cin.CinOperator_strCode = T.CinOperator_strCode
LEFT JOIN tblPrice P ON T.PGroup_strCode = P.PGroup_strCode AND T.Price_strCode = P.Price_strCode
WHERE  T.TransT_dtmDateTime >= @fromDate AND  T.TransT_dtmDateTime < @toDate
group by TransT_lgnNumber

union all 

select 
I.TransI_lgnNumber TransID,
0 as BO_Gross,
sum(Round((TransI_decNoOfItems * TransI_curValueEach),6)) CO_Gross
FROM tblTrans_Inventory I WITH(INDEX(indTransI_Type_DateTime)), tblItem T, tblCinema_Operator Cin 	
,(select distinct TransC_lgnNumber from tblTrans_Cash where TransC_strBKCardNo = '222222......2222') TC
WHERE I.Item_strItemId = T.Item_strItemId 
AND TC.TransC_lgnNumber = I.TransI_lgnNumber
AND Cin.CinOperator_strCode = I.CinOperator_strCode	
AND I.TransI_strType = 'S'
AND I.TransI_strStatus <> 'W'
AND I.TransI_dtmDateTime >= @fromDate
AND I.TransI_dtmDateTime < @toDate
group by I.TransI_lgnNumber
) A
group by TransID

-- Transaction Cụ thể
select top 100 * from tblTrans_Cash
where TransC_lgnNumber = 7076734


select top 100 * from tblTrans_Ticket
where TransT_lgnNumber = 7076734
and TransT_strStatus = 'V'

select top 100 * from tblTrans_Inventory
where TransI_lgnNumber = 7076734


-- check theo payment ref

/*
ND
2405010010277899225
2405010013399229098
2405010019211278120
TB
2405010002344421458
HTP
2404302356544800846
TC
2405010031188794225
BMT
2405010036322274828
DN
2405010023044155407
CM
2405010014199774917
*/


DECLARE @fromDate datetime, @toDate datetime 
SET @fromDate = '2024-04-22 06:00:00'
SET @toDate = '2024-05-02 06:00:00'

			
select 
TransID,	
TranRealDatetime,
TransC_strPaymentTransRef,
sum(BO_Gross) bo,	
(sum(CO_Gross)  - sum(CO_Gross_PTL) - sum(CO_Gross_FnB_uudai) - sum(CO_Gross_FnB_kouudai) - sum(CO_phuthuvip)) co, 
sum(CO_Gross_PTL) co_ptl, 
sum(CO_Gross_FnB_uudai) CO_Gross_FnB_uudai, 
sum(CO_Gross_FnB_kouudai) CO_Gross_FnB_kouudai ,
sum(CO_phuthuvip) CO_phuthuvip,
(sum(BO_Gross) + sum(CO_Gross)) total
from 
(
select 
T.TransT_lgnNumber TransID,
T.TransT_dtmRealTransTime TranRealDatetime,
TransC_strPaymentTransRef,
SUM(TransT_intNoOfSeats * (CASE WHEN T.TransT_curRedempValueEach <> 0 THEN T.TransT_curRedempValueEach ELSE T.TransT_curValueEach END)) BO_Gross,
0 as CO_Gross,
0 as CO_Gross_PTL,
0 as CO_Gross_FnB_uudai,
0 as CO_Gross_FnB_kouudai,
0 as CO_phuthuvip
FROM   tblSession S
INNER JOIN tblScreen_Layout sl ON S.ScreenL_intId = sl.ScreenL_intId
INNER JOIN tblCinema_Screen cs ON sl.Screen_bytNum = cs.Screen_bytNum AND sl.Cinema_strCode = cs.Cinema_strCode
LEFT JOIN tblTrans_Ticket T ON T.Session_lngSessionId = S.Session_lngSessionId
INNER JOIN (select distinct TransC_strPaymentTransRef,TransC_lgnNumber from tblTrans_Cash where TransC_strBKCardNo = '222222......2222' and TransC_strPaymentTransRef in (
'2406012148233373695'
)) TC ON TC.TransC_lgnNumber = T.TransT_lgnNumber
INNER JOIN tblCinema_Operator Cin ON Cin.CinOperator_strCode = T.CinOperator_strCode
LEFT JOIN tblPrice P ON T.PGroup_strCode = P.PGroup_strCode AND T.Price_strCode = P.Price_strCode
WHERE  T.TransT_dtmDateTime >= @fromDate AND  T.TransT_dtmDateTime < @toDate
group by TransT_lgnNumber, T.TransT_dtmRealTransTime, TransC_strPaymentTransRef

union all 

select 
I.TransI_lgnNumber TransID,
I.TransI_dtmRealTransTime TranRealDatetime,
TransC_strPaymentTransRef,
0 as BO_Gross,
sum(Round((TransI_decNoOfItems * TransI_curValueEach),6)) CO_Gross,
0 as CO_Gross_PTL,
0 as CO_Gross_FnB_uudai,
0 as CO_Gross_FnB_kouudai,
0 as CO_phuthuvip
FROM tblTrans_Inventory I WITH(INDEX(indTransI_Type_DateTime)), tblItem T, tblCinema_Operator Cin 	
,(select distinct TransC_strPaymentTransRef,TransC_lgnNumber from tblTrans_Cash where TransC_strBKCardNo = '222222......2222' and TransC_strPaymentTransRef in (
'2406012148233373695'
)) TC
WHERE I.Item_strItemId = T.Item_strItemId 
AND TC.TransC_lgnNumber = I.TransI_lgnNumber
AND Cin.CinOperator_strCode = I.CinOperator_strCode	
AND I.TransI_strType = 'S'
AND I.TransI_strStatus <> 'W'
AND I.TransI_dtmDateTime >= @fromDate
AND I.TransI_dtmDateTime < @toDate
group by I.TransI_lgnNumber, I.TransI_dtmRealTransTime, TransC_strPaymentTransRef

union all 

select 
I.TransI_lgnNumber TransID,
I.TransI_dtmRealTransTime TranRealDatetime,
TransC_strPaymentTransRef,
0 as BO_Gross,
0 as CO_Gross,
sum(Round((TransI_decNoOfItems * TransI_curValueEach),6)) CO_Gross_PTL,
0 as CO_Gross_FnB_uudai,
0 as CO_Gross_FnB_kouudai,
0 as CO_phuthuvip
FROM tblTrans_Inventory I WITH(INDEX(indTransI_Type_DateTime)), tblItem T, tblCinema_Operator Cin 	
,(select distinct TransC_strPaymentTransRef,TransC_lgnNumber from tblTrans_Cash where TransC_strBKCardNo = '222222......2222' and TransC_strPaymentTransRef in (
'2406012148233373695'
)) TC
WHERE I.Item_strItemId = T.Item_strItemId 
AND TC.TransC_lgnNumber = I.TransI_lgnNumber
AND Cin.CinOperator_strCode = I.CinOperator_strCode	
AND I.TransI_strType = 'S'
AND I.TransI_strStatus <> 'W'
AND T.Item_strMasterItemCode in ('HOPHUTHULE')
-- AND T.Item_strReport <> 'Y'
AND I.TransI_dtmDateTime >= @fromDate
AND I.TransI_dtmDateTime < @toDate
group by I.TransI_lgnNumber, I.TransI_dtmRealTransTime, TransC_strPaymentTransRef

union all 

select 
I.TransI_lgnNumber TransID,
I.TransI_dtmRealTransTime TranRealDatetime,
TransC_strPaymentTransRef,
0 as BO_Gross,
0 as CO_Gross,
0 as CO_Gross_PTL,
sum(Round((TransI_decNoOfItems * TransI_curValueEach),6)) CO_Gross_FnB_uudai,
0 as CO_Gross_FnB_kouudai,
0 as CO_phuthuvip
FROM tblTrans_Inventory I WITH(INDEX(indTransI_Type_DateTime)), tblItem T, tblCinema_Operator Cin, tblSalesTax ST
,(select distinct TransC_strPaymentTransRef,TransC_lgnNumber from tblTrans_Cash where TransC_strBKCardNo = '222222......2222' and TransC_strPaymentTransRef in (
'2406012148233373695'
)) TC
WHERE I.Item_strItemId = T.Item_strItemId 
AND TC.TransC_lgnNumber = I.TransI_lgnNumber
AND Cin.CinOperator_strCode = I.CinOperator_strCode	
AND I.TransI_strType = 'S'
AND T.STax_strCode = ST.STax_strCode
AND I.TransI_strStatus <> 'W'
AND T.Location_strCode = '0003' -- Dungpa 26/12/2023
AND ST.HOPK  = '0000000006'
and T.Item_strMasterItemCode <> 'HOGOISIEUVIETGP'
AND I.TransI_dtmDateTime >= @fromDate
AND I.TransI_dtmDateTime < @toDate
group by I.TransI_lgnNumber,I.TransI_dtmRealTransTime, TransC_strPaymentTransRef

union all 

select 
I.TransI_lgnNumber TransID,
I.TransI_dtmRealTransTime TranRealDatetime,
TransC_strPaymentTransRef,
0 as BO_Gross,
0 as CO_Gross,
0 as CO_Gross_PTL,
0 as CO_Gross_FnB_uudai,
sum(Round((TransI_decNoOfItems * TransI_curValueEach),6)) CO_Gross_FnB_kouudai,
0 as CO_phuthuvip
FROM tblTrans_Inventory I WITH(INDEX(indTransI_Type_DateTime)), tblItem T, tblCinema_Operator Cin, tblSalesTax ST
,(select distinct TransC_strPaymentTransRef,TransC_lgnNumber from tblTrans_Cash where TransC_strBKCardNo = '222222......2222' and TransC_strPaymentTransRef in (
'2406012148233373695'
)) TC
WHERE I.Item_strItemId = T.Item_strItemId 
AND TC.TransC_lgnNumber = I.TransI_lgnNumber
AND Cin.CinOperator_strCode = I.CinOperator_strCode	
AND I.TransI_strType = 'S'
AND T.STax_strCode = ST.STax_strCode
AND I.TransI_strStatus <> 'W'
AND T.Location_strCode = '0003' -- Dungpa 26/12/2023
AND ST.HOPK  <> '0000000006'
and T.Item_strMasterItemCode <> 'HOGOISIEUVIETGP'
AND I.TransI_dtmDateTime >= @fromDate
AND I.TransI_dtmDateTime < @toDate
group by I.TransI_lgnNumber,I.TransI_dtmRealTransTime, TransC_strPaymentTransRef

union all 

select 
I.TransI_lgnNumber TransID,
I.TransI_dtmRealTransTime TranRealDatetime,
TransC_strPaymentTransRef,
0 as BO_Gross,
0 as CO_Gross,
0 as CO_Gross_PTL,
0 as CO_Gross_FnB_uudai,
0 as CO_Gross_FnB_kouudai,
sum(Round((TransI_decNoOfItems * TransI_curValueEach),6)) CO_phuthuvip
FROM tblTrans_Inventory I WITH(INDEX(indTransI_Type_DateTime)), tblItem T, tblCinema_Operator Cin 	
,(select distinct TransC_strPaymentTransRef,TransC_lgnNumber from tblTrans_Cash where TransC_strBKCardNo = '222222......2222' and TransC_strPaymentTransRef in (
'2406012148233373695'
)) TC
WHERE I.Item_strItemId = T.Item_strItemId 
AND TC.TransC_lgnNumber = I.TransI_lgnNumber
AND Cin.CinOperator_strCode = I.CinOperator_strCode	
AND I.TransI_strType = 'S'
AND I.TransI_strStatus <> 'W'
AND T.Item_strMasterItemCode in ('HOPHUTHU105KLL')
-- AND T.Item_strReport <> 'Y'
AND I.TransI_dtmDateTime >= @fromDate
AND I.TransI_dtmDateTime < @toDate
group by I.TransI_lgnNumber,I.TransI_dtmRealTransTime, TransC_strPaymentTransRef
) A
group by TransID,TranRealDatetime, TransC_strPaymentTransRef

-- Query 1 for all 

DECLARE @fromDate datetime, @toDate datetime 
SET @fromDate = '2024-05-06 06:00:00'
SET @toDate = '2024-05-13 06:00:00'

select 
A.Cinema,
cast(A.Transaction_date as date) Transaction_date,
sum(A.Admits_BO) as Admits_BO,
sum(A.BO_Gross) as BO_Gross,

sum(A.Admits_CO) - sum(A.Admits_CO_PTL) - sum(A.Admits_CO_PTVIP) - sum(A.Admits_CO_FnB_uudai) - sum(A.Admits_CO_FnB_kouudai) as Admits_CO,
sum(A.CO_Gross) - sum(A.CO_Gross_PTL) - sum(A.CO_Gross_PTVIP) - sum(A.CO_Gross_FnB_uudai) - sum(A.CO_Gross_FnB_kouudai) as CO_Gross,

sum(A.Admits_CO_PTL) as Admits_CO_PTL,
sum(A.CO_Gross_PTL) as CO_Gross_PTL,

sum(A.Admits_CO_PTVIP) as Admits_CO_PTVIP,
sum(A.CO_Gross_PTVIP) as CO_Gross_PTVIP,

sum(A.Admits_CO_FnB_uudai) as Admits_CO_FnB_uudai,
sum(A.CO_Gross_FnB_uudai) as CO_Gross_FnB_uudai,

sum(A.Admits_CO_FnB_kouudai) as Admits_CO_FnB_kouudai,
sum(A.CO_Gross_FnB_kouudai) as CO_Gross_FnB_kouudai
from 
(
SELECT 
CinOperator_strHOOperatorCode Cinema,
CASE 
		WHEN DATEPART(HOUR, T.TransT_dtmDateTime) >= 0 AND DATEPART(HOUR, T.TransT_dtmDateTime) < 6 
				THEN DATEADD(DAY, -1, CAST(T.TransT_dtmDateTime AS DATE))
		ELSE T.TransT_dtmDateTime END AS Transaction_date,
sum(T.TransT_intNoOfSeats) as Admits_BO,
SUM(TransT_intNoOfSeats * (CASE WHEN T.TransT_curRedempValueEach <> 0 THEN T.TransT_curRedempValueEach ELSE T.TransT_curValueEach END)) BO_Gross,
0 as Admits_CO,
0 as CO_Gross,
0 as Admits_CO_PTL,
0 as CO_Gross_PTL,
0 as Admits_CO_PTVIP,
0 as CO_Gross_PTVIP,
0 as Admits_CO_FnB_uudai,
0 as CO_Gross_FnB_uudai,
0 as Admits_CO_FnB_kouudai,
0 as CO_Gross_FnB_kouudai
FROM   tblSession S
INNER JOIN tblScreen_Layout sl ON S.ScreenL_intId = sl.ScreenL_intId
INNER JOIN tblCinema_Screen cs ON sl.Screen_bytNum = cs.Screen_bytNum AND sl.Cinema_strCode = cs.Cinema_strCode
LEFT JOIN tblTrans_Ticket T ON T.Session_lngSessionId = S.Session_lngSessionId
INNER JOIN (select distinct TransC_lgnNumber from tblTrans_Cash where TransC_strBKCardNo = '222222......2222') TC ON TC.TransC_lgnNumber = T.TransT_lgnNumber
INNER JOIN tblCinema_Operator Cin ON Cin.CinOperator_strCode = T.CinOperator_strCode
LEFT JOIN tblPrice P ON T.PGroup_strCode = P.PGroup_strCode AND T.Price_strCode = P.Price_strCode
WHERE  T.TransT_dtmDateTime >= @fromDate AND  T.TransT_dtmDateTime < @toDate
group by CinOperator_strHOOperatorCode, T.TransT_dtmDateTime

UNION ALL 

SELECT
CinOperator_strHOOperatorCode Cinema,
CASE 
		WHEN DATEPART(HOUR, I.TransI_dtmDateTime) >= 0 AND DATEPART(HOUR, I.TransI_dtmDateTime) < 6 
				THEN DATEADD(DAY, -1, CAST(I.TransI_dtmDateTime AS DATE))
		ELSE I.TransI_dtmDateTime END AS Transaction_date,
0 as Admits_BO,
0 as BO_Gross,
sum(TransI_decNoOfItems) as Admits_CO,
sum(Round((TransI_decNoOfItems * TransI_curValueEach),6)) CO_Gross,
0 as Admits_CO_PTL,
0 as CO_Gross_PTL,
0 as Admits_CO_PTVIP,
0 as CO_Gross_PTVIP,
0 as Admits_CO_FnB_uudai,
0 as CO_Gross_FnB_uudai,
0 as Admits_CO_FnB_kouudai,
0 as CO_Gross_FnB_kouudai
FROM tblTrans_Inventory I WITH(INDEX(indTransI_Type_DateTime)), tblItem T, tblCinema_Operator Cin 	
,(select distinct TransC_lgnNumber from tblTrans_Cash where TransC_strBKCardNo = '222222......2222') TC
WHERE I.Item_strItemId = T.Item_strItemId 
AND TC.TransC_lgnNumber = I.TransI_lgnNumber
AND Cin.CinOperator_strCode = I.CinOperator_strCode	
AND I.TransI_strType = 'S'
AND I.TransI_strStatus <> 'W'
-- AND T.Item_strReport <> 'Y'
AND I.TransI_dtmDateTime >= @fromDate
AND I.TransI_dtmDateTime < @toDate
group by CinOperator_strHOOperatorCode, I.TransI_dtmDateTime

UNION ALL 

SELECT
CinOperator_strHOOperatorCode Cinema,
CASE 
		WHEN DATEPART(HOUR, I.TransI_dtmDateTime) >= 0 AND DATEPART(HOUR, I.TransI_dtmDateTime) < 6 
				THEN DATEADD(DAY, -1, CAST(I.TransI_dtmDateTime AS DATE))
		ELSE I.TransI_dtmDateTime END AS Transaction_date,
0 as Admits_BO,
0 as BO_Gross,		
0 as Admits_CO,
0 as CO_Gross,		
sum(TransI_decNoOfItems) as Admits_CO_PTL,
sum(Round((TransI_decNoOfItems * TransI_curValueEach),6)) CO_Gross_PTL,
0 as Admits_CO_PTVIP,
0 as CO_Gross_PTVIP,
0 as Admits_CO_FnB_uudai,
0 as CO_Gross_FnB_uudai,
0 as Admits_CO_FnB_kouudai,
0 as CO_Gross_FnB_kouudai
FROM tblTrans_Inventory I WITH(INDEX(indTransI_Type_DateTime)), tblItem T, tblCinema_Operator Cin 	
,(select distinct TransC_lgnNumber from tblTrans_Cash where TransC_strBKCardNo = '222222......2222') TC
WHERE I.Item_strItemId = T.Item_strItemId 
AND TC.TransC_lgnNumber = I.TransI_lgnNumber
AND Cin.CinOperator_strCode = I.CinOperator_strCode	
AND I.TransI_strType = 'S'
AND I.TransI_strStatus <> 'W'
AND T.Item_strMasterItemCode in ('HOPHUTHULE')
-- AND T.Item_strReport <> 'Y'
AND I.TransI_dtmDateTime >= @fromDate
AND I.TransI_dtmDateTime < @toDate
group by CinOperator_strHOOperatorCode, I.TransI_dtmDateTime

UNION ALL 

SELECT
CinOperator_strHOOperatorCode Cinema,
CASE 
		WHEN DATEPART(HOUR, I.TransI_dtmDateTime) >= 0 AND DATEPART(HOUR, I.TransI_dtmDateTime) < 6 
				THEN DATEADD(DAY, -1, CAST(I.TransI_dtmDateTime AS DATE))
		ELSE I.TransI_dtmDateTime END AS Transaction_date,
0 as Admits_BO,
0 as BO_Gross,		
0 as Admits_CO,
0 as CO_Gross,		
0 as Admits_CO_PTL,
0 as CO_Gross_PTL,
sum(TransI_decNoOfItems) as Admits_CO_PTVIP,
sum(Round((TransI_decNoOfItems * TransI_curValueEach),6)) CO_Gross_PTVIP,
0 as Admits_CO_FnB_uudai,
0 as CO_Gross_FnB_uudai,
0 as Admits_CO_FnB_kouudai,
0 as CO_Gross_FnB_kouudai
FROM tblTrans_Inventory I WITH(INDEX(indTransI_Type_DateTime)), tblItem T, tblCinema_Operator Cin 	
,(select distinct TransC_lgnNumber from tblTrans_Cash where TransC_strBKCardNo = '222222......2222') TC
WHERE I.Item_strItemId = T.Item_strItemId 
AND TC.TransC_lgnNumber = I.TransI_lgnNumber
AND Cin.CinOperator_strCode = I.CinOperator_strCode	
AND I.TransI_strType = 'S'
AND I.TransI_strStatus <> 'W'
AND T.Item_strMasterItemCode in ('HOPHUTHU105KLL')
-- AND T.Item_strReport <> 'Y'
AND I.TransI_dtmDateTime >= @fromDate
AND I.TransI_dtmDateTime < @toDate
group by CinOperator_strHOOperatorCode, I.TransI_dtmDateTime

UNION ALL 

SELECT
CinOperator_strHOOperatorCode Cinema,
CASE 
		WHEN DATEPART(HOUR, I.TransI_dtmDateTime) >= 0 AND DATEPART(HOUR, I.TransI_dtmDateTime) < 6 
				THEN DATEADD(DAY, -1, CAST(I.TransI_dtmDateTime AS DATE))
		ELSE I.TransI_dtmDateTime END AS Transaction_date,
0 as Admits_BO,
0 as BO_Gross,
0 as Admits_CO,
0 as CO_Gross,
0 as Admits_CO_PTL,
0 as CO_Gross_PTL,
0 as Admits_CO_PTVIP,
0 as CO_Gross_PTVIP,
sum(TransI_decNoOfItems) as Admits_CO_FnB_uudai,
sum(Round((TransI_decNoOfItems * TransI_curValueEach),6)) as CO_Gross_FnB_uudai,
0 as Admits_CO_FnB_kouudai,
0 as CO_Gross_FnB_kouudai
FROM tblTrans_Inventory I WITH(INDEX(indTransI_Type_DateTime)), tblItem T, tblCinema_Operator Cin, tblSalesTax ST
,(select distinct TransC_lgnNumber from tblTrans_Cash where TransC_strBKCardNo = '222222......2222') TC
WHERE I.Item_strItemId = T.Item_strItemId 
AND TC.TransC_lgnNumber = I.TransI_lgnNumber
AND Cin.CinOperator_strCode = I.CinOperator_strCode	
AND I.TransI_strType = 'S'
AND T.STax_strCode = ST.STax_strCode
AND I.TransI_strStatus <> 'W'
AND T.Location_strCode = '0003' -- Dungpa 26/12/2023
AND ST.HOPK  <> '0000000006'
and T.Item_strMasterItemCode <> 'HOGOISIEUVIETGP'
AND I.TransI_dtmDateTime >= @fromDate
AND I.TransI_dtmDateTime < @toDate
group by CinOperator_strHOOperatorCode, I.TransI_dtmDateTime

UNION ALL 

SELECT
CinOperator_strHOOperatorCode Cinema,
CASE 
		WHEN DATEPART(HOUR, I.TransI_dtmDateTime) >= 0 AND DATEPART(HOUR, I.TransI_dtmDateTime) < 6 
				THEN DATEADD(DAY, -1, CAST(I.TransI_dtmDateTime AS DATE))
		ELSE I.TransI_dtmDateTime END AS Transaction_date,
0 as Admits_BO,
0 as BO_Gross,
0 as Admits_CO,
0 as CO_Gross,
0 as Admits_CO_PTL,
0 as CO_Gross_PTL,
0 as Admits_CO_PTVIP,
0 as CO_Gross_PTVIP,
0 as Admits_CO_FnB_uudai,
0 as CO_Gross_FnB_uudai,
sum(TransI_decNoOfItems) as Admits_CO_FnB_kouudai,
sum(Round((TransI_decNoOfItems * TransI_curValueEach),6)) as CO_Gross_FnB_kouudai
FROM tblTrans_Inventory I WITH(INDEX(indTransI_Type_DateTime)), tblItem T, tblCinema_Operator Cin, tblSalesTax ST
,(select distinct TransC_lgnNumber from tblTrans_Cash where TransC_strBKCardNo = '222222......2222') TC
WHERE I.Item_strItemId = T.Item_strItemId 
AND TC.TransC_lgnNumber = I.TransI_lgnNumber
AND Cin.CinOperator_strCode = I.CinOperator_strCode	
AND I.TransI_strType = 'S'
AND T.STax_strCode = ST.STax_strCode
AND I.TransI_strStatus <> 'W'
AND T.Location_strCode = '0003' -- Dungpa 26/12/2023
AND ST.HOPK  = '0000000006'
and T.Item_strMasterItemCode <> 'HOGOISIEUVIETGP'
AND I.TransI_dtmDateTime >= @fromDate
AND I.TransI_dtmDateTime < @toDate
group by CinOperator_strHOOperatorCode, I.TransI_dtmDateTime

) A 
group by A.Cinema, cast(A.Transaction_date as date)
order by A.Cinema, cast(A.Transaction_date as date)


--- Query 1 for all but have detail transaction number 



-- select TransC_strPaymentTransRef from tblTrans_Cash where TransC_lgnNumber = 98080

DECLARE @fromDate datetime, @toDate datetime 
SET @fromDate = '2024-04-30 06:00:00'
SET @toDate = '2024-05-01 06:00:00'


select Trans_Number,
A.Cinema,
cast(A.Transaction_date as date) Transaction_date,
sum(A.Admits_BO) as Admits_BO,
sum(A.BO_Gross) as BO_Gross,

sum(A.Admits_CO) - sum(A.Admits_CO_PTL) - sum(A.Admits_CO_PTVIP) - sum(A.Admits_CO_FnB_uudai) - sum(A.Admits_CO_FnB_kouudai) as Admits_CO,
sum(A.CO_Gross) - sum(A.CO_Gross_PTL) - sum(A.CO_Gross_PTVIP) - sum(A.CO_Gross_FnB_uudai) - sum(A.CO_Gross_FnB_kouudai) as CO_Gross,

sum(A.Admits_CO_PTL) as Admits_CO_PTL,
sum(A.CO_Gross_PTL) as CO_Gross_PTL,

sum(A.Admits_CO_PTVIP) as Admits_CO_PTVIP,
sum(A.CO_Gross_PTVIP) as CO_Gross_PTVIP,

sum(A.Admits_CO_FnB_uudai) as Admits_CO_FnB_uudai,
sum(A.CO_Gross_FnB_uudai) as CO_Gross_FnB_uudai,

sum(A.Admits_CO_FnB_kouudai) as Admits_CO_FnB_kouudai,
sum(A.CO_Gross_FnB_kouudai) as CO_Gross_FnB_kouudai
from 
(
SELECT TC.TransC_lgnNumber Trans_Number,
CinOperator_strHOOperatorCode Cinema,
CASE 
		WHEN DATEPART(HOUR, T.TransT_dtmDateTime) >= 0 AND DATEPART(HOUR, T.TransT_dtmDateTime) < 6 
				THEN DATEADD(DAY, -1, CAST(T.TransT_dtmDateTime AS DATE))
		ELSE T.TransT_dtmDateTime END AS Transaction_date,
sum(T.TransT_intNoOfSeats) as Admits_BO,
SUM(TransT_intNoOfSeats * (CASE WHEN T.TransT_curRedempValueEach <> 0 THEN T.TransT_curRedempValueEach ELSE T.TransT_curValueEach END)) BO_Gross,
0 as Admits_CO,
0 as CO_Gross,
0 as Admits_CO_PTL,
0 as CO_Gross_PTL,
0 as Admits_CO_PTVIP,
0 as CO_Gross_PTVIP,
0 as Admits_CO_FnB_uudai,
0 as CO_Gross_FnB_uudai,
0 as Admits_CO_FnB_kouudai,
0 as CO_Gross_FnB_kouudai
FROM   tblSession S
INNER JOIN tblScreen_Layout sl ON S.ScreenL_intId = sl.ScreenL_intId
INNER JOIN tblCinema_Screen cs ON sl.Screen_bytNum = cs.Screen_bytNum AND sl.Cinema_strCode = cs.Cinema_strCode
LEFT JOIN tblTrans_Ticket T ON T.Session_lngSessionId = S.Session_lngSessionId
INNER JOIN (select distinct TransC_lgnNumber from tblTrans_Cash where TransC_strBKCardNo = '222222......2222') TC ON TC.TransC_lgnNumber = T.TransT_lgnNumber
INNER JOIN tblCinema_Operator Cin ON Cin.CinOperator_strCode = T.CinOperator_strCode
LEFT JOIN tblPrice P ON T.PGroup_strCode = P.PGroup_strCode AND T.Price_strCode = P.Price_strCode
WHERE  T.TransT_dtmDateTime >= @fromDate AND  T.TransT_dtmDateTime < @toDate
group by CinOperator_strHOOperatorCode, T.TransT_dtmDateTime, TC.TransC_lgnNumber

UNION ALL 

SELECT TC.TransC_lgnNumber Trans_Number,
CinOperator_strHOOperatorCode Cinema,
CASE 
		WHEN DATEPART(HOUR, I.TransI_dtmDateTime) >= 0 AND DATEPART(HOUR, I.TransI_dtmDateTime) < 6 
				THEN DATEADD(DAY, -1, CAST(I.TransI_dtmDateTime AS DATE))
		ELSE I.TransI_dtmDateTime END AS Transaction_date,
0 as Admits_BO,
0 as BO_Gross,
sum(TransI_decNoOfItems) as Admits_CO,
sum(Round((TransI_decNoOfItems * TransI_curValueEach),6)) CO_Gross,
0 as Admits_CO_PTL,
0 as CO_Gross_PTL,
0 as Admits_CO_PTVIP,
0 as CO_Gross_PTVIP,
0 as Admits_CO_FnB_uudai,
0 as CO_Gross_FnB_uudai,
0 as Admits_CO_FnB_kouudai,
0 as CO_Gross_FnB_kouudai
FROM tblTrans_Inventory I WITH(INDEX(indTransI_Type_DateTime)), tblItem T, tblCinema_Operator Cin 	
,(select distinct TransC_lgnNumber from tblTrans_Cash where TransC_strBKCardNo = '222222......2222') TC
WHERE I.Item_strItemId = T.Item_strItemId 
AND TC.TransC_lgnNumber = I.TransI_lgnNumber
AND Cin.CinOperator_strCode = I.CinOperator_strCode	
AND I.TransI_strType = 'S'
AND I.TransI_strStatus <> 'W'
-- AND T.Item_strReport <> 'Y'
AND I.TransI_dtmDateTime >= @fromDate
AND I.TransI_dtmDateTime < @toDate
group by CinOperator_strHOOperatorCode, I.TransI_dtmDateTime,TC.TransC_lgnNumber

UNION ALL 

SELECT TC.TransC_lgnNumber Trans_Number,
CinOperator_strHOOperatorCode Cinema,
CASE 
		WHEN DATEPART(HOUR, I.TransI_dtmDateTime) >= 0 AND DATEPART(HOUR, I.TransI_dtmDateTime) < 6 
				THEN DATEADD(DAY, -1, CAST(I.TransI_dtmDateTime AS DATE))
		ELSE I.TransI_dtmDateTime END AS Transaction_date,
0 as Admits_BO,
0 as BO_Gross,		
0 as Admits_CO,
0 as CO_Gross,		
sum(TransI_decNoOfItems) as Admits_CO_PTL,
sum(Round((TransI_decNoOfItems * TransI_curValueEach),6)) CO_Gross_PTL,
0 as Admits_CO_PTVIP,
0 as CO_Gross_PTVIP,
0 as Admits_CO_FnB_uudai,
0 as CO_Gross_FnB_uudai,
0 as Admits_CO_FnB_kouudai,
0 as CO_Gross_FnB_kouudai
FROM tblTrans_Inventory I WITH(INDEX(indTransI_Type_DateTime)), tblItem T, tblCinema_Operator Cin 	
,(select distinct TransC_lgnNumber from tblTrans_Cash where TransC_strBKCardNo = '222222......2222') TC
WHERE I.Item_strItemId = T.Item_strItemId 
AND TC.TransC_lgnNumber = I.TransI_lgnNumber
AND Cin.CinOperator_strCode = I.CinOperator_strCode	
AND I.TransI_strType = 'S'
AND I.TransI_strStatus <> 'W'
AND T.Item_strMasterItemCode in ('HOPHUTHULE')
-- AND T.Item_strReport <> 'Y'
AND I.TransI_dtmDateTime >= @fromDate
AND I.TransI_dtmDateTime < @toDate
group by CinOperator_strHOOperatorCode, I.TransI_dtmDateTime,TC.TransC_lgnNumber

UNION ALL 

SELECT TC.TransC_lgnNumber Trans_Number,
CinOperator_strHOOperatorCode Cinema,
CASE 
		WHEN DATEPART(HOUR, I.TransI_dtmDateTime) >= 0 AND DATEPART(HOUR, I.TransI_dtmDateTime) < 6 
				THEN DATEADD(DAY, -1, CAST(I.TransI_dtmDateTime AS DATE))
		ELSE I.TransI_dtmDateTime END AS Transaction_date,
0 as Admits_BO,
0 as BO_Gross,		
0 as Admits_CO,
0 as CO_Gross,		
0 as Admits_CO_PTL,
0 as CO_Gross_PTL,
sum(TransI_decNoOfItems) as Admits_CO_PTVIP,
sum(Round((TransI_decNoOfItems * TransI_curValueEach),6)) CO_Gross_PTVIP,
0 as Admits_CO_FnB_uudai,
0 as CO_Gross_FnB_uudai,
0 as Admits_CO_FnB_kouudai,
0 as CO_Gross_FnB_kouudai
FROM tblTrans_Inventory I WITH(INDEX(indTransI_Type_DateTime)), tblItem T, tblCinema_Operator Cin 	
,(select distinct TransC_lgnNumber from tblTrans_Cash where TransC_strBKCardNo = '222222......2222') TC
WHERE I.Item_strItemId = T.Item_strItemId 
AND TC.TransC_lgnNumber = I.TransI_lgnNumber
AND Cin.CinOperator_strCode = I.CinOperator_strCode	
AND I.TransI_strType = 'S'
AND I.TransI_strStatus <> 'W'
AND T.Item_strMasterItemCode in ('HOPHUTHU105KLL')
-- AND T.Item_strReport <> 'Y'
AND I.TransI_dtmDateTime >= @fromDate
AND I.TransI_dtmDateTime < @toDate
group by CinOperator_strHOOperatorCode, I.TransI_dtmDateTime, TC.TransC_lgnNumber

UNION ALL 

SELECT TC.TransC_lgnNumber Trans_Number,
CinOperator_strHOOperatorCode Cinema,
CASE 
		WHEN DATEPART(HOUR, I.TransI_dtmDateTime) >= 0 AND DATEPART(HOUR, I.TransI_dtmDateTime) < 6 
				THEN DATEADD(DAY, -1, CAST(I.TransI_dtmDateTime AS DATE))
		ELSE I.TransI_dtmDateTime END AS Transaction_date,
0 as Admits_BO,
0 as BO_Gross,
0 as Admits_CO,
0 as CO_Gross,
0 as Admits_CO_PTL,
0 as CO_Gross_PTL,
0 as Admits_CO_PTVIP,
0 as CO_Gross_PTVIP,
sum(TransI_decNoOfItems) as Admits_CO_FnB_uudai,
sum(Round((TransI_decNoOfItems * TransI_curValueEach),6)) as CO_Gross_FnB_uudai,
0 as Admits_CO_FnB_kouudai,
0 as CO_Gross_FnB_kouudai
FROM tblTrans_Inventory I WITH(INDEX(indTransI_Type_DateTime)), tblItem T, tblCinema_Operator Cin, tblSalesTax ST
,(select distinct TransC_lgnNumber from tblTrans_Cash where TransC_strBKCardNo = '222222......2222') TC
WHERE I.Item_strItemId = T.Item_strItemId 
AND TC.TransC_lgnNumber = I.TransI_lgnNumber
AND Cin.CinOperator_strCode = I.CinOperator_strCode	
AND I.TransI_strType = 'S'
AND T.STax_strCode = ST.STax_strCode
AND I.TransI_strStatus <> 'W'
AND T.Location_strCode = '0003' -- Dungpa 26/12/2023
AND ST.HOPK  <> '0000000006'
and T.Item_strMasterItemCode <> 'HOGOISIEUVIETGP'
AND I.TransI_dtmDateTime >= @fromDate
AND I.TransI_dtmDateTime < @toDate
group by CinOperator_strHOOperatorCode, I.TransI_dtmDateTime, TC.TransC_lgnNumber

UNION ALL 

SELECT TC.TransC_lgnNumber Trans_Number,
CinOperator_strHOOperatorCode Cinema,
CASE 
		WHEN DATEPART(HOUR, I.TransI_dtmDateTime) >= 0 AND DATEPART(HOUR, I.TransI_dtmDateTime) < 6 
				THEN DATEADD(DAY, -1, CAST(I.TransI_dtmDateTime AS DATE))
		ELSE I.TransI_dtmDateTime END AS Transaction_date,
0 as Admits_BO,
0 as BO_Gross,
0 as Admits_CO,
0 as CO_Gross,
0 as Admits_CO_PTL,
0 as CO_Gross_PTL,
0 as Admits_CO_PTVIP,
0 as CO_Gross_PTVIP,
0 as Admits_CO_FnB_uudai,
0 as CO_Gross_FnB_uudai,
sum(TransI_decNoOfItems) as Admits_CO_FnB_kouudai,
sum(Round((TransI_decNoOfItems * TransI_curValueEach),6)) as CO_Gross_FnB_kouudai
FROM tblTrans_Inventory I WITH(INDEX(indTransI_Type_DateTime)), tblItem T, tblCinema_Operator Cin, tblSalesTax ST
,(select distinct TransC_lgnNumber from tblTrans_Cash where TransC_strBKCardNo = '222222......2222') TC
WHERE I.Item_strItemId = T.Item_strItemId 
AND TC.TransC_lgnNumber = I.TransI_lgnNumber
AND Cin.CinOperator_strCode = I.CinOperator_strCode	
AND I.TransI_strType = 'S'
AND T.STax_strCode = ST.STax_strCode
AND I.TransI_strStatus <> 'W'
AND T.Location_strCode = '0003' -- Dungpa 26/12/2023
AND ST.HOPK  = '0000000006'
and T.Item_strMasterItemCode <> 'HOGOISIEUVIETGP'
AND I.TransI_dtmDateTime >= @fromDate
AND I.TransI_dtmDateTime < @toDate
group by CinOperator_strHOOperatorCode, I.TransI_dtmDateTime, TC.TransC_lgnNumber

) A 
group by A.Cinema, cast(A.Transaction_date as date), A.Trans_Number
order by A.Cinema, cast(A.Transaction_date as date)


-- 1 for all theo realtranstime

DECLARE @fromDate datetime, @toDate datetime 
SET @fromDate = '2024-06-10 00:00:00'
SET @toDate = '2024-06-17 00:00:00'

select 
A.Cinema,
cast(A.Transaction_date as date) Transaction_date,
sum(A.Admits_BO) as Admits_BO,
sum(A.BO_Gross) as BO_Gross,

sum(A.Admits_CO) - sum(A.Admits_CO_PTL) - sum(A.Admits_CO_PTVIP) - sum(A.Admits_CO_FnB_uudai) - sum(A.Admits_CO_FnB_kouudai) as Admits_CO,
sum(A.CO_Gross) - sum(A.CO_Gross_PTL) - sum(A.CO_Gross_PTVIP) - sum(A.CO_Gross_FnB_uudai) - sum(A.CO_Gross_FnB_kouudai) as CO_Gross,

sum(A.Admits_CO_PTL) as Admits_CO_PTL,
sum(A.CO_Gross_PTL) as CO_Gross_PTL,

sum(A.Admits_CO_PTVIP) as Admits_CO_PTVIP,
sum(A.CO_Gross_PTVIP) as CO_Gross_PTVIP,

sum(A.Admits_CO_FnB_uudai) as Admits_CO_FnB_uudai,
sum(A.CO_Gross_FnB_uudai) as CO_Gross_FnB_uudai,

sum(A.Admits_CO_FnB_kouudai) as Admits_CO_FnB_kouudai,
sum(A.CO_Gross_FnB_kouudai) as CO_Gross_FnB_kouudai
from 
(
SELECT 
CinOperator_strHOOperatorCode Cinema,
CASE 
		WHEN DATEPART(HOUR, T.TransT_dtmRealTransTime) >= 0 AND DATEPART(HOUR, T.TransT_dtmRealTransTime) < 6 
				THEN DATEADD(DAY, -1, CAST(T.TransT_dtmRealTransTime AS DATE))
		ELSE T.TransT_dtmRealTransTime END AS Transaction_date,
sum(T.TransT_intNoOfSeats) as Admits_BO,
SUM(TransT_intNoOfSeats * (CASE WHEN T.TransT_curRedempValueEach <> 0 THEN T.TransT_curRedempValueEach ELSE T.TransT_curValueEach END)) BO_Gross,
0 as Admits_CO,
0 as CO_Gross,
0 as Admits_CO_PTL,
0 as CO_Gross_PTL,
0 as Admits_CO_PTVIP,
0 as CO_Gross_PTVIP,
0 as Admits_CO_FnB_uudai,
0 as CO_Gross_FnB_uudai,
0 as Admits_CO_FnB_kouudai,
0 as CO_Gross_FnB_kouudai
FROM   tblSession S
INNER JOIN tblScreen_Layout sl ON S.ScreenL_intId = sl.ScreenL_intId
INNER JOIN tblCinema_Screen cs ON sl.Screen_bytNum = cs.Screen_bytNum AND sl.Cinema_strCode = cs.Cinema_strCode
LEFT JOIN tblTrans_Ticket T ON T.Session_lngSessionId = S.Session_lngSessionId
INNER JOIN (select distinct TransC_lgnNumber from tblTrans_Cash where TransC_strBKCardNo = '222222......2222') TC ON TC.TransC_lgnNumber = T.TransT_lgnNumber
INNER JOIN tblCinema_Operator Cin ON Cin.CinOperator_strCode = T.CinOperator_strCode
LEFT JOIN tblPrice P ON T.PGroup_strCode = P.PGroup_strCode AND T.Price_strCode = P.Price_strCode
WHERE  T.TransT_dtmRealTransTime >= @fromDate AND  T.TransT_dtmRealTransTime < @toDate
group by CinOperator_strHOOperatorCode, T.TransT_dtmRealTransTime

UNION ALL 

SELECT
CinOperator_strHOOperatorCode Cinema,
CASE 
		WHEN DATEPART(HOUR, I.TransI_dtmRealTransTime) >= 0 AND DATEPART(HOUR, I.TransI_dtmRealTransTime) < 6 
				THEN DATEADD(DAY, -1, CAST(I.TransI_dtmRealTransTime AS DATE))
		ELSE I.TransI_dtmRealTransTime END AS Transaction_date,
0 as Admits_BO,
0 as BO_Gross,
sum(TransI_decNoOfItems) as Admits_CO,
sum(Round((TransI_decNoOfItems * TransI_curValueEach),6)) CO_Gross,
0 as Admits_CO_PTL,
0 as CO_Gross_PTL,
0 as Admits_CO_PTVIP,
0 as CO_Gross_PTVIP,
0 as Admits_CO_FnB_uudai,
0 as CO_Gross_FnB_uudai,
0 as Admits_CO_FnB_kouudai,
0 as CO_Gross_FnB_kouudai
FROM tblTrans_Inventory I, tblItem T, tblCinema_Operator Cin 	
,(select distinct TransC_lgnNumber from tblTrans_Cash where TransC_strBKCardNo = '222222......2222') TC
WHERE I.Item_strItemId = T.Item_strItemId 
AND TC.TransC_lgnNumber = I.TransI_lgnNumber
AND Cin.CinOperator_strCode = I.CinOperator_strCode	
AND I.TransI_strType = 'S'
AND I.TransI_strStatus <> 'W'
-- AND T.Item_strReport <> 'Y'
AND I.TransI_dtmRealTransTime >= @fromDate
AND I.TransI_dtmRealTransTime < @toDate
group by CinOperator_strHOOperatorCode, I.TransI_dtmRealTransTime

UNION ALL 

SELECT
CinOperator_strHOOperatorCode Cinema,
CASE 
		WHEN DATEPART(HOUR, I.TransI_dtmRealTransTime) >= 0 AND DATEPART(HOUR, I.TransI_dtmRealTransTime) < 6 
				THEN DATEADD(DAY, -1, CAST(I.TransI_dtmRealTransTime AS DATE))
		ELSE I.TransI_dtmRealTransTime END AS Transaction_date,
0 as Admits_BO,
0 as BO_Gross,		
0 as Admits_CO,
0 as CO_Gross,		
sum(TransI_decNoOfItems) as Admits_CO_PTL,
sum(Round((TransI_decNoOfItems * TransI_curValueEach),6)) CO_Gross_PTL,
0 as Admits_CO_PTVIP,
0 as CO_Gross_PTVIP,
0 as Admits_CO_FnB_uudai,
0 as CO_Gross_FnB_uudai,
0 as Admits_CO_FnB_kouudai,
0 as CO_Gross_FnB_kouudai
FROM tblTrans_Inventory I, tblItem T, tblCinema_Operator Cin 	
,(select distinct TransC_lgnNumber from tblTrans_Cash where TransC_strBKCardNo = '222222......2222') TC
WHERE I.Item_strItemId = T.Item_strItemId 
AND TC.TransC_lgnNumber = I.TransI_lgnNumber
AND Cin.CinOperator_strCode = I.CinOperator_strCode	
AND I.TransI_strType = 'S'
AND I.TransI_strStatus <> 'W'
AND T.Item_strMasterItemCode in ('HOPHUTHULE')
-- AND T.Item_strReport <> 'Y'
AND I.TransI_dtmRealTransTime >= @fromDate
AND I.TransI_dtmRealTransTime < @toDate
group by CinOperator_strHOOperatorCode, I.TransI_dtmRealTransTime

UNION ALL 

SELECT
CinOperator_strHOOperatorCode Cinema,
CASE 
		WHEN DATEPART(HOUR, I.TransI_dtmRealTransTime) >= 0 AND DATEPART(HOUR, I.TransI_dtmRealTransTime) < 6 
				THEN DATEADD(DAY, -1, CAST(I.TransI_dtmRealTransTime AS DATE))
		ELSE I.TransI_dtmRealTransTime END AS Transaction_date,
0 as Admits_BO,
0 as BO_Gross,		
0 as Admits_CO,
0 as CO_Gross,		
0 as Admits_CO_PTL,
0 as CO_Gross_PTL,
sum(TransI_decNoOfItems) as Admits_CO_PTVIP,
sum(Round((TransI_decNoOfItems * TransI_curValueEach),6)) CO_Gross_PTVIP,
0 as Admits_CO_FnB_uudai,
0 as CO_Gross_FnB_uudai,
0 as Admits_CO_FnB_kouudai,
0 as CO_Gross_FnB_kouudai
FROM tblTrans_Inventory I, tblItem T, tblCinema_Operator Cin 	
,(select distinct TransC_lgnNumber from tblTrans_Cash where TransC_strBKCardNo = '222222......2222') TC
WHERE I.Item_strItemId = T.Item_strItemId 
AND TC.TransC_lgnNumber = I.TransI_lgnNumber
AND Cin.CinOperator_strCode = I.CinOperator_strCode	
AND I.TransI_strType = 'S'
AND I.TransI_strStatus <> 'W'
AND T.Item_strMasterItemCode in ('HOPHUTHU105KLL')
-- AND T.Item_strReport <> 'Y'
AND I.TransI_dtmRealTransTime >= @fromDate
AND I.TransI_dtmRealTransTime < @toDate
group by CinOperator_strHOOperatorCode, I.TransI_dtmRealTransTime

UNION ALL 

SELECT
CinOperator_strHOOperatorCode Cinema,
CASE 
		WHEN DATEPART(HOUR, I.TransI_dtmRealTransTime) >= 0 AND DATEPART(HOUR, I.TransI_dtmRealTransTime) < 6 
				THEN DATEADD(DAY, -1, CAST(I.TransI_dtmRealTransTime AS DATE))
		ELSE I.TransI_dtmRealTransTime END AS Transaction_date,
0 as Admits_BO,
0 as BO_Gross,
0 as Admits_CO,
0 as CO_Gross,
0 as Admits_CO_PTL,
0 as CO_Gross_PTL,
0 as Admits_CO_PTVIP,
0 as CO_Gross_PTVIP,
sum(TransI_decNoOfItems) as Admits_CO_FnB_uudai,
sum(Round((TransI_decNoOfItems * TransI_curValueEach),6)) as CO_Gross_FnB_uudai,
0 as Admits_CO_FnB_kouudai,
0 as CO_Gross_FnB_kouudai
FROM tblTrans_Inventory I, tblItem T, tblCinema_Operator Cin, tblSalesTax ST
,(select distinct TransC_lgnNumber from tblTrans_Cash where TransC_strBKCardNo = '222222......2222') TC
WHERE I.Item_strItemId = T.Item_strItemId 
AND TC.TransC_lgnNumber = I.TransI_lgnNumber
AND Cin.CinOperator_strCode = I.CinOperator_strCode	
AND I.TransI_strType = 'S'
AND T.STax_strCode = ST.STax_strCode
AND I.TransI_strStatus <> 'W'
AND T.Location_strCode = '0003' -- Dungpa 26/12/2023
AND ST.HOPK  <> '0000000006'
and T.Item_strMasterItemCode <> 'HOGOISIEUVIETGP'
AND I.TransI_dtmRealTransTime >= @fromDate
AND I.TransI_dtmRealTransTime < @toDate
group by CinOperator_strHOOperatorCode, I.TransI_dtmRealTransTime

UNION ALL 

SELECT
CinOperator_strHOOperatorCode Cinema,
CASE 
		WHEN DATEPART(HOUR, I.TransI_dtmRealTransTime) >= 0 AND DATEPART(HOUR, I.TransI_dtmRealTransTime) < 6 
				THEN DATEADD(DAY, -1, CAST(I.TransI_dtmRealTransTime AS DATE))
		ELSE I.TransI_dtmRealTransTime END AS Transaction_date,
0 as Admits_BO,
0 as BO_Gross,
0 as Admits_CO,
0 as CO_Gross,
0 as Admits_CO_PTL,
0 as CO_Gross_PTL,
0 as Admits_CO_PTVIP,
0 as CO_Gross_PTVIP,
0 as Admits_CO_FnB_uudai,
0 as CO_Gross_FnB_uudai,
sum(TransI_decNoOfItems) as Admits_CO_FnB_kouudai,
sum(Round((TransI_decNoOfItems * TransI_curValueEach),6)) as CO_Gross_FnB_kouudai
FROM tblTrans_Inventory I, tblItem T, tblCinema_Operator Cin, tblSalesTax ST
,(select distinct TransC_lgnNumber from tblTrans_Cash where TransC_strBKCardNo = '222222......2222') TC
WHERE I.Item_strItemId = T.Item_strItemId 
AND TC.TransC_lgnNumber = I.TransI_lgnNumber
AND Cin.CinOperator_strCode = I.CinOperator_strCode	
AND I.TransI_strType = 'S'
AND T.STax_strCode = ST.STax_strCode
AND I.TransI_strStatus <> 'W'
AND T.Location_strCode = '0003' -- Dungpa 26/12/2023
AND ST.HOPK  = '0000000006'
and T.Item_strMasterItemCode <> 'HOGOISIEUVIETGP'
AND I.TransI_dtmRealTransTime >= @fromDate
AND I.TransI_dtmRealTransTime < @toDate
group by CinOperator_strHOOperatorCode, I.TransI_dtmRealTransTime

) A 
group by A.Cinema, cast(A.Transaction_date as date)
order by A.Cinema, cast(A.Transaction_date as date)