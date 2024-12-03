-- case đặc biệt xài voucher dẫn đến bên report Ticker có tiền còn report Receipt Summary thì = 0 (ND: 8653206)

-- BO 
SELECT 
CinOperator_strHOOperatorCode,
TT.TType_strCode item,
TT.TType_strDescription item_name,
sum(T.TransT_intNoOfSeats) as admits,
T.TransT_curValueEach unit_price,
sum(T.TransT_curDiscount) discount,
((ISNULL( SUM( CASE WHEN T.TransT_curRedempValueEach = 0 THEN TransT_intNoOfSeats * TransT_curValueEach ELSE 0 END ), 0 )) + ISNULL( SUM( CASE WHEN T.TransT_curRedempValueEach = 0 THEN 0
                                             ELSE T.TransT_intNoOfSeats * T.TransT_curRedempValueEach
                                             END ), 0 )) 'Gross',
SUM((ISNULL( ( CASE WHEN T.TransT_curRedempValueEach = 0 THEN TransT_intNoOfSeats * ( TransT_curValueEach - TransT_curTaxAmount -
ISNULL(TransT_curTaxAmount2,0) - ISNULL(TransT_curTaxAmount3,0) - ISNULL(TransT_curTaxAmount4,0) ) ELSE 0 END ), 0 ) 
+
ISNULL( ( CASE WHEN T.TransT_curRedempValueEach = 0 THEN 0 ELSE T.TransT_intNoOfSeats * ( TransT_curRedempValueEach - TransT_curRedempTaxEach -
ISNULL(TransT_curRedempTaxEach2,0) - ISNULL(TransT_curRedempTaxEach3,0) - ISNULL(TransT_curRedempTaxEach4,0) ) END ), 0 )
)) as 'Net'
FROM   tblSession S
INNER JOIN tblScreen_Layout sl ON S.ScreenL_intId = sl.ScreenL_intId
INNER JOIN tblCinema_Screen cs ON sl.Screen_bytNum = cs.Screen_bytNum AND sl.Cinema_strCode = cs.Cinema_strCode
LEFT JOIN tblTrans_Ticket T ON T.Session_lngSessionId = S.Session_lngSessionId
INNER JOIN tblTicketType TT ON TT.TType_strCode = T.Price_strCode
INNER JOIN tblCinema_Operator Cin ON Cin.CinOperator_strCode = T.CinOperator_strCode
LEFT JOIN tblPrice P ON T.PGroup_strCode = P.PGroup_strCode AND T.Price_strCode = P.Price_strCode
WHERE  S.Session_dtmRealShow >= 'myFromDateInput' -- input fromdate
AND  S.Session_dtmRealShow <= 'myToDateInput' -- input todate 
group by CinOperator_strHOOperatorCode,TT.TType_strCode,TT.TType_strDescription,T.TransT_curValueEach

-- CO Counter
SELECT
Cin.CinOperator_strCode,
CinOperator_strHOOperatorCode,
T.Item_strItemId as item,
Item_strItemDescription as item_name,
sum(TransI_decNoOfItems) as Quantity,
TransI_curValueEach unit_price,
SUM(Case ISNULL(Item_curSaleUOMConv, 0) WHEN 0 THEN --handle divide by zero
            Round((IsNull(TransI_decNoOfItems, (TransI_decNoOfItems / 1)) * TransI_curValueEach), 6)
        ELSE --this is the typical path
            Round((IsNull(TransI_decNoOfItems, (TransI_decNoOfItems / 1)) * TransI_curValueEach), 6)
        END) as 'Gross',
ROUND(SUM(Case Item_curSaleUOMConv WHEN 0 THEN
        (Round((TransI_decNoOfItems * TransI_curValueEach)             ,6) - 
        (  Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach,0))  ,6)+ 
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach2,0)) ,6)+
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach3,0)) ,6)+ 
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach4,0)) ,6)    
        ))
                ELSE
        (Round((TransI_decNoOfItems * TransI_curValueEach)             ,6) - 
        (  Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach,0))  ,6)+ 
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach2,0)) ,6)+
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach3,0)) ,6)+ 
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach4,0)) ,6)    
        ))
    END),2) 'Net'
