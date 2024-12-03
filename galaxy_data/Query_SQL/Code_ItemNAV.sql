-- code lay item nav

select 
a.Item_strMasterItemCode as [No.],
a.Item_strMasterItemCode as [No.2],
a.Item_strItemDescription as [Description],
a.Item_strItemDescription as [Search Description],
a.Item_strItemDescription as [Description 2],
b.Unit_strDescription as [Base Unit of Measure],
'Inventory' as [Type],
case when e.ItemType_strItemTypeDescription = 'Component' then 'RAW MT' 
	when (a.Item_strItemType = '' or e.ItemType_strName is null) then 'RESALE' 
	when e.ItemType_strItemTypeDescription = 'Made at sale time (recipe)' then 'FINISHED' end as [Inventory Posting Group],
'Average' as [Costing Method],
'F&B' as [Gen. Prod. Posting Group],
concat('VAT',RIGHT(100+cast(STax_curRate as int),2)) as [VAT Prod. Posting Group],
f.Unit_strDescription as [Sales Unit of Measure],
d.Unit_strDescription as [Purch. Unit of Measure],
c.Class_strDescription as [Item Category Code],
'F&B' as [Product Group Code],
a.Item_strItemDescription as [Vietnamese Description]
from (select case when Item_strItemType = '' then 'Normal' else Item_strItemType end 'Item_strItemType1',* from tblItem) as a 
join tblSalesTax g on a.STax_strCode = g.STax_strCode
left join tblUnitOfMeasure as b on a.Item_strBaseUOMCode = b.Unit_strCode
left join tblUnitOfMeasure as d on a.Item_strStockUOMCode = d.Unit_strCode
left join tblUnitOfMeasure as f on a.Item_strSaleUOMCode = f.Unit_strCode
left join tblItem_Class as c on a.Class_strCode = c.Class_strCode
left join (select case when ItemType_strName = '' then ItemType_strItemTypeDescription else ItemType_strName end as ItemType_strName,ItemType_strItemTypeDescription  from tblDimItemType) as e on a.Item_strItemType1 = e.ItemType_strName
where a.Item_strMasterItemCode in ('HOFAM1BIGONLKV2','HOFAM2NEWBONKV2');

-- code lay BOM nav

select
a.Item_strMasterItemCode as [Item No.],
b.Unit_strDescription as [Code],
1 as [Qty. per Unit of Measure]
from tblItem as a 
left join tblUnitOfMeasure as b on a.Item_strBaseUOMCode = b.Unit_strCode
left join tblUnitOfMeasure as d on a.Item_strStockUOMCode = d.Unit_strCode
where a.Item_strMasterItemCode in ('HOMYVICARANOSAL','HOVICARAMELNOK1','HOVICARAMELNOK2')

union

select
a.Item_strMasterItemCode as [Item No.],
d.Unit_strDescription as [Code],
Item_curStockUOMConv as [Qty. per Unit of Measure]
from tblItem as a 
left join tblUnitOfMeasure as b on a.Item_strBaseUOMCode = b.Unit_strCode
left join tblUnitOfMeasure as d on a.Item_strStockUOMCode = d.Unit_strCode
where a.Item_strMasterItemCode in ('HOMYVICARANOSAL','HOVICARAMELNOK1','HOVICARAMELNOK2')
and d.Unit_strDescription <> b.Unit_strDescription
