select code,	TransT_lgnNumber, sum(bo_qty) bo_qty, sum(bo_amt) bo_amt, sum(co_qty) co_qty, sum(co_amt) co_amt	
from 
(
select concat(TransT_lgnNumber,a.CinOperator_strCode) code,TransT_lgnNumber, sum(TransT_intNoOfSeats) bo_qty, sum(TransT_intNoOfSeats*TransT_curValueEach) bo_amt, 0 as co_qty, 0 as co_amt 
from tblTrans_Ticket a
join tblglxitemcheck b on a.TransT_lgnNumber = b.code
group by TransT_lgnNumber,concat(TransT_lgnNumber,a.CinOperator_strCode)

union all

select concat(TransI_lgnNumber,a.CinOperator_strCode) code,TransI_lgnNumber,0 as bo_qty, 0 as bo_amt, sum(TransI_decNoOfItems) co_qty, sum(TransI_decNoOfItems*TransI_curValueEach) co_amt 
from tblTrans_Inventory a 
join tblglxitemcheck b on a.TransI_lgnNumber = b.code
where TransI_strType = 'S'
group by TransI_lgnNumber,concat(TransI_lgnNumber,a.CinOperator_strCode)
) A 
group by code,	TransT_lgnNumber