FROM tblTrans_Inventory I , tblItem T, tblCinema_Operator Cin  , tblSalesTax ST  , tblStock_Location SL
WHERE I.Item_strItemId = T.Item_strItemId 
AND Cin.CinOperator_strCode = I.CinOperator_strCode 
AND T.STax_strCode = ST.STax_strCode
AND I.Location_strCode = SL.Location_strCode
AND I.TransI_strType = 'S' AND I.TransI_strStatus <> 'W' AND T.Item_strReport <> 'Y'
AND I.TransI_dtmDateTime >= 'myFromDateInput' -- input fromdate
AND I.TransI_dtmDateTime <=  'myToDateInput' -- input todate
AND T.Item_strMasterItemCode <> 'HOGOISIEUVIETGP'
--AND ST.STax_strCode  <> '0000000005'
AND SL.Location_strCode <> '0003'
group by Cin.CinOperator_strCode,CinOperator_strHOOperatorCode,T.Item_strItemId,TransI_curValueEach,Item_strItemDescription





-- CO F&B 10%
SELECT
Cin.CinOperator_strCode,
CinOperator_strHOOperatorCode,
T.Item_strItemId as item,
Item_strItemDescription as item_name,
sum(TransI_decNoOfItems) as Quantity,
TransI_curValueEach unit_price,
SUM(Case ISNULL(Item_curSaleUOMConv, 0) WHEN 0 THEN --handle divide by zero
            Round((IsNull(TransI_decNoOfItems, (TransI_decNoOfItems / 1)) * TransI_curValueEach), 6)
        ELSE --this is the typical path
            Round((IsNull(TransI_decNoOfItems, (TransI_decNoOfItems / 1)) * TransI_curValueEach), 6)
        END) as 'Gross',
ROUND(SUM(Case Item_curSaleUOMConv WHEN 0 THEN
        (Round((TransI_decNoOfItems * TransI_curValueEach)             ,6) - 
        (  Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach,0))  ,6)+ 
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach2,0)) ,6)+
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach3,0)) ,6)+ 
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach4,0)) ,6)    
        ))
                ELSE
        (Round((TransI_decNoOfItems * TransI_curValueEach)             ,6) - 
        (  Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach,0))  ,6)+ 
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach2,0)) ,6)+
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach3,0)) ,6)+ 
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach4,0)) ,6)    
        ))
    END),2) 'Net'
FROM tblTrans_Inventory I , tblItem T, tblCinema_Operator Cin  , tblSalesTax ST  , tblStock_Location SL
WHERE I.Item_strItemId = T.Item_strItemId 
AND Cin.CinOperator_strCode = I.CinOperator_strCode 
AND T.STax_strCode = ST.STax_strCode
AND I.Location_strCode = SL.Location_strCode
AND I.TransI_strType = 'S' AND I.TransI_strStatus <> 'W' AND T.Item_strReport <> 'Y'
AND I.TransI_dtmDateTime >= 'myFromDateInput' -- input fromdate
AND I.TransI_dtmDateTime <=  'myToDateInput' -- input todate
AND T.Item_strMasterItemCode <> 'HOGOISIEUVIETGP'
AND ST.HOPK  = '0000000006'
AND SL.Location_strCode = '0003'
group by Cin.CinOperator_strCode,CinOperator_strHOOperatorCode,T.Item_strItemId,TransI_curValueEach,Item_strItemDescription




-- CO F&B Khác 10%
SELECT
Cin.CinOperator_strCode,
CinOperator_strHOOperatorCode,
T.Item_strItemId as item,
Item_strItemDescription as item_name,
sum(TransI_decNoOfItems) as Quantity,
TransI_curValueEach unit_price,
SUM(Case ISNULL(Item_curSaleUOMConv, 0) WHEN 0 THEN --handle divide by zero
            Round((IsNull(TransI_decNoOfItems, (TransI_decNoOfItems / 1)) * TransI_curValueEach), 6)
        ELSE --this is the typical path
            Round((IsNull(TransI_decNoOfItems, (TransI_decNoOfItems / 1)) * TransI_curValueEach), 6)
        END) as 'Gross',
ROUND(SUM(Case Item_curSaleUOMConv WHEN 0 THEN
        (Round((TransI_decNoOfItems * TransI_curValueEach)             ,6) - 
        (  Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach,0))  ,6)+ 
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach2,0)) ,6)+
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach3,0)) ,6)+ 
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach4,0)) ,6)    
        ))
                ELSE
        (Round((TransI_decNoOfItems * TransI_curValueEach)             ,6) - 
        (  Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach,0))  ,6)+ 
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach2,0)) ,6)+
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach3,0)) ,6)+ 
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach4,0)) ,6)    
        ))
    END),2) 'Net'
