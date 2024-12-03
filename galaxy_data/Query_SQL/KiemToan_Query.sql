-- BO 
SELECT 
CinOperator_strHOOperatorCode,
convert(nvarchar(6),S.Session_dtmRealShow,112) month_key,
sum(T.TransT_intNoOfSeats) as admits,
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
WHERE  S.Session_dtmRealShow >= '2023-01-01 06:00:00.000' 
AND  S.Session_dtmRealShow <= '2024-01-01 06:00:00.000'  
group by CinOperator_strHOOperatorCode,convert(nvarchar(6),S.Session_dtmRealShow,112)
order by convert(nvarchar(6),S.Session_dtmRealShow,112)


-- CO 
SELECT
CinOperator_strHOOperatorCode,
convert(nvarchar(6),I.TransI_dtmDateTime, 112) month_key,
sum(TransI_decNoOfItems) as Quantity,
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
FROM tblTrans_Inventory I , tblItem T, tblCinema_Operator Cin 
WHERE I.Item_strItemId = T.Item_strItemId 
AND Cin.CinOperator_strCode = I.CinOperator_strCode 
AND I.TransI_strType = 'S' AND I.TransI_strStatus <> 'W' AND T.Item_strReport <> 'Y'
AND I.TransI_dtmDateTime >= '2023-01-01 06:00:00.000'
AND I.TransI_dtmDateTime <=  '2024-01-01 06:00:00.000' -- input todate
group by CinOperator_strHOOperatorCode,convert(nvarchar(6),I.TransI_dtmDateTime, 112)