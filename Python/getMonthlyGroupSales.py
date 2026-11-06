import pyodbc
import pandas as pd
from openpyxl import load_workbook
from openpyxl.styles import Font, PatternFill
from datetime import datetime

# List of server names (replace with actual server names)
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
    '10.20.30.152'  # gold coast nha trang
    ]
# Connection parameters (shared across all servers)
database = 'VISTA'  #database name
username = 'sa'  #username
password = 'GaLaXyNDNTTB126'  #password
timeout = 30  # Connection timeout in seconds

# Queries for each condition
queries = {
    "zalopaygrs": """
        -- Declare Date Range
        DECLARE @StartDate DATETIME = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0);
        DECLARE @EndDate DATETIME = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0);
        DECLARE @CardType nvarchar(20) = 'ZALOPAYGRS';
        -- Step 1: Filter transactions with ZALOPAYGRS and calculate total values
        WITH FilteredZaloPay AS (
            SELECT DISTINCT TransC_lgnNumber
            FROM tblTrans_Cash
            WHERE TransC_strBKCardType = @CardType
            AND TransC_dtmRealTransTime >= @StartDate
            AND TransC_dtmRealTransTime < @EndDate
        ),
        SummedValues AS (
            -- Step 2: Sum TransC_curValue for each filtered TransC_lgnNumber
            SELECT 
                tc.TransC_lgnNumber,
                SUM(tc.TransC_curValue) AS TotalValue
            FROM tblTrans_Cash tc
            INNER JOIN FilteredZaloPay fzp
                ON tc.TransC_lgnNumber = fzp.TransC_lgnNumber
            GROUP BY tc.TransC_lgnNumber
            HAVING SUM(tc.TransC_curValue) <> 0 -- Keep only non-zero sums
        )
        -- Step 3: Fetch detailed records for filtered transaction numbers
        SELECT
            t.CinOperator_strCode,
            t.TransC_strBKCardType,
            t.TransC_curValue,
            t.TransC_strPaymentTransRef,
            t.Workstation_strCode,
            t.TransC_lgnNumber,
            CAST(t.TransC_dtmDateTime AS DATE) AS business_date,
            t.TransC_dtmDateTime
        FROM tblTrans_Cash t
        WHERE t.TransC_lgnNumber IN (
            SELECT TransC_lgnNumber FROM SummedValues
        )
        AND t.TransC_strBKCardType = @CardType; -- Exclude APPZALO transactions""",
    "momogrs": """
        -- Declare Date Range
        DECLARE @StartDate DATETIME = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0);
        DECLARE @EndDate DATETIME = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0);
        DECLARE @CardType nvarchar(20) = 'MOMOGRS';
        -- Step 1: Filter transactions with ZALOPAYGRS and calculate total values
        WITH FilteredZaloPay AS (
            SELECT DISTINCT TransC_lgnNumber
            FROM tblTrans_Cash
            WHERE TransC_strBKCardType = @CardType
            AND TransC_dtmRealTransTime >= @StartDate
            AND TransC_dtmRealTransTime < @EndDate
        ),
        SummedValues AS (
            -- Step 2: Sum TransC_curValue for each filtered TransC_lgnNumber
            SELECT 
                tc.TransC_lgnNumber,
                SUM(tc.TransC_curValue) AS TotalValue
            FROM tblTrans_Cash tc
            INNER JOIN FilteredZaloPay fzp
                ON tc.TransC_lgnNumber = fzp.TransC_lgnNumber
            GROUP BY tc.TransC_lgnNumber
            HAVING SUM(tc.TransC_curValue) <> 0 -- Keep only non-zero sums
        )
        -- Step 3: Fetch detailed records for filtered transaction numbers
        SELECT
            t.CinOperator_strCode,
            t.TransC_strBKCardType,
            t.TransC_curValue,
            t.TransC_strPaymentTransRef,
            t.Workstation_strCode,
            t.TransC_lgnNumber,
            CAST(t.TransC_dtmDateTime AS DATE) AS business_date,
            t.TransC_dtmDateTime
        FROM tblTrans_Cash t
        WHERE t.TransC_lgnNumber IN (
            SELECT TransC_lgnNumber FROM SummedValues
        )
        AND t.TransC_strBKCardType = @CardType; -- Exclude APPZALO transactions""",
    "vnpaygrs": """
        -- Declare Date Range
        DECLARE @StartDate DATETIME = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0);
        DECLARE @EndDate DATETIME = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0);
        DECLARE @CardType nvarchar(20) = 'VNPAYGRS';
        -- Step 1: Filter transactions with ZALOPAYGRS and calculate total values
        WITH FilteredZaloPay AS (
            SELECT DISTINCT TransC_lgnNumber
            FROM tblTrans_Cash
            WHERE TransC_strBKCardType = @CardType
            AND TransC_dtmRealTransTime >= @StartDate
            AND TransC_dtmRealTransTime < @EndDate
        ),
        SummedValues AS (
            -- Step 2: Sum TransC_curValue for each filtered TransC_lgnNumber
            SELECT 
                tc.TransC_lgnNumber,
                SUM(tc.TransC_curValue) AS TotalValue
            FROM tblTrans_Cash tc
            INNER JOIN FilteredZaloPay fzp
                ON tc.TransC_lgnNumber = fzp.TransC_lgnNumber
            GROUP BY tc.TransC_lgnNumber
            HAVING SUM(tc.TransC_curValue) <> 0 -- Keep only non-zero sums
        )
        -- Step 3: Fetch detailed records for filtered transaction numbers
        SELECT
            t.CinOperator_strCode,
            t.TransC_strBKCardType,
            t.TransC_curValue,
            t.TransC_strPaymentTransRef,
            t.Workstation_strCode,
            t.TransC_lgnNumber,
            CAST(t.TransC_dtmDateTime AS DATE) AS business_date,
            t.TransC_dtmDateTime
        FROM tblTrans_Cash t
        WHERE t.TransC_lgnNumber IN (
            SELECT TransC_lgnNumber FROM SummedValues
        )
        AND t.TransC_strBKCardType = @CardType; -- Exclude APPZALO transactions""",
}

