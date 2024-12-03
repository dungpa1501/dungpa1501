
			SELECT 
			Screen_strName,
			cs.Screen_bytNum,
			cast(ISNULL(S.Session_dtmRevenueDateTime, S.Session_dtmRealShow) as date) datekey,
			ISNULL(Sum(ISNULL(T.TransT_intNoOfSeats,0)),0) as 'Admits'
			FROM tblTrans_Ticket T, tblSession S, tblFilm f, tblCinema_Operator c, tblCinema_Screen cs
			WHERE T.Session_lngSessionId = S.Session_lngSessionId
			and S.Screen_bytNum = cs.Screen_bytNum
			and S.Film_strCode = f.Film_strCode and T.CinOperator_strCode = c.CinOperator_strCode
			AND  ISNULL(S.Session_dtmRevenueDateTime, S.Session_dtmRealShow) >= '2024-06-06 06:00:00' --DATEADD(HOUR,6,CONVERT(VARCHAR(10), GETDATE()-1,110))
			AND ISNULL(S.Session_dtmRevenueDateTime, S.Session_dtmRealShow)  < '2024-07-01 06:00:00'--dateadd(ms, -3, (dateadd(day, +1, convert(varchar, GETDATE(), 101))))
			AND S.Session_strStatus IN ('O', 'C', 'I', 'U', 'X')
			and cs.Screen_bytNum not in (2,3)
			group by Screen_strName,cs.Screen_bytNum,cast(ISNULL(S.Session_dtmRevenueDateTime, S.Session_dtmRealShow) as date)
			order by Screen_strName,cs.Screen_bytNum,cast(ISNULL(S.Session_dtmRevenueDateTime, S.Session_dtmRealShow) as date)