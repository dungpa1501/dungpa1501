import pyodbc
import pandas as pd
import logging
from openpyxl import load_workbook
from openpyxl.utils import get_column_letter

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Connection parameters
database = 'VISTA'
username = 'sa'
password = 'GaLaXyNDNTTB126'
timeout = 30

# Server list
servers = [
    ('10.20.30.116', 'Nguyen Du'),
    ('10.20.30.118', 'Tan Binh'),
    ('10.20.30.119', 'Kinh Duong Vuong'),
    ('10.20.30.120', 'Quang Trung'),
    ('10.20.30.130', 'Ben Tre'),
    ('10.20.30.132', 'Long Bien'),
    ('10.20.30.133', 'Da Nang'),
    ('10.20.30.134', 'Ca Mau'),
    ('10.20.30.135', 'Trung Chanh'),
    ('10.20.30.137', 'Huynh Tan Phat'),
    ('10.20.30.138', 'Vinh'),
    ('10.20.30.139', 'Hai Phong'),
    ('10.20.30.140', 'Nguyen Van Qua'),
    ('10.20.30.142', 'Buon Ma Thuot'),
    ('10.20.30.143', 'Long Xuyen'),
    ('10.20.30.144', 'Linh Trung'),
    ('10.20.30.145', 'Nha Trang'),
    ('10.20.30.146', 'Truong Chinh'),
    ('10.20.30.147', 'Ba Ria - Vung Tau'),
    ('10.20.30.148', 'Thiso-Sala'),
    ('10.20.30.150', 'Parmall'),
    ('10.20.30.149', 'Hue'),
    ('10.20.30.151', 'Phan Huy Ich'),
    ('10.20.30.152', 'Gold Coast Nha Trang'),
]

# Query
query = """
with cte as 
(
select distinct TransC_lgnNumber from tblTrans_Cash where TransC_strBKCardNo = '111111......1111'
)
-- -- BO 
-- SELECT 
-- CinOperator_strHOOperatorCode Cinema,
-- year(S.Session_dtmRealShow) as Year,
-- count(distinct TransC_lgnNumber) as 'BillBO',
-- sum(T.TransT_intNoOfSeats) as Admits,
-- SUM((ISNULL( ( CASE WHEN T.TransT_curRedempValueEach = 0 THEN TransT_intNoOfSeats * ( TransT_curValueEach - TransT_curTaxAmount -
-- ISNULL(TransT_curTaxAmount2,0) - ISNULL(TransT_curTaxAmount3,0) - ISNULL(TransT_curTaxAmount4,0) ) ELSE 0 END ), 0 ) 
-- +
-- ISNULL( ( CASE WHEN T.TransT_curRedempValueEach = 0 THEN 0 ELSE T.TransT_intNoOfSeats * ( TransT_curRedempValueEach - TransT_curRedempTaxEach -
-- ISNULL(TransT_curRedempTaxEach2,0) - ISNULL(TransT_curRedempTaxEach3,0) - ISNULL(TransT_curRedempTaxEach4,0) ) END ), 0 )
-- )) as 'NBO'
-- FROM   tblSession S
-- INNER JOIN tblScreen_Layout sl ON S.ScreenL_intId = sl.ScreenL_intId
-- INNER JOIN tblCinema_Screen cs ON sl.Screen_bytNum = cs.Screen_bytNum AND sl.Cinema_strCode = cs.Cinema_strCode
-- LEFT JOIN tblTrans_Ticket T ON T.Session_lngSessionId = S.Session_lngSessionId
-- INNER JOIN tblTicketType TT ON TT.TType_strCode = T.Price_strCode
-- join cte zz on zz.TransC_lgnNumber = T.TransT_lgnNumber
-- INNER JOIN tblCinema_Operator Cin ON Cin.CinOperator_strCode = T.CinOperator_strCode
-- LEFT JOIN tblPrice P ON T.PGroup_strCode = P.PGroup_strCode AND T.Price_strCode = P.Price_strCode
-- WHERE  S.Session_dtmRealShow >= '2022-01-01 06:00:00.000' -- input fromdate
-- AND  S.Session_dtmRealShow < '2025-05-01 06:00:00.000' -- input todate 
-- AND TransT_strStatus = 'V'
-- group by CinOperator_strHOOperatorCode,year(S.Session_dtmRealShow)
-- 
-- BO 
SELECT 
--CinOperator_strHOOperatorCode Cinema,
format(S.Session_dtmRealShow,'yyyy-MM') as Year,
count(distinct TransC_lgnNumber) as 'BillBO',
sum(T.TransT_intNoOfSeats) as Admits,
SUM((ISNULL( ( CASE WHEN T.TransT_curRedempValueEach = 0 THEN TransT_intNoOfSeats * ( TransT_curValueEach - TransT_curTaxAmount -
ISNULL(TransT_curTaxAmount2,0) - ISNULL(TransT_curTaxAmount3,0) - ISNULL(TransT_curTaxAmount4,0) ) ELSE 0 END ), 0 ) 
+
ISNULL( ( CASE WHEN T.TransT_curRedempValueEach = 0 THEN 0 ELSE T.TransT_intNoOfSeats * ( TransT_curRedempValueEach - TransT_curRedempTaxEach -
ISNULL(TransT_curRedempTaxEach2,0) - ISNULL(TransT_curRedempTaxEach3,0) - ISNULL(TransT_curRedempTaxEach4,0) ) END ), 0 )
)) as 'NBO'
FROM   tblSession S
INNER JOIN tblScreen_Layout sl ON S.ScreenL_intId = sl.ScreenL_intId
INNER JOIN tblCinema_Screen cs ON sl.Screen_bytNum = cs.Screen_bytNum AND sl.Cinema_strCode = cs.Cinema_strCode
LEFT JOIN tblTrans_Ticket T ON T.Session_lngSessionId = S.Session_lngSessionId
INNER JOIN tblTicketType TT ON TT.TType_strCode = T.Price_strCode
join cte zz on zz.TransC_lgnNumber = T.TransT_lgnNumber
INNER JOIN tblCinema_Operator Cin ON Cin.CinOperator_strCode = T.CinOperator_strCode
LEFT JOIN tblPrice P ON T.PGroup_strCode = P.PGroup_strCode AND T.Price_strCode = P.Price_strCode
WHERE  S.Session_dtmRealShow >= '2025-01-01 06:00:00.000' -- input fromdate
AND  S.Session_dtmRealShow < '2025-05-01 06:00:00.000' -- input todate 
AND TransT_strStatus = 'V'
group by CinOperator_strHOOperatorCode,format(S.Session_dtmRealShow,'yyyy-MM')

"""

