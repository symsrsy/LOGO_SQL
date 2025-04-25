-- Aynı ettn ile irsaliye var diyebiliyor connect bazen. Ozaman EDESPSTATUS'u 10 olarak değiştiriyorum
--EDESPSTATUS alanı 0 yapıldıktan sonra fiş satırına müdahale yapılabilmektedir.EDESPSTATUS 0 yapıldığında GIB'e gönderilebilecek duruma gelir

-- E-irsaliye yeni durum : Gönderildi
UPDATE LG_004_01_STFICHE	SET EDESPSTATUS=10 where FICHENO='IRS2025000000001'

-- E-irsaliye yeni durum : Gönderilmedi
UPDATE LG_004_01_STFICHE	SET EDESPSTATUS=0 where FICHENO='IRS2025000000001'

