select
CinOperator_strCode as 'Cinema Code',	
TransC_strBKCardNo as 'Card Number',	
       CASE 
			 WHEN TransC_strBKCardType = 'FUNDIINOFF' then 'FUNDIIN_OFF_QR'
			 WHEN TransC_strBKCardType = '' OR TransC_strBKCardType IS NULL
	   OR UPPER(RTRIM(LTRIM(TransC_strBKCardType))) IN ( 'OTHER', 'UNKNOWN' )
	   THEN ISNULL( ( SELECT  TOP 1 UPPER(D.Card_strCardType)
				         FROM    tblCardDefinition D
				         WHERE   LEFT(TransC_strBKCardNo,6) >= D.Card_strStartRange 
				         AND   LEFT(TransC_strBKCardNo,6) < D.Card_strEndRange 
				         AND   UPPER(D.Card_strPaymentCard) = 'Y' 
				         --B16693: Removed (Although I don't think this actually did anything)
				         --AND   (    T.TransC_strBKCardNo <> ''
				         --        OR T.TransC_strBKCardNo IS NOT NULL )
				         ORDER BY Card_intRangeSize ASC
				         ),
				         'UNKNOWN'
				         )
					     ELSE UPPER(TransC_strBKCardType)
					     END AS 'Card Type',	
TransC_curValue as 'Amount',	
TransC_strPaymentTransRef as 'Bank Reference',
Workstation_strCode as 'Workstation Code',	
TransC_lgnNumber as 'Transaction Number',	
cast(TransC_dtmDateTime as date) as 'Business Date',	
TransC_dtmDateTime as 'Transaction Date',
TransC_dtmRealTransTime as 'Real Transaction Date'
from tblTrans_Cash
where TransC_lgnNumber in 
(
3996, 3997
)




-- change bank ref
select
CinOperator_strCode as 'Cinema Code',	
TransC_strBKCardNo as 'Card Number',	
TransC_strBKCardType as 'Card Type',	
TransC_curValue as 'Amount',	
case when isnull(TransC_strPaymentTransRef,'') = '' then TransC_strPaymentTransRef else LEFT(TransC_strPaymentTransRef, CHARINDEX('~', TransC_strPaymentTransRef) - 1) end  as 'Bank Reference',
Workstation_strCode as 'Workstation Code',	
TransC_lgnNumber as 'Transaction Number',	
cast(TransC_dtmDateTime as date) as 'Business Date',	
TransC_dtmDateTime as 'Transaction Date',
TransC_dtmRealTransTime as 'Real Transaction Date'
from tblTrans_Cash
where TransC_lgnNumber = 3515


-- query APPZALOGRP 
select
CinOperator_strCode,	TransC_strBKCardType,	TransC_curValue,	TransC_strPaymentTransRef,	Workstation_strCode,	TransC_lgnNumber,cast(TransC_dtmDateTime as date)	business_date,	TransC_dtmDateTime
from tblTrans_Cash
Where TransC_strBKCardType = 'ZALOPAYGRS'
and TransC_dtmDateTime >= '2024-08-01 06:00:00'
and TransC_dtmDateTime < '2024-09-01 06:00:00'

-- Query lấy giao dịch online bỏ mấy cổng thanh toán đi
SELECT   
SUM( TransT_intNoOfSeats ) AS Admits
FROM  tblSession AS S 
INNER JOIN tblFilm F ON S.Film_strCode = F.Film_strCode
INNER JOIN tblTrans_Ticket T ON T.Session_lngSessionId = S.Session_lngSessionId
LEFT JOIN	(select distinct CASE WHEN (ISNULL(TransC_strBKCollected , 'N')) = 'Y' THEN IsNull(TransC_strBKSource,'POSBK') ELSE IsNull(TransC_strBKSource,'POS') END AS Sales_Channel,TransC_lgnNumber from tblTrans_Cash where TransC_strBKCardType not in ('APPMOMO','APPVNPAY','APPZALO','MOMO','MOMOGRS','MOMOGRSDIS','VNPAYGRS','ZALOPAYGRS')) B on T.TransT_lgnNumber = B.TransC_lgnNumber	
INNER JOIN tblCinema_Operator C ON T.CinOperator_strCode = C.CinOperator_strCode
LEFT OUTER JOIN tblBooking_Header BH ON BH.TransC_lgnNumber = T.TransT_lgnNumber
WHERE    Session_dtmRealShow >= '2024-07-12 17:30:00' --DATEADD(HOUR,6,CONVERT(VARCHAR(10), GETDATE(),110))--@DateFrom
	AND    Session_dtmRealShow < GETDATE()
	AND    Session_strStatus IN ('O', 'C')		
	AND 	 Sales_Channel = 'WWW'


-- Query lấy payment type và card type tại rạp
declare @numb int, @date int
set @numb = 486 -- Transaction Number
set @date = 8 -- lùi 1 ngày kể từ now()

select strDate,	PayType_strDescription,	cardType, sum(Gross) Gross
from 
(
SELECT cast(TransC_dtmDateTime as date) strDate,
		tblPaymentType.PayType_strDescription,
		CASE WHEN Cash.TransC_strBKCardType = '' OR Cash.TransC_strBKCardType IS NULL
	   OR UPPER(RTRIM(LTRIM(Cash.TransC_strBKCardType))) IN ( 'OTHER', 'UNKNOWN' )
	   THEN ISNULL( ( SELECT  TOP 1 UPPER(D.Card_strCardType)
				         FROM    tblCardDefinition D
				         WHERE   LEFT(Cash.TransC_strBKCardNo,6) >= D.Card_strStartRange 
				         AND   LEFT(Cash.TransC_strBKCardNo,6) < D.Card_strEndRange 
				         AND   UPPER(D.Card_strPaymentCard) = 'Y' 
				         ORDER BY Card_intRangeSize ASC
				         ),
				         'UNKNOWN'
				         )
					     ELSE UPPER(Cash.TransC_strBKCardType) 
					     END AS cardType,
			SUM(Cash.TransC_curValue) AS Gross				 
FROM tblTrans_Cash Cash WITH (INDEX=indDateTime), 
		tblPaymentType, tblWorkstation, tblWorkstation_Group
WHERE Cash.TransC_strType = tblPaymentType.PayType_strType AND
		Cash.Workstation_strCode = tblWorkstation.Workstation_strCode AND
		tblWorkstation.WGroup_strCode = tblWorkstation_Group.WGroup_strCode AND
		Cash.TransC_curValue >= 0 AND 
		TransC_dtmDateTime >= DATEADD(HOUR,6,CONVERT(VARCHAR(10), GETDATE()- @date,110)) AND 
		Cash.TransC_lgnNumber = @numb
GROUP BY tblPaymentType.PayType_strDescription, Cash.TransC_strBKCardType, Cash.TransC_strBKCardNo,cast(TransC_dtmDateTime as date) 
) A 
group by strDate,	PayType_strDescription,	cardType
order by strDate asc


-- his stock 
-- DECLARE @fromdate DATETIME = '2023-01-01 06:00:01.000',
--         @todate DATETIME = '2023-02-01 06:00:01.000',
--         @cinema_code NVARCHAR(100),
--         @cinema_name NVARCHAR(100),
--         @month_counter INT = 1;  -- Counter to track the month
-- 
-- -- Loop through each month of 2023
-- WHILE @month_counter <= 5
-- BEGIN
--     -- Get Cinema info
--     SELECT TOP 1 
--         @cinema_code = CinOperator_strCode, 
--         @cinema_name = CinOperator_strHOOperatorCode 
--     FROM tblCinema_Operator;
--     
--     -- Execute the stored procedure with the current month's date range
--     EXEC spRptStockVar @fromdate, @todate, StockLocation, StocktakeGroup, ItemClass, Vendor, Frequency, N'_Y', 999999, N'S';
-- 
-- 		-- Check if the table exists, if not, create it
-- 		IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'tblglxStockVarianceReport')
-- 		BEGIN
-- 				CREATE TABLE tblglxStockVarianceReport (
-- 						Cinema nvarchar(100),
-- 						MonthYear nvarchar(100),
-- 						NhapKho FLOAT,
-- 						ThucTeBan FLOAT,
-- 						TonThucTe FLOAT,
-- 						TangKho FLOAT,
-- 						TongCost FLOAT
-- 				);
-- 		END;
-- 
-- 		-- Insert the desired results into tblglxStockVarianceReport
-- 		INSERT INTO tblglxStockVarianceReport (Cinema, MonthYear, NhapKho, ThucTeBan, TonThucTe, TangKho, TongCost)
-- 
--     -- Select the desired aggregated results
--     SELECT @cinema_name as 'Cinema',
-- 				format(@fromdate, 'MM-yyyy') as 'MonthYear',
--         SUM(CAST(PlusReceipts AS FLOAT)) AS 'NhapKho',
--         SUM(CAST(LessSales AS FLOAT) + CAST(LessUsage AS FLOAT)) AS 'ThucTeBan',
--         SUM(CAST(StockAtEnd AS FLOAT)) AS 'TonThucTe',
-- 				SUM(CAST(VarianceQuantity as FLOAT)) AS 'TangKho',
--         (SUM(DISTINCT CAST(UnitCost AS FLOAT)) * SUM(CAST(StockAtEnd AS FLOAT))) AS 'TongCost'
--     FROM tblRptStockVar
--     WHERE Item_strHOCode = 'HOKITKATNEW';
-- 
--     -- Increment @fromdate and @todate by 1 month for the next iteration
--     SET @fromdate = DATEADD(MONTH, 1, @fromdate);
--     SET @todate = DATEADD(MONTH, 1, @todate);
--     
--     -- Increment the month counter
--     SET @month_counter = @month_counter + 1;
-- END;
-- 

