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
    ]

# SQL query (modify as needed)
query = """
declare @cinema nvarchar(100)
select @cinema = CinOperator_strHOOperatorCode from tblCinema_Operator

select @cinema rap,Item_strMasterItemCode,Item_curRetailPrice from tblItem
where Item_strMasterItemCode in
('HOICBF1BSTDVOU',
'HOICBF1BSTDKV1',
'HOICBF2BSTDVOU',
'HOICBF2BSTDKV1')

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
    excel_file = 'E:\\checkgia.xlsx'
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