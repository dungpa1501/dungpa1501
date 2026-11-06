from sshtunnel import SSHTunnelForwarder
import pymysql
import pyodbc
import pandas as pd
import json

# Thông tin SSH
ssh_host = '10.40.30.34'
ssh_port = 22
ssh_user = 'root'
ssh_password = 'Kt4c.GAmv%RK'  # hoặc dùng private key

# Thông tin MySQL
mysql_host = '127.0.0.1'  # MySQL host từ góc nhìn của SSH server
mysql_port = 3306
mysql_user = 'root'
mysql_password = 'dAs25T33MqYSSZNP'
mysql_db = 'galaxy_inventory'

# SQL Server
sql_server = '192.168.115.6'
sql_database = 'BIDW'
sql_user = 'sa'
sql_password = '1qaZ2wsX'


# === SSH + MySQL Connection ===
with SSHTunnelForwarder(
    (ssh_host, ssh_port),
    ssh_username=ssh_user,
    ssh_password=ssh_password,
    remote_bind_address=(mysql_host, mysql_port),
    local_bind_address=('127.0.0.1', 3307)
) as tunnel:
    connection = pymysql.connect(
        host='127.0.0.1',
        port=3307,
        user=mysql_user,
        password=mysql_password,
        db=mysql_db,
        charset='utf8mb4',
        cursorclass=pymysql.cursors.DictCursor
    )

    query = """
        SELECT
            siteId, orderId, name, email, phone, createdAt, updatedAt,
            vistaBookingId, vistaBookingNumber, vistaTransactionId,
            memberId, method, merchTxnRef, status,
            clientIp, expiredAt, error, items
        FROM `order`
        where createdAt >= '2025-04-17 10:10:05'
    """

    with connection.cursor() as cursor:
        cursor.execute(query)
        rows = cursor.fetchall()

    connection.close()

# === Parse JSON ===
records = []
for row in rows:
    order_id = row['orderId']
    json_data = row['items']
    if not json_data or json_data in ('null', 'NULL'):
        continue

    try:
        products = json.loads(json_data)
        if not isinstance(products, list):
            continue

        for idx, product in enumerate(products, start=1):  # Start index at 1 for item position
            integration_id = f"{order_id}_{idx}"  # integration_id = orderId + stt (index)
            records.append((
                integration_id,  # New integration_id
                row['siteId'], row['orderId'], row['name'], row['email'], row['phone'],
                row['createdAt'], row['updatedAt'], row['vistaBookingId'], row['vistaBookingNumber'],
                row['vistaTransactionId'], row['memberId'], row['method'], row['merchTxnRef'],
                row['status'], row['clientIp'], row['expiredAt'],
                row['error'], product.get('productId'), product.get('productName'),
                product.get('qty'), product.get('price'), product.get('total')
            ))
    except Exception as e:
        print(f"⚠️ Lỗi parse JSON cho order_id={order_id}: {e}")

# === SQL Server Connection ===
sql_conn = pyodbc.connect(
    f'DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={sql_server};DATABASE={sql_database};UID={sql_user};PWD={sql_password}'
)
sql_cursor = sql_conn.cursor()

# === Truy vấn integration_id đã tồn tại ===
sql_cursor.execute("SELECT integration_id FROM tblOrderAnhTrai")
existing_integration_ids = {row.integration_id for row in sql_cursor.fetchall()}

# === Phân loại: insert vs update ===
to_insert, to_update = [], []
for r in records:
    if r[0] in existing_integration_ids:  # r[0] is the integration_id
        to_update.append(r)
    else:
        to_insert.append(r)

# === BATCH INSERT ===
insert_sql = """
    INSERT INTO tblOrderAnhTrai (
        integration_id, siteId, orderId, name, email, phone, createdAt, updatedAt,
        vistaBookingId, vistaBookingNumber, vistaTransactionId,
        memberId, method, merchTxnRef, status,
        clientIp, expiredAt, error,
        productId, productName, qty, price, total
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
"""
if to_insert:
    sql_cursor.executemany(insert_sql, to_insert)

# === BATCH UPDATE ===
update_sql = """
    UPDATE tblOrderAnhTrai SET
        siteId = ?, name = ?, email = ?, phone = ?, createdAt = ?, updatedAt = ?,
        vistaBookingId = ?, vistaBookingNumber = ?, vistaTransactionId = ?,
        memberId = ?, method = ?, merchTxnRef = ?, status = ?,
        clientIp = ?, expiredAt = ?, error = ?,
        productId = ?, productName = ?, qty = ?, price = ?, total = ?
    WHERE integration_id = ?
"""
# Move integration_id to the end for WHERE clause (remove it from the SET part)
update_batch = [r[1:] + (r[0],) for r in to_update]  # r[1:] skips integration_id, adding it to the WHERE clause

if update_batch:
    sql_cursor.executemany(update_sql, update_batch)

# === Done ===
sql_conn.commit()
sql_cursor.close()
sql_conn.close()

print(f"✅ Done: Inserted {len(to_insert)}, Updated {len(to_update)}")