select * from tblglxStockVarianceReport

-- lấy định lượng và item BOM của item bán
select  a.Item_strItemDescription ItemDescription, d.Unit_strDescription as 'UOM(Sold)', a.Item_curRetailPrice as RetailPrice, a.Item_decCostPrice CostPrice, round((a.Item_decCostPrice*100 / a.Item_curRetailPrice),2) as 'CostPricePercent', c.Item_strItemDescription as RecipeDescription,  c.Item_strMasterItemCode HORecipeCode,c.Item_decCostPrice as CostRecipePrice, e.Unit_strDescription as 'UOMRecipe', BOM_curItemQty as RecipeQty
from tblItem a 
left join tblUnitOfMeasure d on a.Item_strBaseUOMCode = d.Unit_strCode
join tblBOM b on a.Item_strItemId = b.Item_strItemId
join tblItem c on b.BOM_strItemId = c.Item_strItemId
left join tblUnitOfMeasure e on c.Item_strBaseUOMCode = e.Unit_strCode
where a.Item_strMasterItemCode in
(
'HOPOPLATEECAFE',
'HONONCFPOCAFE',
'HOCHESEECOFFEE',
'HOESPRESSO12OZ',
'HOCAFESUA12OZ',
'HOAMERICA12OZ',
'HOCAPPUCINO12OZ',
'HOICELATE12OZ',
'HOGLXMATCHABLEN',
'HOGLXPOPBLENDE',
'HOGLXPOPVLENONC',
'HOHIBICUSTE12OZ',
'HOCANELECAKE',
'HOBCREMEPLA',
'HOTUIBANHPAINAU',
'HOTUIBANHCROSI'
)

