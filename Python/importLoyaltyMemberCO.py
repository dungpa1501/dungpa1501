import pandas as pd
import pyodbc  # hoặc dùng sqlalchemy
from datetime import datetime, timedelta
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill


# Connection parameters (shared across all servers)
database = 'VISTALOYALTY'  #database name
username = 'sa'  #username
password = 'GaLaXyNDNTTB126'  #password
timeout = 30  # Connection timeout in seconds
server = '192.168.115.14'


# Thiết lập kết nối SQL Server
conn_str = f'DRIVER={{SQL Server}};SERVER={server};DATABASE={database};UID={username};PWD={password};timeout={timeout}'
conn = pyodbc.connect(conn_str)

# Hàm lấy dữ liệu từng tháng
def fetch_data(start_date, end_date, year):
    query = f"""
                with cte as 
                (
                select 
                complex_name,
                year(transaction_time) transYear,
                FORMAT(transaction_time, 'MMM', 'en-US') Month,
                case when isnull(person_gender,'') = '' then 'Unknown' else person_gender end gender,
                CASE 
                                WHEN 2025 - (TRY_CAST(REPLACE(person_centuryOfBirth, '??', '20') + REPLACE(person_yearOfBirth, '??', '20') AS INT)) < 0 THEN 'Unknown'
                                WHEN 2025 - (TRY_CAST(REPLACE(person_centuryOfBirth, '??', '20') + REPLACE(person_yearOfBirth, '??', '20') AS INT)) < 18 THEN '<18'
                                WHEN 2025 - (TRY_CAST(REPLACE(person_centuryOfBirth, '??', '20') + REPLACE(person_yearOfBirth, '??', '20') AS INT)) < 23 THEN 'U18-22'
                                WHEN 2025 - (TRY_CAST(REPLACE(person_centuryOfBirth, '??', '20') + REPLACE(person_yearOfBirth, '??', '20') AS INT)) < 31 THEN 'U23-30'
                                WHEN 2025 - (TRY_CAST(REPLACE(person_centuryOfBirth, '??', '20') + REPLACE(person_yearOfBirth, '??', '20') AS INT)) < 41 THEN 'U31-40'
                                ELSE '>U40'
                END AS Age,
                rank as level,
                count(distinct a.transaction_id) trans_co,
                sum(transactionItem_quantity) co_quantity,
                (sum(case when transactionItem_quantity < 0 then transactionItem_spend * transactionItem_quantity else transactionItem_spend end) + sum(case when transactionItem_quantity < 0 then transactionItem_tax * transactionItem_quantity else transactionItem_tax end)) CO_amount
                from cognetic_data_transaction a 
                join cognetic_data_transactionItem b on a.transaction_id = b.transactionItem_transactionid
                join cognetic_campaigns_complex e on a.transaction_complexid = e.complex_id
                join cognetic_members_membership d on a.transaction_membershipid = d.membership_id
                INNER JOIN (SELECT * FROM cognetic_core_person WHERE ISNULL(person_deleted,0) <> 1) cognetic_core_person ON membership_personid = person_id
                left join tblGLXMemberRankAllYear lv on d.membership_id = lv.membership_id
                WHERE ISNULL(membership_deleted,0) = 0 and isnull(person_deleted,0) = 0
                                and transaction_time >= '{start_date}'
                                and transaction_time < '{end_date}'
                                and transactionItem_movieid is null
                                and year = {year}
                group by 
                complex_name,
                year(transaction_time),
                CASE 
                                WHEN 2025 - TRY_CAST(REPLACE(person_centuryOfBirth, '??', '20') + REPLACE(person_yearOfBirth, '??', '20') AS INT) < 0 THEN 'Unknown'
                                WHEN 2025 - TRY_CAST(REPLACE(person_centuryOfBirth, '??', '20') + REPLACE(person_yearOfBirth, '??', '20') AS INT) < 18 THEN '<18'
                                WHEN 2025 - TRY_CAST(REPLACE(person_centuryOfBirth, '??', '20') + REPLACE(person_yearOfBirth, '??', '20') AS INT) < 23 THEN 'U18-22'
                                WHEN 2025 - TRY_CAST(REPLACE(person_centuryOfBirth, '??', '20') + REPLACE(person_yearOfBirth, '??', '20') AS INT) < 31 THEN 'U23-30'
                                WHEN 2025 - TRY_CAST(REPLACE(person_centuryOfBirth, '??', '20') + REPLACE(person_yearOfBirth, '??', '20') AS INT) < 41 THEN 'U31-40'
                                ELSE '>U40'
                END
                ,case when isnull(person_gender,'') = '' then 'Unknown' else person_gender end ,
                rank,
                FORMAT(transaction_time, 'MMM', 'en-US')
                )
                select complex_name as Cinema,	transYear as Year, Month,	gender,	Age, level, sum(trans_co) trans_co, sum(co_quantity) co_qty, sum(CO_amount) co_amt
                from cte
                group by complex_name,	transYear, Month,	gender,	Age,	level
    """
    return pd.read_sql(query, conn)

# Loop qua từng tháng
start = datetime(2019, 1, 1)
end = datetime(2020, 1, 1) 
year = 2019

all_data = []
while start < end:
    next_month = (start.replace(day=1) + timedelta(days=32)).replace(day=1)
    start_str = start.strftime('%Y-%m-%d 00:00:00.000')
    end_str = next_month.strftime('%Y-%m-%d 00:00:00.000')

    print(f"Fetching: {start.strftime('%Y-%m')}...")
    df = fetch_data(start.strftime('%Y-%m-%d'), next_month.strftime('%Y-%m-%d'), year)
    all_data.append(df)
    start = next_month

# Gộp tất cả lại
final_df = pd.concat(all_data, ignore_index=True)

# Ghi ra Excel
output_file = f"E:\\LoyaltyTransAllsCO_{year}.xlsx"
with pd.ExcelWriter(output_file, engine='openpyxl') as writer:
    final_df.to_excel(writer, index=False, sheet_name="Data")
    
    # Format header
    workbook = writer.book
    worksheet = writer.sheets["Data"]
    header_fill = PatternFill(start_color="CCFFCC", end_color="CCFFCC", fill_type="solid")
    for cell in worksheet[1]:
        cell.font = Font(bold=True)
        cell.fill = header_fill

print(f"Done! File saved as: {output_file}")