FROM tblTrans_Inventory I , tblItem T, tblCinema_Operator Cin  , tblSalesTax ST  , tblStock_Location SL
WHERE I.Item_strItemId = T.Item_strItemId 
AND Cin.CinOperator_strCode = I.CinOperator_strCode 
AND T.STax_strCode = ST.STax_strCode
AND I.Location_strCode = SL.Location_strCode
AND I.TransI_strType = 'S' AND I.TransI_strStatus <> 'W' AND T.Item_strReport <> 'Y'
AND I.TransI_dtmDateTime >= 'myFromDateInput' -- input fromdate
AND I.TransI_dtmDateTime <=  'myToDateInput' -- input todate
AND T.Item_strMasterItemCode <> 'HOGOISIEUVIETGP'
AND ST.HOPK  <> '0000000006'
AND SL.Location_strCode = '0003'
group by Cin.CinOperator_strCode,CinOperator_strHOOperatorCode,T.Item_strItemId,TransI_curValueEach,Item_strItemDescription


-- query new


select A.*
from 
(
-- BO 
SELECT 
CinOperator_strHOOperatorCode cinema,
TransT_lgnNumber transaction_number,
TT.TType_strCode item_code,
TT.TType_strDescription item_name,
sum(T.TransT_intNoOfSeats) as admits,
T.TransT_curValueEach unit_price,
((ISNULL( SUM( CASE WHEN T.TransT_curRedempValueEach = 0 THEN TransT_intNoOfSeats * TransT_curValueEach ELSE 0 END ), 0 )) + ISNULL( SUM( CASE WHEN T.TransT_curRedempValueEach = 0 THEN 0
                                             ELSE T.TransT_intNoOfSeats * T.TransT_curRedempValueEach
                                             END ), 0 )) 'gross_bo',
																						 sum(TransT_curTaxAmount -
ISNULL(TransT_curTaxAmount2,0) - ISNULL(TransT_curTaxAmount3,0) - ISNULL(TransT_curTaxAmount4,0)) as 'tax_bo',
SUM((ISNULL( ( CASE WHEN T.TransT_curRedempValueEach = 0 THEN TransT_intNoOfSeats * ( TransT_curValueEach - TransT_curTaxAmount -
ISNULL(TransT_curTaxAmount2,0) - ISNULL(TransT_curTaxAmount3,0) - ISNULL(TransT_curTaxAmount4,0) ) ELSE 0 END ), 0 ) 
+
ISNULL( ( CASE WHEN T.TransT_curRedempValueEach = 0 THEN 0 ELSE T.TransT_intNoOfSeats * ( TransT_curRedempValueEach - TransT_curRedempTaxEach -
ISNULL(TransT_curRedempTaxEach2,0) - ISNULL(TransT_curRedempTaxEach3,0) - ISNULL(TransT_curRedempTaxEach4,0) ) END ), 0 )
)) as 'net_bo',
0 as qty_co,
0 as gross_co,
0 as tax_co,
0 as net_co
FROM   tblSession S
INNER JOIN tblScreen_Layout sl ON S.ScreenL_intId = sl.ScreenL_intId
INNER JOIN tblCinema_Screen cs ON sl.Screen_bytNum = cs.Screen_bytNum AND sl.Cinema_strCode = cs.Cinema_strCode
LEFT JOIN tblTrans_Ticket T ON T.Session_lngSessionId = S.Session_lngSessionId
INNER JOIN tblTicketType TT ON TT.TType_strCode = T.Price_strCode
INNER JOIN tblCinema_Operator Cin ON Cin.CinOperator_strCode = T.CinOperator_strCode
LEFT JOIN tblPrice P ON T.PGroup_strCode = P.PGroup_strCode AND T.Price_strCode = P.Price_strCode
WHERE  S.Session_dtmRealShow >= '2024-10-21 06:00:00' -- input fromdate
AND  S.Session_dtmRealShow <= '2024-10-22 06:00:00' -- input todate 
group by CinOperator_strHOOperatorCode,TT.TType_strCode,TT.TType_strDescription,T.TransT_curValueEach,TransT_lgnNumber

union all

-- CO Counter
SELECT
CinOperator_strHOOperatorCode cinema,
TransI_lgnNumber transaction_number,
T.Item_strItemId as item_code,
Item_strItemDescription as item_name,
0 as admits,
TransI_curValueEach unit_price,
0 as gross_bo,
0 as tax_b0,
0 as net_bo,
sum(TransI_decNoOfItems) as qty_co,
SUM(Case ISNULL(Item_curSaleUOMConv, 0) WHEN 0 THEN --handle divide by zero
            Round((IsNull(TransI_decNoOfItems, (TransI_decNoOfItems / 1)) * TransI_curValueEach), 6)
        ELSE --this is the typical path
            Round((IsNull(TransI_decNoOfItems, (TransI_decNoOfItems / 1)) * TransI_curValueEach), 6)
        END) as 'gross_co',
SUM(  Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach,0))  ,6)+ 
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach2,0)) ,6)+
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach3,0)) ,6)+ 
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach4,0)) ,6)    
        ) as 'tax_co',