-- Query item  onl off
select c.CinOperator_strHOOperatorCode Cinema,
case when User_intUserNo < 0 then 'Online' else 'Offline' end Channel,
sum(TransI_decActualNoOfItems) Quantity
from tblTrans_Inventory a 
join tblItem b on a.Item_strItemId = b.Item_strItemId
join tblCinema_Operator c on a.CinOperator_strCode = c.CinOperator_strCode
where Item_strMasterItemCode in
(
'HOICBDANHGIHCMV',
'HOICBDANHGIOTHV',
'HOICBGIAMONHCMV',
'HOICBGIAMONOTHV',
'HOICBHAOMONHCMV',
'HOICBHAOMONOTHV'
)
and TransI_strType = 'S'
group by c.CinOperator_strHOOperatorCode,case when User_intUserNo < 0 then 'Online' else 'Offline' end 



-- query lấy thông tin 


select  
CinOperator_strHOOperatorCode cinema,
format(TransT_dtmDateTime, 'yyyy-MM') yearMonth,
case when User_intUserNo < 0 then 'Online' else 'Offline' end Channel,
sum(TransT_intNoOfSeats) admits,
count(distinct TransT_lgnNumber) total_trans_bo,
0 as total_trans_co,
0 as total_co
from tblTrans_Ticket a 
join (
select distinct Session_lngSessionId
from tblSession
where (Session_intSeatsSold*100.0 / (Session_intSeatsAvail	+ Session_intSeatsSold)) >= 80
and Session_dtmRealShow >= '2022-01-01 00:00:00.000'
) b on a.Session_lngSessionId = b.Session_lngSessionId
join tblCinema_Operator c on a.CinOperator_strCode = c.CinOperator_strCode
where a.TransT_strStatus = 'V'
group by format(TransT_dtmDateTime, 'yyyy-MM'),case when User_intUserNo < 0 then 'Online' else 'Offline' end,CinOperator_strHOOperatorCode

