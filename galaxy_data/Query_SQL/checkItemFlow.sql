select top 100 * from tblItem
where Item_strStatus = 'A'
and Item_strItemId IN(
5415,
5418,
5420,
5423
)

select top 100 * from tblItem
where Item_strStatus = 'A'
and Item_strItemId IN(5376),
5428)


select * from tblItemAlternate
where Item_strItemId = 5382
order by ItemAlt_intSequence asc



select * from tblBOM where Item_strItemId = 5434


select * from tblBOM where Item_strItemId = 5376


select * from tblBOM where Item_strItemId = 5420



DECLARE @TableTypeName NVARCHAR(128) = 'StockItemRelationship';
DECLARE @TypeTableObjectID INT;

-- Check if the table type exists and get the object ID
SELECT @TypeTableObjectID = type_table_object_id
FROM sys.table_types
WHERE name = @TableTypeName;

IF @TypeTableObjectID IS NOT NULL
BEGIN
    PRINT 'Table type exists. Listing structure:';

    -- Get the structure of the table type
    SELECT 
        c.name AS ColumnName,
        t.name AS DataType,
        c.max_length AS MaxLength,
        c.precision,
        c.scale,
        c.is_nullable
    FROM sys.columns AS c
    INNER JOIN sys.types AS t ON c.user_type_id = t.user_type_id
    WHERE c.object_id = @TypeTableObjectID;
END
ELSE
BEGIN
    PRINT 'The table type dbo.StockItemRelationship does not exist.';
END