ROUND(SUM(Case Item_curSaleUOMConv WHEN 0 THEN
        (Round((TransI_decNoOfItems * TransI_curValueEach)             ,6) - 
        (  Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach,0))  ,6)+ 
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach2,0)) ,6)+
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach3,0)) ,6)+ 
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach4,0)) ,6)    
        ))
                ELSE
        (Round((TransI_decNoOfItems * TransI_curValueEach)             ,6) - 
        (  Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach,0))  ,6)+ 
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach2,0)) ,6)+
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach3,0)) ,6)+ 
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach4,0)) ,6)    
        ))
    END),2) 'net_co'
FROM tblTrans_Inventory I , tblItem T, tblCinema_Operator Cin  , tblSalesTax ST  , tblStock_Location SL
WHERE I.Item_strItemId = T.Item_strItemId 
AND Cin.CinOperator_strCode = I.CinOperator_strCode 
AND T.STax_strCode = ST.STax_strCode
AND I.Location_strCode = SL.Location_strCode
AND I.TransI_strType = 'S' AND I.TransI_strStatus <> 'W' AND T.Item_strReport <> 'Y'
AND I.TransI_dtmDateTime >= '2024-10-21 06:00:00' -- input fromdate
AND I.TransI_dtmDateTime <=  '2024-10-22 06:00:00' -- input todate
AND T.Item_strMasterItemCode <> 'HOGOISIEUVIETGP'
--AND ST.STax_strCode  <> '0000000005'
group by TransI_lgnNumber,CinOperator_strHOOperatorCode,T.Item_strItemId,TransI_curValueEach,Item_strItemDescription
) A
order by A.transaction_number


-- code new
declare @from datetime, @to datetime 
set @from = '2024-09-02 00:00:00'
set @to = '2024-09-03 00:00:00'


SELECT 
CinOperator_strHOOperatorCode cinema,
T.TransT_lgnNumber transaction_number,
T.TransT_dtmDateTime transaction_date,
T.TransT_dtmRealTransTime real_transaction_date,
TT.TType_strCode item,
TT.TType_strDescription item_name,
sum(T.TransT_intNoOfSeats) as bo_quantity,
T.TransT_curValueEach bo_unit_price,
((ISNULL( SUM( CASE WHEN T.TransT_curRedempValueEach = 0 THEN TransT_intNoOfSeats * TransT_curValueEach ELSE 0 END ), 0 )) + ISNULL( SUM( CASE WHEN T.TransT_curRedempValueEach = 0 THEN 0
                                             ELSE T.TransT_intNoOfSeats * T.TransT_curRedempValueEach
                                             END ), 0 )) 'bo_gross',
sum(TransT_curTaxAmount + ISNULL(TransT_curTaxAmount2,0) + ISNULL(TransT_curTaxAmount3,0) + ISNULL(TransT_curTaxAmount4,0)) as 'bo_tax',
SUM((ISNULL( ( CASE WHEN T.TransT_curRedempValueEach = 0 THEN TransT_intNoOfSeats * ( TransT_curValueEach - TransT_curTaxAmount -
ISNULL(TransT_curTaxAmount2,0) - ISNULL(TransT_curTaxAmount3,0) - ISNULL(TransT_curTaxAmount4,0) ) ELSE 0 END ), 0 ) 
+
ISNULL( ( CASE WHEN T.TransT_curRedempValueEach = 0 THEN 0 ELSE T.TransT_intNoOfSeats * ( TransT_curRedempValueEach - TransT_curRedempTaxEach -
ISNULL(TransT_curRedempTaxEach2,0) - ISNULL(TransT_curRedempTaxEach3,0) - ISNULL(TransT_curRedempTaxEach4,0) ) END ), 0 )
)) as 'bo_net',
0 as co_quantity,
0 as co_unit_price,
0 as co_gross,
0 as co_tax,
0 as co_net
FROM tblTrans_Ticket T
INNER JOIN tblTicketType TT ON TT.TType_strCode = T.Price_strCode
INNER JOIN tblCinema_Operator Cin ON Cin.CinOperator_strCode = T.CinOperator_strCode
LEFT JOIN tblPrice P ON T.PGroup_strCode = P.PGroup_strCode AND T.Price_strCode = P.Price_strCode
WHERE  T.TransT_dtmDateTime >= @from
AND  T.TransT_dtmDateTime <= @to
group by CinOperator_strHOOperatorCode,TT.TType_strCode,TT.TType_strDescription,T.TransT_curValueEach,T.TransT_lgnNumber,T.TransT_dtmDateTime,
T.TransT_dtmRealTransTime