union all 

select CinOperator_strHOOperatorCode cinema,format(TransI_dtmDateTime, 'yyyy-MM') yearMonth,case when User_intUserNo < 0 then 'Online' else 'Offline' end Channel,
0 as admits,
0 as total_trans_bo,
count(distinct TransI_lgnNumber) total_trans_co, sum(TransI_decActualNoOfItems) total_co
from tblTrans_Inventory c 
join (select distinct TransT_lgnNumber 
from tblTrans_Ticket a 
join (
select distinct Session_lngSessionId
from tblSession
where (Session_intSeatsSold*100.0 / (Session_intSeatsAvail	+ Session_intSeatsSold)) >= 80
and Session_dtmRealShow >= '2022-01-01 00:00:00.000'
) b on a.Session_lngSessionId = b.Session_lngSessionId
where a.TransT_strStatus = 'V') ctv on c.TransI_lgnNumber = ctv.TransT_lgnNumber
join tblCinema_Operator d on c.CinOperator_strCode = d.CinOperator_strCode
where TransI_strType = 'S'
group by case when User_intUserNo < 0 then 'Online' else 'Offline' end ,CinOperator_strHOOperatorCode,format(TransI_dtmDateTime, 'yyyy-MM')


-- lam file template
-- lam file template
SELECT A.*
FROM
(
select 
TransC_lgnNumber 'MaGiaoDich',
cast(cash.TransC_dtmDateTime as date) as 'businessDate',
cin.CinOperator_strHOOperatorCode 'CinemaName', 
pay.PayType_strDescription PaymentType,
(TransC_curValue) Value
From tblTrans_Cash cash 
join tblCinema_Operator cin on cash.CinOperator_strCode = cin.CinOperator_strCode
join tblPaymentType pay on cash.TransC_strType = pay.PayType_strType	
where 1=1 
and cash.TransC_dtmDateTime >= '2024-11-01 06:00:00'
and cash.TransC_dtmDateTime < '2024-11-02 06:00:00'
AND 'Y' NOT IN ( pay.PayType_strCreditCard, pay.PayType_strDebitCard)

union all 

-- lam file template
select 
TransC_lgnNumber 'MaGiaoDich',
cast(cash.TransC_dtmDateTime as date) as 'businessDate',
cin.CinOperator_strHOOperatorCode 'CinemaName', 
	(CASE  WHEN cash.TransC_strBKCardType = '' OR cash.TransC_strBKCardType IS NULL OR UPPER(cash.TransC_strBKCardType) = 'OTHER' OR UPPER(cash.TransC_strBKCardType) = 'UNKNOWN' 
						THEN ISNULL((Select top 1 UPPER(Card_strCardType)
						from tblCardDefinition 
						where Left(cash.TransC_strBKCardNo,6) >= Card_strStartRange 
						AND left(cash.TransC_strBKCardNo,6) < Card_strEndRange 
						AND Upper(Card_strPaymentCard) = 'Y' 
						AND (cash.TransC_strBKCardNo <> ''
						OR   cash.TransC_strBKCardNo IS NOT NULL)
						order by Card_intRangeSize Asc) , 'UNKNOWN')
						ELSE UPPER(cash.TransC_strBKCardType) END) as PaymentType,			
TransC_curValue Value
From tblTrans_Cash cash 
join tblCinema_Operator cin on cash.CinOperator_strCode = cin.CinOperator_strCode
join tblPaymentType pay on cash.TransC_strType = pay.PayType_strType	
where 1=1 
and cash.TransC_dtmDateTime >= '2024-11-01 06:00:00'
and cash.TransC_dtmDateTime < '2024-11-02 06:00:00'
AND 'Y' IN ( pay.PayType_strCreditCard, pay.PayType_strDebitCard )
) A 
order by A.MaGiaoDich

