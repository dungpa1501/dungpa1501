import pandas as pd
import pyodbc
import win32com.client as win32
import os

# Connection parameters (shared across all servers)
database = 'VISTALOYALTY'  #database name
username = 'sa'  #username
password = 'GaLaXyNDNTTB126'  #password
timeout = 30  # Connection timeout in seconds
server = '192.168.115.14'


# Thiết lập kết nối SQL Server
conn_str = f'DRIVER={{SQL Server}};SERVER={server};DATABASE={database};UID={username};PWD={password};timeout={timeout}'
conn = pyodbc.connect(conn_str)

query = "SELECT top 10 person_id FROM cognetic_core_person"  # đổi lại query của bạn
df = pd.read_sql(query, conn)
conn.close()

# --- 2. Ghi dữ liệu ra Excel ---
file_path = r"E:\Excel\report.xlsx"
df.to_excel(file_path, index=False)

# --- 3. Gửi mail với Outlook ---
outlook = win32.Dispatch('Outlook.Application')
mail = outlook.CreateItem(0)

mail.To = "dungpa@galaxystudio.vn"
mail.Subject = "Báo cáo dữ liệu"
mail.Body = "Đính kèm là báo cáo từ SQL Server."

# Đính kèm file
mail.Attachments.Add(Source=file_path)

# Gửi
mail.Send()

# (Tùy chọn) Xóa file sau khi gửi nếu muốn
# os.remove(file_path)

print("Mail sent successfully.")