union all 


-- CO Counter
SELECT
CinOperator_strHOOperatorCode cinema,
I.TransI_lgnNumber transaction_number,
I.TransI_dtmDateTime transaction_date,
I.TransI_dtmRealTransTime real_transaction_date,
T.Item_strItemId as item,
Item_strItemDescription as item_name,
0 as bo_quantity,
0 as bo_unit_price,
0 as bo_gross,
0 as bo_tax,
0 as bo_net,
sum(TransI_decNoOfItems) as co_quantity,
TransI_curValueEach co_unit_price,
SUM(Case ISNULL(Item_curSaleUOMConv, 0) WHEN 0 THEN --handle divide by zero
            Round((IsNull(TransI_decNoOfItems, (TransI_decNoOfItems / 1)) * TransI_curValueEach), 6)
        ELSE --this is the typical path
            Round((IsNull(TransI_decNoOfItems, (TransI_decNoOfItems / 1)) * TransI_curValueEach), 6)
        END) as 'co_gross',
ROUND(SUM(  Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach,0))  ,6)+ 
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach2,0)) ,6)+
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach3,0)) ,6)+ 
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach4,0)) ,6)    
        ),2) as 'co_tax',				
ROUND(SUM(Case Item_curSaleUOMConv WHEN 0 THEN
        (Round((TransI_decNoOfItems * TransI_curValueEach)             ,6) - 
        (  Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach,0))  ,6)+ 
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach2,0)) ,6)+
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach3,0)) ,6)+ 
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach4,0)) ,6)    
        ))
                ELSE
        (Round((TransI_decNoOfItems * TransI_curValueEach)             ,6) - 
        (  Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach,0))  ,6)+ 
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach2,0)) ,6)+
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach3,0)) ,6)+ 
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach4,0)) ,6)    
        ))
    END),2) 'co_net'
FROM tblTrans_Inventory I , tblItem T, tblCinema_Operator Cin  , tblSalesTax ST  , tblStock_Location SL
WHERE I.Item_strItemId = T.Item_strItemId 
AND Cin.CinOperator_strCode = I.CinOperator_strCode 
AND T.STax_strCode = ST.STax_strCode
AND I.Location_strCode = SL.Location_strCode
AND I.TransI_strType = 'S' AND I.TransI_strStatus <> 'W' --AND T.Item_strReport <> 'Y'
AND I.TransI_dtmDateTime >= @from
AND I.TransI_dtmDateTime <=  @to
group by Cin.CinOperator_strCode,CinOperator_strHOOperatorCode,T.Item_strItemId,TransI_curValueEach,Item_strItemDescription,I.TransI_lgnNumber,I.TransI_dtmDateTime,
I.TransI_dtmRealTransTime

-- code update 14/11/2024
-- code new
declare @from datetime, @to datetime 
set @from = '2024-09-02 00:00:00'
set @to = '2024-09-03 00:00:00'