SELECT 
TransT_lgnNumber,
sum(T.TransT_intNoOfSeats) as admits,
((ISNULL( SUM( CASE WHEN T.TransT_curRedempValueEach = 0 THEN TransT_intNoOfSeats * TransT_curValueEach ELSE 0 END ), 0 )) + ISNULL( SUM( CASE WHEN T.TransT_curRedempValueEach = 0 THEN 0
                                             ELSE T.TransT_intNoOfSeats * T.TransT_curRedempValueEach
                                             END ), 0 )) 'Gross',
sum(TransT_curTaxAmount - ISNULL(TransT_curTaxAmount2,0) - ISNULL(TransT_curTaxAmount3,0) - ISNULL(TransT_curTaxAmount4,0)) tax
FROM   tblTrans_Ticket T
INNER JOIN tblTicketType TT ON TT.TType_strCode = T.Price_strCode
INNER JOIN tblCinema_Operator Cin ON Cin.CinOperator_strCode = T.CinOperator_strCode
LEFT JOIN tblPrice P ON T.PGroup_strCode = P.PGroup_strCode AND T.Price_strCode = P.Price_strCode
WHERE  
TransT_lgnNumber in
(
select distinct TransC_lgnNumber 
from tblTrans_Cash cash 
where  1=1 
and cash.TransC_dtmDateTime >= '2024-11-01 06:00:00'
and cash.TransC_dtmDateTime < '2024-11-02 06:00:00'
)
group by TransT_lgnNumber


-- CO Counter
SELECT
TransI_lgnNumber,
sum(TransI_decNoOfItems) as Quantity,
SUM(Case ISNULL(Item_curSaleUOMConv, 0) WHEN 0 THEN --handle divide by zero
            Round((IsNull(TransI_decNoOfItems, (TransI_decNoOfItems / 1)) * TransI_curValueEach), 6)
        ELSE --this is the typical path
            Round((IsNull(TransI_decNoOfItems, (TransI_decNoOfItems / 1)) * TransI_curValueEach), 6)
        END) as 'Gross',
sum((  Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach,0))  ,6)+ 
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach2,0)) ,6)+
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach3,0)) ,6)+ 
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach4,0)) ,6)    
        )) tax
FROM tblTrans_Inventory I , tblItem T, tblCinema_Operator Cin  , tblSalesTax ST  , tblStock_Location SL
WHERE I.Item_strItemId = T.Item_strItemId 
AND Cin.CinOperator_strCode = I.CinOperator_strCode 
AND T.STax_strCode = ST.STax_strCode
AND I.Location_strCode = SL.Location_strCode
AND I.TransI_strType = 'S' 
AND TransI_lgnNumber in
(
select distinct TransC_lgnNumber 
from tblTrans_Cash cash 
where  1=1 
and cash.TransC_dtmDateTime >= '2024-11-01 06:00:00'
and cash.TransC_dtmDateTime < '2024-11-02 06:00:00'
)
group by TransI_lgnNumber


