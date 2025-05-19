import pandas as pd
from openpyxl import load_workbook

# Định nghĩa đường dẫn file
file_1 = "E:\\coappmomo1.xlsx"
file_2 = "E:\\coappmomo2.xlsx"
output_file = "E:\\merged_file1.xlsx"

# Đọc danh sách sheet từ file đầu tiên (cả hai file có số sheet giống nhau)
sheets = pd.ExcelFile(file_1).sheet_names

# Tạo writer để lưu file hợp nhất
with pd.ExcelWriter(output_file, engine='openpyxl') as writer:
    for sheet in sheets:
        # Đọc dữ liệu từng sheet từ cả hai file
        df1 = pd.read_excel(file_1, sheet_name=sheet)
        df2 = pd.read_excel(file_2, sheet_name=sheet)
        
        # Ghép dữ liệu của 2 file (nối dòng)
        merged_df = pd.concat([df1, df2], ignore_index=True)
        
        # Ghi vào file mới
        merged_df.to_excel(writer, sheet_name=sheet, index=False)

# Tự động điều chỉnh độ rộng cột
wb = load_workbook(output_file)
for sheet_name in wb.sheetnames:
    ws = wb[sheet_name]
    for column_cells in ws.columns:
        max_length = max(len(str(cell.value)) if cell.value else 0 for cell in column_cells)
        col_letter = column_cells[0].column_letter
        ws.column_dimensions[col_letter].width = max_length + 2

wb.save(output_file)

print(f"✅ Đã gộp hai file thành {output_file}")