# Get last month's yyyyMM format
last_month = (datetime.now().replace(day=1) - pd.DateOffset(months=1)).strftime("%Y%m")

# Excel output file
output_file = f"E:\\GroupSales_{last_month}.xlsx"

# Dictionary to store dataframes
dfs = {key: [] for key in queries.keys()}

# Connect to each server and fetch data
for server in servers:
    conn_str = f'DRIVER={{SQL Server}};SERVER={server};DATABASE={database};UID={username};PWD={password};timeout={timeout}'
    try:
        conn = pyodbc.connect(conn_str)
        for key, query in queries.items():
            df = pd.read_sql(query, conn)
            dfs[key].append(df)
        conn.close()
    except Exception as e:
        print(f"Error connecting to {server}: {e}")

# Merge data from all servers
for key in dfs:
    dfs[key] = pd.concat(dfs[key], ignore_index=True)

# Write data to Excel with formatting
with pd.ExcelWriter(output_file, engine="openpyxl") as writer:
    for sheet_name, df in dfs.items():
        df.to_excel(writer, sheet_name=sheet_name, index=False)
        wb = writer.book
        ws = wb[sheet_name]

        # Apply formatting
        header_fill = PatternFill(start_color="C6EFCE", end_color="C6EFCE", fill_type="solid")
        bold_font = Font(bold=True)

        for cell in ws[1]:  # First row (headers)
            cell.font = bold_font
            cell.fill = header_fill

        # Autofit columns
        for col in ws.columns:
            max_length = max(len(str(cell.value)) if cell.value else 0 for cell in col)
            ws.column_dimensions[col[0].column_letter].width = max_length + 2

print(f"Data exported to {output_file}")