select *
from 
(
SELECT 
CinOperator_strHOOperatorCode cinema,
T.TransT_lgnNumber transaction_number,
T.TransT_intSequence transaction_seq,
T.TransT_intSeqRefunded transaction_refund_seq,
T.TransT_dtmDateTime transaction_date,
T.TransT_dtmRealTransTime real_transaction_date,
TT.TType_strHOCode itemHOCode,
TT.TType_strDescription item_name,
sum(T.TransT_intNoOfSeats) as bo_quantity,
T.TransT_curValueEach bo_unit_price, 
((ISNULL( SUM( CASE WHEN T.TransT_curRedempValueEach = 0 THEN TransT_intNoOfSeats * TransT_curValueEach ELSE 0 END ), 0 )) + ISNULL( SUM( CASE WHEN T.TransT_curRedempValueEach = 0 THEN 0
                                             ELSE T.TransT_intNoOfSeats * T.TransT_curRedempValueEach
                                             END ), 0 )) 'bo_gross',
sum(TransT_curTaxAmount + ISNULL(TransT_curTaxAmount2,0) + ISNULL(TransT_curTaxAmount3,0) + ISNULL(TransT_curTaxAmount4,0)) as 'bo_tax',
SUM((ISNULL( ( CASE WHEN T.TransT_curRedempValueEach = 0 THEN TransT_intNoOfSeats * ( TransT_curValueEach - TransT_curTaxAmount -
ISNULL(TransT_curTaxAmount2,0) - ISNULL(TransT_curTaxAmount3,0) - ISNULL(TransT_curTaxAmount4,0) ) ELSE 0 END ), 0 ) 
+
ISNULL( ( CASE WHEN T.TransT_curRedempValueEach = 0 THEN 0 ELSE T.TransT_intNoOfSeats * ( TransT_curRedempValueEach - TransT_curRedempTaxEach -
ISNULL(TransT_curRedempTaxEach2,0) - ISNULL(TransT_curRedempTaxEach3,0) - ISNULL(TransT_curRedempTaxEach4,0) ) END ), 0 )
)) as 'bo_net',
0 as co_quantity,
0 as co_unit_price,
0 as co_gross,
0 as co_tax,
0 as co_net
FROM tblTrans_Ticket T
INNER JOIN tblTicketType TT ON TT.TType_strCode = T.Price_strCode
INNER JOIN tblCinema_Operator Cin ON Cin.CinOperator_strCode = T.CinOperator_strCode
LEFT JOIN tblPrice P ON T.PGroup_strCode = P.PGroup_strCode AND T.Price_strCode = P.Price_strCode
WHERE  T.TransT_dtmDateTime >= @from
AND  T.TransT_dtmDateTime <= @to
group by CinOperator_strHOOperatorCode,TT.TType_strHOCode,TT.TType_strDescription,T.TransT_curValueEach,T.TransT_lgnNumber,T.TransT_dtmDateTime,
T.TransT_dtmRealTransTime, T.TransT_intSequence, T.TransT_intSeqRefunded

union all 


-- CO Counter
SELECT
CinOperator_strHOOperatorCode cinema,
I.TransI_lgnNumber transaction_number,
I.TransI_intSequence transaction_seq, 
I.TransI_intSeqRefunded transaction_refund_seq,
I.TransI_dtmDateTime transaction_date,
I.TransI_dtmRealTransTime real_transaction_date,
T.Item_strMasterItemCode as itemHOCode,
Item_strItemDescription as item_name,
0 as bo_quantity,
0 as bo_unit_price,
0 as bo_gross,
0 as bo_tax,
0 as bo_net,
sum(TransI_decNoOfItems) as co_quantity,
TransI_curValueEach co_unit_price,
SUM(Case ISNULL(Item_curSaleUOMConv, 0) WHEN 0 THEN --handle divide by zero
            Round((IsNull(TransI_decNoOfItems, (TransI_decNoOfItems / 1)) * TransI_curValueEach), 6)
        ELSE --this is the typical path
            Round((IsNull(TransI_decNoOfItems, (TransI_decNoOfItems / 1)) * TransI_curValueEach), 6)
        END) as 'co_gross',
ROUND(SUM(  Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach,0))  ,6)+ 
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach2,0)) ,6)+
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach3,0)) ,6)+ 
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach4,0)) ,6)    
        ),2) as 'co_tax',				
ROUND(SUM(Case Item_curSaleUOMConv WHEN 0 THEN
        (Round((TransI_decNoOfItems * TransI_curValueEach)             ,6) - 
        (  Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach,0))  ,6)+ 
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach2,0)) ,6)+
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach3,0)) ,6)+ 
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach4,0)) ,6)    
        ))
                ELSE
        (Round((TransI_decNoOfItems * TransI_curValueEach)             ,6) - 
        (  Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach,0))  ,6)+ 
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach2,0)) ,6)+
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach3,0)) ,6)+ 
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach4,0)) ,6)    
        ))
    END),2) 'co_net'
FROM tblTrans_Inventory I , tblItem T, tblCinema_Operator Cin  , tblSalesTax ST  , tblStock_Location SL
WHERE I.Item_strItemId = T.Item_strItemId 
AND Cin.CinOperator_strCode = I.CinOperator_strCode 
AND T.STax_strCode = ST.STax_strCode
AND I.Location_strCode = SL.Location_strCode
AND I.TransI_strType = 'S' AND I.TransI_strStatus <> 'W' --AND T.Item_strReport <> 'Y'
AND I.TransI_dtmDateTime >= @from
AND I.TransI_dtmDateTime <=  @to
group by Cin.CinOperator_strCode,CinOperator_strHOOperatorCode,T.Item_strMasterItemCode,TransI_curValueEach,Item_strItemDescription,I.TransI_lgnNumber,I.TransI_dtmDateTime,I.TransI_dtmRealTransTime,I.TransI_intSequence, I.TransI_intSeqRefunded
) A 
order by A.transaction_number




-- code update 28/11/2024
DECLARE @fromdate datetime, @todate datetime, @closedbusinesstime datetime, @closedtime datetime
SET @closedbusinesstime = DATEADD(HOUR,0,CONVERT(VARCHAR(10), GETDATE()-1,110))
SET @fromdate = DATEADD(HOUR,6,CONVERT(VARCHAR(10), GETDATE()-1,110))
SET @todate = DATEADD(HOUR,6,CONVERT(VARCHAR(10), GETDATE(),110))

