import pandas as pd
from openpyxl import load_workbook

# Đọc file gốc
file_path = 'E:\\merged_file.xlsx'
xls = pd.ExcelFile(file_path)

# Tạo file kết quả
output_file = 'E:\\final_format.xlsx'
writer = pd.ExcelWriter(output_file, engine='openpyxl')

# Mapping cột
row_mapping = {
    'Admit': 'Adm',
    'NBO': 'NBO',
    'BillBO': 'lượt mua BO ( số bill bán vé )'
}

# Xử lý từng sheet
for sheet_name in xls.sheet_names:
    df = xls.parse(sheet_name)

    # Pivot dữ liệu: từ nhiều dòng -> 1 dòng / chỉ số
    df_melted = df.melt(id_vars=['Year'], value_vars=['Admits', 'NBO', 'BillBO'],
                        var_name='Metric', value_name='Value')

    # Thay đổi tên hiển thị
    df_melted['Metric'] = df_melted['Metric'].map(row_mapping)

    # Pivot để ra đúng format
    df_pivot = df_melted.pivot_table(index='Metric', columns='Year', values='Value', aggfunc='sum')

    # Đảm bảo thứ tự dòng đúng
    final_order = ['Adm', 'NBO', 'lượt mua BO ( số bill bán vé )']
    df_pivot = df_pivot.reindex(final_order)

    # Ghi vào file mới
    df_pivot.to_excel(writer, sheet_name=sheet_name)

with pd.ExcelWriter(output_file, engine='openpyxl') as writer:
    for sheet_name in xls.sheet_names:
        df = xls.parse(sheet_name)

        df_melted = df.melt(id_vars=['Year'], value_vars=['Admit', 'NBO', 'BillBO'],
                            var_name='Metric', value_name='Value')

        df_melted['Metric'] = df_melted['Metric'].map(row_mapping)
        df_pivot = df_melted.pivot_table(index='Metric', columns='Year', values='Value', aggfunc='sum')

        final_order = ['Adm', 'NBO', 'lượt mua BO ( số bill bán vé )']
        df_pivot = df_pivot.reindex(final_order)

        df_pivot.to_excel(writer, sheet_name=sheet_name)


print("✅ Xuất file thành công:", output_file)
