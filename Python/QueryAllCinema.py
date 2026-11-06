import pyodbc
import pandas as pd
import logging
from openpyxl import load_workbook

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Connection parameters (shared across all servers)
database = 'VISTA'  #database name
username = 'sa'  #username
password = 'GaLaXyNDNTTB126'  #password
timeout = 30  # Connection timeout in seconds

# List of servers to query
servers = [
    '10.20.30.116',  # Nguyen Du
    '10.20.30.118',  # Tan Binh
    '10.20.30.119',  # Kinh Duong Vuong
    '10.20.30.120',  # Quang Trung
    '10.20.30.130',  # Ben tre
    '10.20.30.132',  # Long Bien
    '10.20.30.133',  # Da Nang
    '10.20.30.134',  # Ca mau
    '10.20.30.135',  # Trung Chanh
    '10.20.30.137',  # Huynh Tan Phat
    '10.20.30.138',  # Vinh
    '10.20.30.139',  # Hai Phong
    '10.20.30.140',  # Nguyen Van Qua
    '10.20.30.142',  # Buon Ma Thuot
    '10.20.30.143',  # Long Xuyen
    '10.20.30.144',  # Linh Trung
    '10.20.30.145',  # Nha Trang
    '10.20.30.146',  # Truong Chinh
    '10.20.30.147',  # Ba Ria - Vung Tau
    '10.20.30.148',  # Thiso-Sala
    '10.20.30.150',  # parmall
    '10.20.30.149',  # hue
    '10.20.30.151',  # phan huy ich
    '10.20.30.152',  # gold coast nha trang
    ]

# SQL query (modify as needed)
query = """
SELECT
			
			
			A.CinOperator_strHOOperatorCode,
			A.Title,
			SUM(A.Admits) as 'Admits',
			sum(A.Amount) as 'Amount',
			--sum(A.Amount_Net) as 'Amount_Net',
			SUM(A.Capacity) as 'Capacity',
			SUM(A.Session) as 'Session'
			FROM
			(
			SELECT
			c.CinOperator_strCode,
			c.CinOperator_strHOOperatorCode,
			S.Film_strCode,
			f.Film_strTitle as 'Title',
			f.Film_dtmOpeningDate,
			ISNULL(S.Session_dtmRevenueDateTime, S.Session_dtmRealShow) as 'RealShow',
			ISNULL(Sum(ISNULL(T.TransT_intNoOfSeats,0)),0) as 'Admits',
			--SUM(TransT_intNoOfSeats * (CASE WHEN T.TransT_curRedempValueEach <> 0 THEN T.TransT_curRedempValueEach ELSE T.TransT_curValueEach END)) as 'Amount',
			SUM(
			 ISNULL( ( CASE WHEN T.TransT_curRedempValueEach = 0 THEN TransT_intNoOfSeats * ( TransT_curValueEach - TransT_curTaxAmount -
				ISNULL(TransT_curTaxAmount2,0) - ISNULL(TransT_curTaxAmount3,0) - ISNULL(TransT_curTaxAmount4,0) ) ELSE 0 END ), 0 )
				+
			 ISNULL( ( CASE WHEN T.TransT_curRedempValueEach = 0 THEN 0 ELSE T.TransT_intNoOfSeats * ( TransT_curRedempValueEach - TransT_curRedempTaxEach -
				ISNULL(TransT_curRedempTaxEach2,0) - ISNULL(TransT_curRedempTaxEach3,0) - ISNULL(TransT_curRedempTaxEach4,0) ) END ), 0 )
			 ) Amount,
			0 as 'Capacity',
			0 as 'Session'
			FROM tblTrans_Ticket T, tblSession S, tblFilm f, tblCinema_Operator c
			WHERE T.Session_lngSessionId = S.Session_lngSessionId
			and S.Film_strCode = f.Film_strCode and T.CinOperator_strCode = c.CinOperator_strCode
			AND  ISNULL(S.Session_dtmRevenueDateTime, S.Session_dtmRealShow) >= DATEADD(HOUR,6,CONVERT(VARCHAR(10), GETDATE()-20,110))
			--AND ISNULL(S.Session_dtmRevenueDateTime, S.Session_dtmRealShow)  < dateadd(ms, -3, (dateadd(day, +1, convert(varchar, GETDATE(), 101))))
			AND S.Session_strStatus IN ('O', 'C', 'I', 'U', 'X')
			AND f.HOPK = 'HO00003176'
			group by f.Film_strTitle,c.CinOperator_strHOOperatorCode,c.CinOperator_strCode,f.Film_dtmOpeningDate,ISNULL(S.Session_dtmRevenueDateTime, S.Session_dtmRealShow),S.Film_strCode
 
			UNION ALL
 
			SELECT
			c.CinOperator_strCode,
			c.CinOperator_strHOOperatorCode,
			s.Film_strCode,
			f.Film_strTitle as 'Title',
			f.Film_dtmOpeningDate,
			ISNULL(s.Session_dtmRevenueDateTime, s.Session_dtmRealShow) as 'RealShow',
			0 as 'Admits',
			--0 as 'Amount',
			0 as 'Amount',
			ISNULL(SUM(ISNULL(s.Session_intSeatsAvail, 0) + ISNULL(s.Session_intSeatsSold, 0)+ ISNULL(s.Session_intSeatsHeld, 0) + ISNULL(s.Session_intSeatsHouse, 0)) , 0) as 'Capacity',
			count(s.Session_dtmRealShow) as 'Session'
			FROM tblSession s, tblFilm f, tblCinema_Operator c
			WHERE s.Film_strCode = f.Film_strCode and c.CinOperator_strCode = s.CinOperator_strCode
			and ISNULL(s.Session_dtmRevenueDateTime, s.Session_dtmRealShow) >=  DATEADD(HOUR,6,CONVERT(VARCHAR(10), GETDATE()-20,110))
			--AND ISNULL(s.Session_dtmRevenueDateTime, s.Session_dtmRealShow)  <  dateadd(ms, -3, (dateadd(day, +1, convert(varchar, GETDATE(), 101))))
			AND s.Session_strStatus IN ('C', 'O', 'X')
			AND f.HOPK = 'HO00003176'
			group by f.Film_strTitle,f.Film_dtmOpeningDate,c.CinOperator_strCode,c.CinOperator_strHOOperatorCode,ISNULL(s.Session_dtmRevenueDateTime, s.Session_dtmRealShow),s.Film_strCode
			) as A
			group by
			A.CinOperator_strHOOperatorCode,
			A.Title

        """ #Query