# Excel export path
excel_file = 'E:\\admitappmomo.xlsx'

# List to collect results
all_results = []

# Loop through each server
for server, cinema_name in servers:
    try:
        conn_str = (
            f"DRIVER={{SQL Server}};"
            f"SERVER={server};"
            f"DATABASE={database};"
            f"UID={username};"
            f"PWD={password};"
            f"timeout={timeout}"
        )
        logging.info(f"Querying server {server} ({cinema_name})...")
        with pyodbc.connect(conn_str) as conn:
            df = pd.read_sql(query, conn)
            if not df.empty:
                if 'Cinema' not in df.columns:
                    df.insert(0, 'Cinema', cinema_name)
                else:
                    df['Cinema'] = cinema_name
                all_results.append((cinema_name, df))
            else:
                logging.info(f"No data for {cinema_name}")

    except pyodbc.Error as e:
        logging.error(f"Query failed for server {server} ({cinema_name}): {e}")

# Export to Excel
if all_results:
    with pd.ExcelWriter(excel_file, engine='openpyxl') as writer:
        for cinema_name, df in all_results:
            sheet_name = cinema_name[:31]  # Excel sheet name limit
            df.to_excel(writer, sheet_name=sheet_name, index=False)

    # Adjust column width
    wb = load_workbook(excel_file)
    for sheet in wb.sheetnames:
        ws = wb[sheet]
        for col in ws.columns:
            max_length = max(len(str(cell.value)) for cell in col if cell.value is not None)
            adjusted_width = max_length + 2
            ws.column_dimensions[get_column_letter(col[0].column)].width = adjusted_width
    wb.save(excel_file)

    logging.info(f"✅ Exported data to Excel: {excel_file}")
else:
    logging.info("⚠️ No data retrieved from any server.")
