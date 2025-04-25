-- Malzeme kartının net 1 kilosunun brüt kaç kg geldiğini belirtmek için kullandığım sorgu
UPDATE un 
SET un.GROSSWEIGHT=<BrutKg> 
FROM LG_004_ITMUNITA un 
LEFT JOIN LG_004_ITEMS inv ON un.ITEMREF = inv.LOGICALREF AND un.UNITLINEREF=25 
WHERE inv.CODE='MALZEMEKODU'