# List to store results
all_results = []

# Loop through each server and run the query
for server in servers:
    try:
        # Create connection string for each server, but use the same database
        conn_str = f'DRIVER={{SQL Server}};SERVER={server};DATABASE={database};UID={username};PWD={password};timeout={timeout}'
        
        # Use context manager for automatic connection handling
        with pyodbc.connect(conn_str) as connection:
            with connection.cursor() as cursor:
                
                # Execute the query with parameter
                cursor.execute(query)
                
                # Fetch all results
                columns = [desc[0] for desc in cursor.description]  # Get column names
                rows = cursor.fetchall()  # Fetch all rows

                # Convert results to a DataFrame
                df = pd.DataFrame.from_records(rows, columns=columns)

                # Add the server name as a new column to identify the source of the data
                df['Server'] = server

                # Exclude empty or all-NA DataFrames
                if not df.empty and not df.dropna(how='all').empty:
                    all_results.append(df)

    except pyodbc.Error as e:
        logging.error(f"Error querying {server}: {e}")

# Combine results from all servers into a single DataFrame
if all_results:
    combined_df = pd.concat(all_results, ignore_index=True)

    # Write the DataFrame to an Excel file
    excel_file = 'E:\\mualua.xlsx'
    combined_df.to_excel(excel_file, index=False)

    # Load the workbook and get the active sheet
    wb = load_workbook(excel_file)
    ws = wb.active

    # Auto-adjust column widths based on the length of the data and headers
    for column in ws.columns:
        max_length = 0
        column_letter = column[0].column_letter  # Get column letter (e.g., 'A', 'B')
        
        # Calculate the max length of the column header and the data
        for cell in column:
            try:
                if cell.value:
                    max_length = max(max_length, len(str(cell.value)))
            except:
                pass
        adjusted_width = max_length + 2  # Add some extra space
        ws.column_dimensions[column_letter].width = adjusted_width

    # Save the workbook with adjusted column widths
    wb.save(excel_file)

    logging.info(f"Results exported and columns adjusted in {excel_file}")
else:
    logging.info("No results to export")