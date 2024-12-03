select a.CinOperator_strCode,b.CinOperator_strHOOperatorCode,
format(TransT_dtmDateTime,'yyyy-MM') monthYear,
sum(ABS(TransT_intNoOfSeats)) admissions,
sum(TransT_curValueEach*abs(TransT_intNoOfSeats)) gross_amt
from tblTrans_Ticket a 
join tblCinema_Operator b on a.CinOperator_strCode = b.CinOperator_strCode
where TransT_strStatus = 'C' and TransT_strType = 'A'
and year(TransT_dtmDateTime) >= 2022
group by format(TransT_dtmDateTime,'yyyy-MM'),a.CinOperator_strCode,CinOperator_strHOOperatorCode