-- Get Closing Date
SELECT @closedtime = DCJ_dtmCreated FROM tblDailyCashJournal WHERE DCJ_dtmBusinessDate = @closedbusinesstime AND DCJ_strStatus = 'C'

-- Drop temp Table if exist 
IF OBJECT_ID('tempdb..#tempTransCash') IS NOT NULL
BEGIN
    DROP TABLE #tempTransCash
END

-- Get All Transactions in Date Range 
SELECT DISTINCT TransC_lgnNumber 
INTO #tempTransCash
FROM tblTrans_Cash WITH (INDEX=indDateTime) WHERE TransC_dtmDateTime >= @fromdate AND TransC_dtmDateTime < @todate

-- Main query
SELECT 
right(Cin.CinOperator_strCode,4) as cinemaCode,
T.TransT_lgnNumber as transactionNumber,
T.TransT_intSequence as transactionSeq,
T.TransT_intSeqRefunded as transactionRefundSeq,
@closedtime as closingDate,
Session_dtmShowing as redeemDate,
T.TransT_dtmDateTime as transactionDate,
T.TransT_dtmRealTransTime as realTransactionDate,
F.Film_strHOFilmCode as productHOCode,
F.Film_strTitle as productName,
'BO' as typeProduct,
TT.TType_strHOCode itemHOCode, 
TT.TType_strDescription as itemName,
T.TransT_intNoOfSeats as quantity,
T.TransT_curValueEach as unitPrice, 
'Ticket' as donViTinh,
(ISNULL( ( CASE WHEN T.TransT_curRedempValueEach = 0 THEN TransT_intNoOfSeats * TransT_curValueEach ELSE 0 END ), 0 )) as gross,

(TransT_intNoOfSeats * (TransT_curTaxAmount + ISNULL(TransT_curTaxAmount2,0) + ISNULL(TransT_curTaxAmount3,0) + ISNULL(TransT_curTaxAmount4,0))) as tax,

ISNULL( ( CASE WHEN T.TransT_curRedempValueEach = 0 THEN TransT_intNoOfSeats * ( TransT_curValueEach - TransT_curTaxAmount -
ISNULL(TransT_curTaxAmount2,0) - ISNULL(TransT_curTaxAmount3,0) - ISNULL(TransT_curTaxAmount4,0) ) ELSE 0 END ), 0 ) as net,
case 
	when TransT_strType = 'A' and TransT_strStatus = 'C' then 'RefundPortion'
	when TransT_strType = 'P' and TransT_strStatus = 'V' then 'Sold'
	when TransT_strType = 'P' and TransT_strStatus = 'R' then 'TicketRefunded'
end	 as status
FROM tblTrans_Ticket T
INNER JOIN tblTicketType TT ON TT.TType_strCode = T.Price_strCode
INNER JOIN tblCinema_Operator Cin ON Cin.CinOperator_strCode = T.CinOperator_strCode
LEFT JOIN tblPrice P ON T.PGroup_strCode = P.PGroup_strCode AND T.Price_strCode = P.Price_strCode
LEFT JOIN tblSession S ON T.Session_lngSessionId = S.Session_lngSessionId
LEFT JOIN tblFilm F ON S.Film_strCode = F.Film_strCode
WHERE T.TransT_lgnNumber IN (SELECT * FROM #tempTransCash)

UNION ALL 

-- CO Counter
SELECT
right(Cin.CinOperator_strCode,4) as cinemaCode,
I.TransI_lgnNumber transactionNumber,
I.TransI_intSequence transactionSeq, 
I.TransI_intSeqRefunded transactionRefundSeq,
@closedtime as closingDate,
case when Session_dtmShowing is null then I.TransI_dtmDateTime else Session_dtmShowing end as redeemDate,
I.TransI_dtmDateTime as transactionDate,
I.TransI_dtmRealTransTime as realTransactionDate,
T.Item_strMasterItemCode as productHOCode,
Item_strItemDescription as productName,
IC.Class_strDescription as typeProduct,
Item_strItemDescription as itemHOCode,
IC.Class_strDescription as itemName,
TransI_decNoOfItems as quantity,
TransI_curValueEach unitPrice,
UOM.Unit_strDescription as donViTinh,
(Case ISNULL(Item_curSaleUOMConv, 0) WHEN 0 THEN --handle divide by zero
            Round((IsNull(TransI_decNoOfItems, (TransI_decNoOfItems / 1)) * TransI_curValueEach), 6)
        ELSE --this is the typical path
            Round((IsNull(TransI_decNoOfItems, (TransI_decNoOfItems / 1)) * TransI_curValueEach), 6)
        END) as gross,
ROUND((  Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach,0))  ,6) + 
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach2,0)) ,6) +
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach3,0)) ,6) + 
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach4,0)) ,6)    
        ),2) as tax,				
