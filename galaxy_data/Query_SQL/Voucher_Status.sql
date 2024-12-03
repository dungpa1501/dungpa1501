
select b.memberId,b.voucherCode, a.dIssuedDate, a.dExpiryDate, c.dRedeemedDate ,
case when c.dRedeemedDate is not null then 'Redeemed' 
		when a.dExpiryDate <= '2023-12-01 00:00:00.000' then 'Expired' else 'Usable' end status
from tblStock a 
join glxMemberVoucher b on a.Stock_strBarcode = b.voucherCode
left join tblRedeemed c on a.lVoucherTypeID = c.lVoucherTypeID and a.lVoucherNumber = c.lVoucherNumber and a.nDuplicateNo = c.nDuplicateNo
where a.dIssuedDate >= '2023-08-01 00:00:00.000'
order by b.memberId



-- voucher member
select memberId,VStock_strBookletIdent,Stock_strBarcode, nVoucherCode, Stock_dtmCreated ,dIssuedDate, dExpiryDate, dRedeemedDate, 
case when dRedeemedDate is not null then 'Redeemed' 
	when dExpiryDate < '2024-08-01 00:00:00.000' then 'Expired'
	else 'Usable' end status
from tblStock a 
left join tblRedeemed b on a.lVoucherTypeID = b.lVoucherTypeID and a.lVoucherNumber = b.lVoucherNumber and a.nDuplicateNo = b.nDuplicateNo
left join glxMemberVoucher c on a.Stock_strBarcode = c.voucherCode
join tblVoucherType d on a.lVoucherTypeID = d.lID
where 1=1
and dIssuedDate >= '2024-07-01 00:00:00.000'
and dIssuedDate < '2024-08-01 00:00:00.000'
--and dRedeemedDate is null 
--and (dExpiryDate >= cast(cast(getdate() as date) as datetime) or dExpiryDate is null)


-- Voucher Redeemed 
select b.memberId, a.Redeemed_strSalesChannel,  count(a.Redeemed_strScannedBarcode) total_voucherRedeemed
from tblRedeemed a 
join glxMemberVoucher b on a.Redeemed_strScannedBarcode = b.voucherCode
where dRedeemedDate >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)
and dRedeemedDate < DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
group by b.memberId, a.Redeemed_strSalesChannel
order by  count(a.Redeemed_strScannedBarcode) desc,memberId

--Voucher TV redeemed
select A.dateMonth,	A.dayOfWeek,	A.hour,	A.cinema,	A.totalVoucher,	A.mAlternatePrice 'GiaVe', (A.totalVoucher * A.mAlternatePrice) as Gross
from 
(
select 
format(c.Session_dtmRealShow,'dd-MM-yyyy') as N'dateMonth',
left(DATENAME(dw,c.Session_dtmRealShow),3) as N'dayOfWeek',
case when cast(c.Session_dtmRealShow  as TIME) >= '17:00:00' then N'Sau 17:00'
		when cast(c.Session_dtmRealShow  as TIME) < '17:00:00' then N'Trước 17:00'
		else '' end as N'hour', e.lID,
case 
	when e.lID =  2 then 'ND '
	when e.lID =  4 then 'TB '
	when e.lID =  5 then 'KDV'
	when e.lID =  6 then 'QT '
	when e.lID =  7 then 'BT '
	when e.lID =  8 then 'MIHN      '
	when e.lID =  9 then 'DN '
	when e.lID =  10 then 'CM '
	when e.lID =  11 then 'TC '
	when e.lID =  13 then 'HTP'
	when e.lID =  14 then 'VIN'
	when e.lID =  15 then 'HP '
	when e.lID =  16 then 'NVQ'
	when e.lID =  18 then 'BMT'
	when e.lID =  19 then 'LXN'
	when e.lID =  20 then 'LTR'
	when e.lID =  23 then 'NTR'
	when e.lID =  24 then 'TRC'
	when e.lID =  25 then 'BRV'
	when e.lID =  26 then 'THS'
	when e.lID =  28 then 'PAR'
else '' end 'cinema',		
count(*) totalVoucher,
c.mAlternatePrice
from tblStock a 
join tblRedeemed c on a.lVoucherTypeID = c.lVoucherTypeID and a.lVoucherNumber = c.lVoucherNumber and a.nDuplicateNo = c.nDuplicateNo
join tblVoucherType d on a.lVoucherTypeID = d.lID
join tblLocation e on c.lRedeemedLocationID = e.lID
where c.Redeemed_dtmLocalTime >= '2024-01-01 00:00:00.000' and c.Redeemed_dtmLocalTime < '2024-09-01 00:00:00.000'
and nVoucherCode = 'TV'
group by 
c.mAlternatePrice,
format(c.Session_dtmRealShow,'dd-MM-yyyy'),
left(DATENAME(dw,c.Session_dtmRealShow),3),
case when cast(c.Session_dtmRealShow  as TIME) >= '17:00:00' then N'Sau 17:00'
		when cast(c.Session_dtmRealShow  as TIME) < '17:00:00' then N'Trước 17:00'
		else '' end,e.lID,
sCode
) A 
order by A.dateMonth, A.lID


-- code issue voucher 

update tblStock
set lIssuedLocationID = 1,
dIssuedDate = cast(cast(getdate() as date) as datetime),
dExpiryDate = CAST(DATEADD(MONTH, 6, CAST(GETDATE() AS DATE)) AS DATETIME),
Stock_dtmUpdated = getdate(),
Stock_dtmValidFromDate = cast(cast(getdate() as date) as datetime),
User_intUserNoCreatedBy = 1000
where Stock_strBarcode in ('900020487674')