
--BO
declare @from datetime, @to datetime, @CinemaOperator nvarchar(20)
select @CinemaOperator = CinOperator_strCode from tblCinema_Operator
If @CinemaOperator is not null or @CinemaOperator <> ''
BEGIN
 set @from = dbo.fnGetBizDateTime(getdate()-1)
 set @to = dbo.fnGetBizDateTime(getdate())
 exec spRptNavisionBoxOfficeExtract @DateFrom = @from,@DateTo = @to,@CinOperator_strCode = @CinemaOperator
END

--BO Select 
SELECT
CINEMA_CODE AS 'Cinema Code',
FILM_HO_CODE AS 'Film HO Code',
FILM_NAME AS 'Film Name',
CONVERT(VARCHAR(10), POSTING_DATE, 103)  AS 'Posting Date',
convert(decimal(10,3),UNIT_PRICE) AS 'Unit Price',
ADMITS AS 'Admits',
AMOUNT AS 'Amount'
FROM [dbo].[tblRptNavisionBoxOfficeExtract]
where SEQ = 3




-- CO
declare @from datetime, @to datetime, @CinemaOperator nvarchar(20)
select @CinemaOperator = CinOperator_strCode from tblCinema_Operator
If @CinemaOperator is not null or @CinemaOperator <> ''
BEGIN
 set @from = dbo.fnGetBizDateTime(getdate()-1)
 set @to = dbo.fnGetBizDateTime(getdate())
 exec spRptNavisionConcessionSalesExtract @DateFrom = @from,@DateTo = @to,@CinOperator_strCode = @CinemaOperator
END

--CO Select 
SELECT
CINEMA_CODE AS 'Cinema Code',
CONVERT(VARCHAR(10), POSTING_DATE, 103)  AS 'Posting Date',
HO_CODE AS 'HO Code',
ITEM_NAME AS 'Item Name',
QUANTITY AS 'Quantity',
convert(decimal(10,3),UNIT_PRICE) AS 'Unit Price',
AMOUNT AS 'Amount',
ITEM_CLASS AS 'Item Class'
FROM [dbo].[tblRptNavisionConcessionSalesExtract]
where SEQ = 3


--BOM
declare @from datetime, @to datetime, @CinemaOperator nvarchar(20)
select @CinemaOperator = CinOperator_strCode from tblCinema_Operator
If @CinemaOperator is not null or @CinemaOperator <> ''
BEGIN
 set @from = dbo.fnGetBizDateTime(getdate()-1)
 set @to = dbo.fnGetBizDateTime(getdate())
 exec spRptNavisionBOMRecipeExtract @DateFrom = @from,@DateTo = @to,@CinOperator_strCode = @CinemaOperator
END


-- BOM Select
SELECT
CINEMA_CODE AS 'Cinema Code',
ITEM_CLASS AS 'Item Class',
CONVERT(VARCHAR(10), POSTING_DATE, 103)  AS 'Posting Date',
HO_CODE AS 'Item HO Code',
ITEM_NAME AS 'Item Name',
QUANTITY AS 'Quantity',
BOM_HO_CODE AS 'Sold BOM Item HO Code',
BOM_ITEM_NAME AS 'Sold BOM Item Name',
BOM_QUANTITY AS 'Sold BOM Item Quantity',
convert(decimal(10,3),BOM_UNIT_PRICE) AS 'Sold BOM Item Price'
FROM [dbo].[tblRptNavisionBOMRecipeExtract]
where SEQ = 3