ROUND((Case Item_curSaleUOMConv WHEN 0 THEN
        (Round((TransI_decNoOfItems * TransI_curValueEach)             ,6) - 
        (  Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach,0))  ,6) + 
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach2,0)) ,6) +
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach3,0)) ,6) + 
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach4,0)) ,6)    
        ))
                ELSE
        (Round((TransI_decNoOfItems * TransI_curValueEach)             ,6) - 
        (  Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach,0))  ,6) + 
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach2,0)) ,6) +
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach3,0)) ,6) + 
             Round((TransI_decNoOfItems * ISNULL(TransI_curSTaxEach4,0)) ,6)    
        ))
    END),2) net,
case when I.TransI_strStatus = 'R' then 'CORefunded' else 'Sold' end as status
FROM tblTrans_Inventory I
INNER JOIN tblItem T ON I.Item_strItemId = T.Item_strItemId 
INNER JOIN tblItem_Class IC ON T.Class_strCode = IC.Class_strCode
INNER JOIN tblCinema_Operator Cin ON Cin.CinOperator_strCode = I.CinOperator_strCode 
INNER JOIN tblSalesTax ST ON T.STax_strCode = ST.STax_strCode
INNER JOIN tblStock_Location SL ON I.Location_strCode = SL.Location_strCode
LEFT JOIN tblUnitOfMeasure UOM ON T.Item_strBaseUOMCode = UOM.Unit_strCode
LEFT JOIN tblSession S ON I.TransI_lngSessionId = S.Session_lngSessionId
WHERE 1=1
AND I.TransI_strType = 'S' AND I.TransI_strStatus <> 'W'
AND I.TransI_lgnNumber IN (SELECT * FROM #tempTransCash)



-----##################### Receipt Summary theo Transaction ############################
DECLARE @fromdate datetime, @todate datetime
SET @fromdate = DATEADD(HOUR,6,CONVERT(VARCHAR(10), GETDATE()-1,110))
SET @todate = DATEADD(HOUR,6,CONVERT(VARCHAR(10), GETDATE(),110))

Select 
right(cash.CinOperator_strCode,4) as cinemaCode,
cash.TransC_lgnNumber as transactionNumber,
cash.TransC_intSequence as transactionSeq,
(CASE  WHEN cash.TransC_strBKCardType = '' OR cash.TransC_strBKCardType IS NULL OR UPPER(cash.TransC_strBKCardType) = 'OTHER' OR UPPER(cash.TransC_strBKCardType) = 'UNKNOWN' 
						THEN ISNULL((Select top 1 UPPER(Card_strCardType)
						from tblCardDefinition 
						where Left(cash.TransC_strBKCardNo,6) >= Card_strStartRange 
						AND left(cash.TransC_strBKCardNo,6) < Card_strEndRange 
						AND Upper(Card_strPaymentCard) = 'Y' 
						AND (cash.TransC_strBKCardNo <> ''
						OR   cash.TransC_strBKCardNo IS NOT NULL)
						order by Card_intRangeSize Asc) , 'UNKNOWN')
						ELSE UPPER(cash.TransC_strBKCardType) END) as paymentType,
cash.TransC_strPaymentTransRef as paymentTransRef,					
cash.TransC_curValue as gross
From tblTrans_Cash cash WITH (INDEX=indDateTime), tblPaymentType pay
Where 1=1
AND cash.TransC_dtmDateTime BETWEEN @fromdate AND @todate 
AND cash.TransC_strType = pay.PayType_strType	
AND 'Y' IN ( pay.PayType_strCreditCard, pay.PayType_strDebitCard )

union all 

SELECT 	
right(cash.CinOperator_strCode,4) as cinemaCode,
cash.TransC_lgnNumber as transactionNumber,
cash.TransC_intSequence as transactionSeq,
tblPaymentType.PayType_strDescription as paymentType,
cash.TransC_strPaymentTransRef as paymentTransRef,					
cash.TransC_curValue as gross
FROM tblTrans_Cash cash WITH (INDEX=indDateTime), tblPaymentType
WHERE 1=1
AND cash.TransC_strType = tblPaymentType.PayType_strType
AND cash.TransC_dtmDateTime BETWEEN @fromdate AND @todate
AND 'Y' NOT IN ( tblPaymentType.PayType_strCreditCard, tblPaymentType.PayType_strDebitCard )
