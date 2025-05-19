import pyodbc
import pandas as pd
import logging
from openpyxl import load_workbook
from datetime import datetime, timedelta

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Connection parameters (shared across all servers)
database = 'VISTA'  #database name
username = 'sa'  #username
password = 'GaLaXyNDNTTB126'  #password
timeout = 30  # Connection timeout in seconds

# List of servers to query
servers = [
    '10.20.30.151',  # phan huy ich
    '10.20.30.152',  # gold coast nha trang
    ]

from_date = 'DATEADD(HOUR,6,CONVERT(VARCHAR(10), GETDATE()-1,110))'
to_date = 'DATEADD(HOUR,6,CONVERT(VARCHAR(10), GETDATE(),110))'
date_format = datetime.now() - timedelta(days=1)
formatted_date = date_format.strftime("%d%m%Y")    

# SQL query (modify as needed)
query = f"""
			SELECT
			CinOperator_strHOOperatorCode Cinema, PromotionH_strDescription 'Promotion Name', sum(intQuantity) as Quantity ,	sum(cast(curValue as float)) as 'Sell Price',	sum(cast(curDiscount as float)) as Discount
			FROM
			(
						SELECT  concat(Cin.CinOperator_strCode,'~',TransI_lgnNumber,'~',TransI_intSequence,'~',P.PromotionH_strCode) as integration_id,
										TransI_lgnNumber as Trans_lgnNumber,
										TransI_intSequence as Trans_intSequence,
										TransI_dtmDateTime as date_filter,
										CinOperator_strHOOperatorCode,
										PromotionHDiscount_strCode AS strPromotionCode,
										P.PromotionH_strDescription,
										SIGN(TransI_decActualNoOfItems)
										* COUNT( DISTINCT TransI_lgnNumber + ( TransI_intPackageGroupNo / 100.00 ) ) AS intQuantity,
										sum( TransI_decActualNoOfItems * TransI_curValueEach ) AS curValue,
										sum( SIGN(TransI_decActualNoOfItems) * TransI_curDiscount ) AS curDiscount
						FROM    tblTrans_Inventory Inv WITH(INDEX(indTransI_Type_DateTime))
						INNER JOIN tblItem I ON I.Item_strItemId = Inv.Item_strItemId
						INNER JOIN tblPromotionHeader P ON P.PromotionH_strCode = Inv.PromotionHDiscount_strCode
						INNER JOIN tblCinema_Operator Cin on Cin.CinOperator_strCode = Inv.CinOperator_strCode
						WHERE   RTRIM( ISNULL(PromotionHDiscount_strCode,'') ) <> ''
							AND   TransI_intDealSequence IS NULL
							AND   TransI_strType = 'S'
							AND   ISNULL(TransI_curDiscount,0) <> 0
							AND   ISNULL(TransI_intPackageGroupNo,0) <> 0  -- Package Sale
							AND 	Inv.TransI_dtmDateTime >= {from_date} AND Inv.TransI_dtmDateTime < {to_date}
						GROUP BY PromotionHDiscount_strCode, SIGN(TransI_decActualNoOfItems),TransI_lgnNumber,	TransI_intSequence,TransI_dtmDateTime,P.PromotionH_strDescription,
										 concat(Cin.CinOperator_strCode,'~',TransI_lgnNumber,'~',TransI_intSequence,'~',P.PromotionH_strCode),CinOperator_strHOOperatorCode

						UNION ALL
						-- Non-Package Item Sales
						SELECT  concat(Cin.CinOperator_strCode,'~',TransI_lgnNumber,'~',TransI_intSequence,'~',P.PromotionH_strCode) as integration_id,
										TransI_lgnNumber as Trans_lgnNumber,
										TransI_intSequence as Trans_intSequence,
										TransI_dtmDateTime as date_filter,
										CinOperator_strHOOperatorCode,
										PromotionHDiscount_strCode AS strPromotionCode,
										P.PromotionH_strDescription,
										SUM( SIGN(TransI_decActualNoOfItems) ) AS intQuantity,
										SUM( TransI_decActualNoOfItems * TransI_curValueEach ) AS curValue,
										SUM( SIGN(TransI_decActualNoOfItems) * TransI_curDiscount ) AS curDiscount
						FROM     tblTrans_Inventory Inv WITH(INDEX(indTransI_Type_DateTime))
						INNER JOIN tblItem I ON I.Item_strItemId = Inv.Item_strItemId
						INNER JOIN tblPromotionHeader P ON P.PromotionH_strCode = Inv.PromotionHDiscount_strCode
						INNER JOIN tblCinema_Operator Cin on Cin.CinOperator_strCode = Inv.CinOperator_strCode
						WHERE   RTRIM( ISNULL(PromotionHDiscount_strCode,'') ) <> ''
							AND   TransI_intDealSequence IS NULL
							AND   TransI_strType = 'S'
							AND   ISNULL(TransI_curDiscount,0) <> 0
							AND   ISNULL(TransI_intPackageGroupNo,0) = 0  -- Not Package Sale
							AND 	Inv.TransI_dtmDateTime >= {from_date} AND Inv.TransI_dtmDateTime < {to_date}
						GROUP BY PromotionHDiscount_strCode,TransI_lgnNumber,	TransI_intSequence,TransI_dtmDateTime,P.PromotionH_strDescription,concat(Cin.CinOperator_strCode,'~',TransI_lgnNumber,'~',TransI_intSequence,'~',P.PromotionH_strCode),
						CinOperator_strHOOperatorCode

						UNION ALL

						-- Ticket Sales:
						SELECT  concat(Cin.CinOperator_strCode,'~',TransT_lgnNumber,'~',TransT_intSequence,'~',P.PromotionH_strCode) integration_id,
										TransT_lgnNumber as Trans_lgnNumber,
										TransT_intSequence as Trans_intSequence,
										Session_dtmRealShow date_filter,
										CinOperator_strHOOperatorCode,
										P.PromotionH_strDescription,
										PromotionHDiscount_strCode,
										SIGN(TransT_intNoOfSeats) AS intQuantity,
										TransT_curValueEach  AS curValue,
										SIGN(TransT_intNoOfSeats) * TransT_curDiscount AS curDiscount
						FROM     tblSession S
						INNER JOIN tblTrans_Ticket T ON T.Session_lngSessionId = S.Session_lngSessionId
						INNER JOIN tblTicketType TT ON TT.TType_strCode = T.Price_strCode
						INNER JOIN tblPromotionHeader P ON P.PromotionH_strCode = T.PromotionHDiscount_strCode
						INNER JOIN tblCinema_Operator Cin on Cin.CinOperator_strCode = T.CinOperator_strCode
						WHERE Session_dtmRealShow >= {from_date} AND Session_dtmRealShow < {to_date}
						AND Session_strStatus IN ('O', 'C')
						AND RTRIM(ISNULL(PromotionHDiscount_strCode,'')) <> ''
						AND   TransT_intDealSequence IS NULL
						AND   UPPER(TransT_strType) IN ( 'P', 'A' )
						AND   ISNULL(TransT_curDiscount,0) <> 0

						-- End part 1

						UNION ALL

						-- start part 2
						SELECT  concat(Cin.CinOperator_strCode,'~',TransI_lgnNumber,'~',TransI_intDealSequence,'~',P.PromotionH_strCode) as integration_id,
										Inv.TransI_lgnNumber AS Trans_lgnNumber,
										Inv.TransI_intDealSequence AS intDealSequence,
										Inv.TransI_dtmDateTime date_filter,
										CinOperator_strHOOperatorCode,
										Inv.PromotionHDiscount_strCode,
										P.PromotionH_strDescription,
										SIGN(Inv.TransI_decActualNoOfItems) AS intQuantitySign,
										SUM(SIGN(Inv.TransI_decActualNoOfItems) * Inv.TransI_curValueEach) AS curValue,
										SUM(SIGN(Inv.TransI_decActualNoOfItems) * Inv.TransI_curDiscount) AS curDiscount
						FROM     tblTrans_Inventory Inv WITH(INDEX(indTransI_Type_DateTime))
						INNER JOIN tblItem I ON I.Item_strItemId = Inv.Item_strItemId
						INNER JOIN tblPromotionHeader P ON P.PromotionH_strCode = Inv.PromotionHDiscount_strCode
						INNER JOIN tblCinema_Operator Cin on Cin.CinOperator_strCode = Inv.CinOperator_strCode
						WHERE    Inv.TransI_dtmDateTime >= {from_date} AND Inv.TransI_dtmDateTime < {to_date}
							AND   RTRIM( ISNULL(Inv.PromotionHDiscount_strCode,'') ) <> ''
							AND   Inv.TransI_intDealSequence IS NOT NULL
							AND   Inv.TransI_strType = 'S'
						GROUP BY 	Inv.PromotionHDiscount_strCode, P.PromotionH_strDescription, Inv.TransI_lgnNumber,Inv.TransI_intDealSequence,Inv.TransI_dtmDateTime,SIGN(Inv.TransI_decActualNoOfItems),
						concat(Cin.CinOperator_strCode,'~',TransI_lgnNumber,'~',TransI_intDealSequence,'~',P.PromotionH_strCode),CinOperator_strHOOperatorCode

						UNION ALL

						SELECT  concat(Cin.CinOperator_strCode,'~',TransT_lgnNumber,'~',TransT_intDealSequence,'~',P.PromotionH_strCode) integration_id,
										T.TransT_lgnNumber AS Trans_lgnNumber,
										T.TransT_intDealSequence AS intDealSequence,
										Session_dtmRealShow date_filter,
										CinOperator_strHOOperatorCode,
										T.PromotionHDiscount_strCode,
										P.PromotionH_strDescription,
										SIGN(T.TransT_intNoOfSeats) AS intQuantitySign,
										SUM(T.TransT_curValueEach) AS curValue,
										SUM(SIGN(T.TransT_intNoOfSeats) * T.TransT_curDiscount) AS curDiscount
						FROM     tblSession S
						INNER JOIN tblTrans_Ticket T ON T.Session_lngSessionId = S.Session_lngSessionId
						INNER JOIN tblTicketType TT ON TT.TType_strCode = T.Price_strCode
						INNER JOIN tblPromotionHeader P ON P.PromotionH_strCode = T.PromotionHDiscount_strCode
						INNER JOIN tblCinema_Operator Cin on Cin.CinOperator_strCode = T.CinOperator_strCode
						WHERE   RTRIM( ISNULL(T.PromotionHDiscount_strCode,'') ) <> ''
							AND   T.TransT_intDealSequence IS NOT NULL
							AND   UPPER(T.TransT_strType) IN ( 'P', 'A' )
							AND   Session_dtmRealShow >= {from_date} AND Session_dtmRealShow < {to_date}
							AND Session_strStatus IN ('O', 'C')
							AND RTRIM(ISNULL(PromotionHDiscount_strCode,'')) <> ''
						GROUP BY T.PromotionHDiscount_strCode, P.PromotionH_strDescription, T.TransT_lgnNumber,T.TransT_intDealSequence,Session_dtmRealShow,SIGN(T.TransT_intNoOfSeats),
						concat(Cin.CinOperator_strCode,'~',TransT_lgnNumber,'~',TransT_intDealSequence,'~',P.PromotionH_strCode),CinOperator_strHOOperatorCode

						-- end part 2

						UNION ALL

						-- start part 3
						SELECT  concat(Cin.CinOperator_strCode,'~',TransI_lgnNumber,'~',TransI_intDealSequence,'~',PH.PromotionH_strCode) as integration_id,
										Inv.TransI_lgnNumber AS Trans_lgnNumber,
										Inv.TransI_intDealSequence AS intDealSequence,
										Inv.TransI_dtmDateTime AS date_filter,
										CinOperator_strHOOperatorCode,
										Inv.PromotionH_strCode AS strPromotionCode,
										PH.PromotionH_strDescription,
										COUNT( DISTINCT CASE WHEN P.Item_strItemId IS NULL THEN NULL ELSE Inv.TransI_lgnNumber + ( Inv.TransI_intPackageGroupNo / 100.00 ) END)
										+
										SUM( CASE WHEN P.Item_strItemId IS NULL THEN Inv.TransI_decActualNoOfItems ELSE 0 END) AS intQuantity,
										SUM(Inv.TransI_decActualNoOfItems * Inv.TransI_curValueEach) AS curValue,
										SUM( SIGN(Inv.TransI_decActualNoOfItems) * Inv.TransI_curDiscount) AS curDiscount
						FROM tblTrans_Inventory Inv WITH(INDEX(indDateTime))
						INNER JOIN tblItem I ON I.Item_strItemId = Inv.Item_strItemId
						LEFT JOIN tblItem P ON P.Item_strItemId = Inv.TransI_strParentItem_strItemId AND P.Item_strItemType IS NOT NULL AND P.Item_strItemType = '' AND P.Item_strPackage = 'Y'
						INNER JOIN tblPromotionHeader PH ON PH.PromotionH_strCode = Inv.PromotionHDiscount_strCode
						INNER JOIN tblCinema_Operator Cin on Cin.CinOperator_strCode = Inv.CinOperator_strCode
						WHERE   UPPER(I.Item_strReport) <> 'Y'
							AND   ( ( ISNULL(Inv.PromotionH_strCode,'') <> '' AND Inv.TransI_intDealSequence IS NULL ) OR UPPER(I.Item_strPromotion) = 'Y' )
							AND   ISNULL(Inv.PromotionHDiscount_strCode,'') = ''
							AND 	Inv.TransI_dtmDateTime >= {from_date}
							AND   Inv.TransI_dtmDateTime < {to_date}
						GROUP BY Inv.PromotionH_strCode,Inv.TransI_lgnNumber,Inv.TransI_intDealSequence,Inv.TransI_dtmDateTime,PH.PromotionH_strDescription,CinOperator_strHOOperatorCode,
						concat(Cin.CinOperator_strCode,'~',TransI_lgnNumber,'~',TransI_intDealSequence,'~',PH.PromotionH_strCode)
						-- end part 3
			) AS A
			GROUP BY CinOperator_strHOOperatorCode, PromotionH_strDescription
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
                    df['Quantity'] = pd.to_numeric(df['Quantity'], errors='coerce')

    except pyodbc.Error as e:
        logging.error(f"Error querying {server}: {e}")

# Combine results from all servers into a single DataFrame
if all_results:
    
    combined_df = pd.concat(all_results, ignore_index=True)
    combined_df = combined_df.drop(columns=['Server'])
    # Write the DataFrame to an Excel file
    excel_file = f'\\\\GLXPWNAV01\\navdata$\\Data_CTKM_KhaiTruong\\CTKM_KhaiTruong_{formatted_date}.xlsx'
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