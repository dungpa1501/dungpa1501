
-- code check ho banking monthly

select 
CinOperator_strCode,	HOBank_dtmBusinessDate,	UPPER(case when Card_strCardType = 'VNPAYQR' then 'VNPAYPAY' else Card_strCardType end) Card_strCardType, sum(amt) amt
from 
(	
select CinOperator_strCode,HOBank_dtmBusinessDate,
Card_strCardType_1 Card_strCardType
,sum(HOBank_curAmount) amt 
from (select *,case when HOBank_strCardNumber = '400002......0000' then 'HSBC-Visa/Master' 
		 when HOBank_strCardNumber = '400000......0000' then 'HSBC-ATM' 
		 else Card_strCardType END as Card_strCardType_1 from tblHOBanking) tblHOBanking where HOBank_dtmBusinessDate >= '2024-04-01' and HOBank_dtmBusinessDate < '2024-04-02' 
group by Card_strCardType_1,CinOperator_strCode,HOBank_dtmBusinessDate
) A
where A.amt <> 0  
group by CinOperator_strCode,	HOBank_dtmBusinessDate,	UPPER(case when Card_strCardType = 'VNPAYQR' then 'VNPAYPAY' else Card_strCardType end)
order by A.CinOperator_strCode,HOBank_dtmBusinessDate


-- export receipt summary each site 

declare @cinema nvarchar(100)
set @cinema = (select CinOperator_strCode from tblCinema_Operator)
exec spRptReceiptsSummary @fromdate = '2022-09-01 06:00.000', @todate = '2022-10-01 06:00.000', @GroupByCinOperator = @cinema
SELECT 
	CAST ( strCinOperatorCode AS nvarchar ( 100 ) ) AS strCinOperatorCode,
	CAST ( CinOperator_strName AS nvarchar ( 100 ) ) AS CinOperator_strName,
	CAST ( RS_strTenderCategory AS nvarchar ( 100 ) ) AS RS_strTenderCategory,
	SUM ( RS_curTranValue ) amt 
FROM
	tblRptReceiptSum 
WHERE
	RS_strWGroupDesc = 'TOTALS' 
	AND RS_strType = 'N' 
GROUP BY
	strCinOperatorCode,
	CinOperator_strName,
	RS_strTenderCategory
	
	
-- Code import receipt summary theo daily
--create table if not exists
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblGlx_HoBankingCheck')
BEGIN
		create table tblGlx_HoBankingCheck
		(
			datetime datetime,	
			strCinOperatorCode nvarchar(100),	
			CinOperator_strName nvarchar(100),	
			RS_strTenderCategory nvarchar(100),	
			amt money
		)
END

declare @fromdate datetime		
	set @fromdate = DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(DAY, -1, GETDATE())), '06:00:00')

declare @todate datetime		
	set @todate = DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(DAY, 0, GETDATE())), '06:00:00')

declare @todateEnd datetime		
	set @todateEnd = DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), '06:00:00')
	
declare @cinema nvarchar(100)
set @cinema = (select CinOperator_strCode from tblCinema_Operator)	

WHILE @fromdate < @todateEnd
BEGIN

	delete tbl_GLX_ReceiptSum
	-- Code here 
	exec spRptReceiptsSummary @fromdate, @todate , @GroupByCinOperator = @cinema
	
	--insert to table
	insert into tblGlx_HoBankingCheck
	SELECT 
		@fromdate as datetime,
		CAST ( strCinOperatorCode AS nvarchar ( 100 ) ) AS strCinOperatorCode,
		CAST ( CinOperator_strName AS nvarchar ( 100 ) ) AS CinOperator_strName,
		CAST ( RS_strTenderCategory AS nvarchar ( 100 ) ) AS RS_strTenderCategory,
		SUM ( RS_curTranValue ) amt 
	FROM
		tblRptReceiptSum 
	WHERE
		RS_strWGroupDesc = 'TOTALS' 
		AND RS_strType = 'N' 
	GROUP BY
		strCinOperatorCode,
		CinOperator_strName,
		RS_strTenderCategory

	--Inscreat increase Increase
	SET @todate = DATEADD(day, 1, @todate);
	SET @fromdate = DATEADD(day, 1, @fromdate);
END;


-- select table o rap
select
case when upper(RS_strTenderCategory) = 'VNPAY-QR' then concat(replace('VNPAYPAY',' ',''),format(datetime,'yyyyMMdd'),strCinOperatorCode)
		when upper(RS_strTenderCategory) = 'ZALOPAY-QR' then concat(replace('ZALOPAYPAY',' ',''),format(datetime,'yyyyMMdd'),strCinOperatorCode)
else concat(replace(RS_strTenderCategory,' ',''),format(datetime,'yyyyMMdd'),strCinOperatorCode) end comp, amt
from tblGlx_HoBankingCheck

