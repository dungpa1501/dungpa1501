			--F&B Dashboard
			SELECT 
			concat(Inv.CinOperator_strCode,'~',I.Item_strItemId,'~',format(TransI_dtmDateTime,'yyyyMMddhh')) integration_id,
			dateadd(hour, datediff(hour, 0, TransI_dtmDateTime), 0) date_filter,
			case when WProfile_strCode not in (0004,0003) then 'CO' else  Workstation_strName end Workstation_strName,
			Location_strDescription,
			Class_strDescription,
			I.Item_strItemId, 
			Item_strItemDescription, 
			Cin.CinOperator_strCode,
			Cin.CinOperator_strHOOperatorCode,
			
			SUM(TransI_decActualNoOfItems) AS QtyCO,
			
			SUM(TransI_decActualNoOfItems * TransI_curValueEach) AS GrossCO,
			
			SUM( TransI_decActualNoOfItems * ( TransI_curValueEach - ROUND( ISNULL(Inv.TransI_curSTaxEach,0), 3 ) + ROUND( ISNULL(Inv.TransI_curSTaxEach2,0), 3 ) + ROUND( ISNULL(Inv.TransI_curSTaxEach3,0), 3 ) + ROUND( ISNULL(Inv.TransI_curSTaxEach4,0), 3 ) ) ) AS netCO,
			
			SUM( ( TransI_decActualNoOfItems * ( TransI_curValueEach - ROUND( ISNULL(Inv.TransI_curSTaxEach,0), 3 ) + ROUND( ISNULL(Inv.TransI_curSTaxEach2,0), 3 ) + ROUND( ISNULL(Inv.TransI_curSTaxEach3,0), 3 ) + ROUND( ISNULL(Inv.TransI_curSTaxEach4,0), 3 ) ) ) -
					 ( TransI_decActualNoOfItems * ( TransI_decCostEach - ROUND( ISNULL(Inv.TransI_decSTaxCostEach,0) + ISNULL(Inv.TransI_decSTaxCostEach2,0) + ISNULL(Inv.TransI_decSTaxCostEach3,0) + ISNULL(Inv.TransI_decSTaxCostEach4,0),6) ) ) ) AS Margin
			FROM  tblTrans_Inventory Inv WITH(INDEX(indTransI_Type_DateTime))
			INNER JOIN tblItem I ON I.Item_strItemId = Inv.Item_strItemId
			INNER JOIN tblItem_Class IC ON I.Class_strCode = IC.Class_strCode
			INNER JOIN tblCinema_Operator Cin on Inv.CinOperator_strCode = Cin.CinOperator_strCode
			INNER JOIN tblStock_Location SL ON SL.Location_strCode = Inv.Location_strCode
			LEFT JOIN tblWorkstation WC ON WC.Workstation_strCode = Inv.Workstation_strCode
			WHERE TransI_strType = 'S' and UPPER(Item_strReport) <> 'Y' 
			AND Inv.TransI_dtmDateTime >= DATEADD(HOUR,6,CONVERT(VARCHAR(10), GETDATE(),110))
			group by 
			concat(Inv.CinOperator_strCode,'~',I.Item_strItemId,'~',format(TransI_dtmDateTime,'yyyyMMddhh')),
			dateadd(hour, datediff(hour, 0, TransI_dtmDateTime), 0),
			case when WProfile_strCode not in (0004,0003) then 'CO' else  Workstation_strName end,
			Location_strDescription,
			Class_strDescription,
			I.Item_strItemId, 
			Item_strItemDescription, 
			Cin.CinOperator_strCode,
			Cin.CinOperator_strHOOperatorCode
			order by dateadd(hour, datediff(hour, 0, TransI_dtmDateTime), 0) asc



-- admid
			-- Lấy Admission để tính strike rate
			SELECT 
			dateadd(hour, datediff(hour, 0, S.Session_dtmRealShow), 0) as date_filter,
			sum(T.TransT_intNoOfSeats) as QtyBO
			FROM   tblSession S
			INNER JOIN tblScreen_Layout sl ON S.ScreenL_intId = sl.ScreenL_intId
			INNER JOIN tblCinema_Screen cs ON sl.Screen_bytNum = cs.Screen_bytNum AND sl.Cinema_strCode = cs.Cinema_strCode
			LEFT JOIN tblTrans_Ticket T ON T.Session_lngSessionId = S.Session_lngSessionId
			INNER JOIN tblCinema_Operator Cin ON Cin.CinOperator_strCode = T.CinOperator_strCode
			LEFT JOIN tblPrice P ON T.PGroup_strCode = P.PGroup_strCode AND T.Price_strCode = P.Price_strCode
			WHERE  S.Session_dtmRealShow >= DATEADD(HOUR,6,CONVERT(VARCHAR(10), GETDATE(),110)) AND  S.Session_dtmRealShow < GETDATE()
			group by dateadd(hour, datediff(hour, 0, S.Session_dtmRealShow), 0) 