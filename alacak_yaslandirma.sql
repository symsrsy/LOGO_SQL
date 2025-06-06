create table #tempresults
(
	[RECID] [int] NULL,
	[SIGN] [smallint] NULL,
	[DEBIT] [float] NULL,
	[CREDIT] [float] NULL,
	[DATE_] [datetime] NULL,
	[LINEEXP] [varchar](251) NULL,
	[ACCOUNTCODE] [varchar](101) NULL,
	[INVOICENO] [varchar](17) NULL,
	[CLOSED] [smallint] NULL,
	[ACILIS] [float] NULL,
	[OCAK] [float] NULL,
	[SUBAT] [float] NULL,
	[MART] [float] NULL,
	[NISAN] [float] NULL,
	[MAYIS] [float] NULL,
	[HAZIRAN] [float] NULL,
	[TEMMUZ] [float] NULL,
	[AGUSTOS] [float] NULL,
	[EYLUL] [float] NULL,
	[EKIM] [float] NULL,
	[KASIM] [float] NULL,
	[ARALIK] [float] NULL,
	[ACCOUNTNAME] [varchar](200) NULL
)

-- Tahsilatlar Temp Tablo Baþlangýç
create table #tempcredits
(
	[CREDIT] [float] NULL,
	[ACCOUNTCODE] [varchar](101) NULL,
	[REMAINING] [float] NULL
)
Insert Into #tempcredits
select SUM(CREDIT) as CREDIT,ACCOUNTCODE,SUM(CREDIT) as REMAINING
from LG_004_01_EMFLINE
WHERE CANCELLED<>1 AND [SIGN]=1 --AND ACCOUNTCODE='120.01.G01'
GROUP BY ACCOUNTCODE
-- Tahsilatlar Temp Tablo Bitiþ


DECLARE @_sign smallint;
DECLARE @_debit float;
DECLARE @_credit float;
DECLARE @_date datetime;
DECLARE @_lineexp varchar(251);
DECLARE @_accountcode varchar(101);
DECLARE @_invoiceno varchar(17);
DECLARE @_month smallint;
DECLARE @_trcode smallint;
DECLARE @_recid int;
DECLARE @_accountname varchar(200);
SET @_recid=0;

DECLARE MY_CURSOR CURSOR 
  LOCAL STATIC READ_ONLY FORWARD_ONLY
FOR 
select [SIGN],DEBIT,CREDIT,DATE_ ,LINEEXP,ACCOUNTCODE,INVOICENO,MONTH_,ca.DEFINITION_,el.TRCODE
from LG_004_01_EMFLINE el
left join LG_004_EMUHACC ca ON ca.LOGICALREF=el.ACCOUNTREF
WHERE el.CANCELLED<>1 
AND el.ACCOUNTCODE LIKE '120.%'
ORDER BY DATE_ ASC

OPEN MY_CURSOR
FETCH NEXT FROM MY_CURSOR INTO @_sign,@_debit,@_credit,@_date,@_lineexp,@_accountcode,@_invoiceno,@_month,@_accountname,@_trcode
WHILE @@FETCH_STATUS = 0
BEGIN 
	SET @_recid = @_recid + 1;
    DECLARE @_remaining FLOAT;
    SET @_remaining=0;
    DECLARE @_splitted smallint;
    SET @_splitted=0;
    SELECT @_remaining = ISNULL(REMAINING,0) FROM #tempcredits WHERE ACCOUNTCODE=@_accountcode
    
    
    SET @_splitted=0
	IF @_remaining=0 OR @_remaining IS NULL
	INSERT INTO #tempresults VALUES(@_recid,@_sign,@_debit,@_credit,@_date,@_lineexp,@_accountcode,@_invoiceno,0,0,0,0,0,0,0,0,0,0,0,0,0,0,@_accountname)
	ELSE
	BEGIN
    
    IF NOT @_remaining-@_debit<0 AND @_sign=0
    BEGIN
    --PRINT @_remaining-@_debit
    UPDATE #tempcredits SET REMAINING=REMAINING-@_debit WHERE ACCOUNTCODE=@_accountcode
    INSERT INTO #tempresults VALUES(@_recid,@_sign,@_debit,@_credit,@_date,@_lineexp,@_accountcode,@_invoiceno,1,0,0,0,0,0,0,0,0,0,0,0,0,0,@_accountname)
    END
    
    IF @_remaining-@_debit<0 AND @_sign=0 AND @_remaining<>0
    BEGIN
    UPDATE #tempcredits SET REMAINING=0 WHERE ACCOUNTCODE=@_accountcode
    SET @_splitted=1
    INSERT INTO #tempresults VALUES(@_recid,@_sign,@_remaining,@_credit,@_date,@_lineexp,@_accountcode,@_invoiceno,1,0,0,0,0,0,0,0,0,0,0,0,0,0,@_accountname)
	SET @_recid = @_recid+1;    
    INSERT INTO #tempresults VALUES(@_recid,@_sign,@_debit-@_remaining,@_credit,@_date,'PARÇALANDI : '+@_lineexp,@_accountcode,@_invoiceno,0,0,0,0,0,0,0,0,0,0,0,0,0,0,@_accountname)
    END
    
    IF @_remaining=0 AND @_sign<>1
    BEGIN
    INSERT INTO #tempresults VALUES(@_recid,@_sign,@_debit,@_credit,@_date,@_lineexp,@_accountcode,@_invoiceno,0,0,0,0,0,0,0,0,0,0,0,0,0,0,@_accountname)
    END
    
    IF @_sign=1 --credit iþlemi. deðiþtirmeden geç
    BEGIN
    INSERT INTO #tempresults VALUES(@_recid,@_sign,@_debit,@_credit,@_date,@_lineexp,@_accountcode,@_invoiceno,1,0,0,0,0,0,0,0,0,0,0,0,0,0,@_accountname)
    END
    
    END
    
    IF ((@_remaining-@_debit<0 AND @_remaining<>0) OR @_remaining=0)AND @_sign=0
    BEGIN
    UPDATE #tempresults
    SET 
    ACILIS = CASE WHEN @_trcode=1 THEN @_debit-@_remaining ELSE 0 END,
    OCAK = CASE WHEN @_month=1 AND @_trcode<>1 THEN @_debit-@_remaining ELSE 0 END,
    SUBAT = CASE WHEN @_month=2 THEN @_debit-@_remaining ELSE 0 END,
    MART = CASE WHEN @_month=3 THEN @_debit-@_remaining ELSE 0 END,
    NISAN = CASE WHEN @_month=4 THEN @_debit-@_remaining ELSE 0 END,
    MAYIS = CASE WHEN @_month=5 THEN @_debit-@_remaining ELSE 0 END,
    HAZIRAN = CASE WHEN @_month=6 THEN @_debit-@_remaining ELSE 0 END,
    TEMMUZ = CASE WHEN @_month=7 THEN @_debit-@_remaining ELSE 0 END,
    AGUSTOS = CASE WHEN @_month=8 THEN @_debit-@_remaining ELSE 0 END,
    EYLUL = CASE WHEN @_month=9 THEN @_debit-@_remaining ELSE 0 END,
    EKIM = CASE WHEN @_month=10 THEN @_debit-@_remaining ELSE 0 END,
    KASIM = CASE WHEN @_month=11 THEN @_debit-@_remaining ELSE 0 END,
    ARALIK = CASE WHEN @_month=12 THEN @_debit-@_remaining ELSE 0 END
    WHERE RECID=@_recid
    END
    
    FETCH NEXT FROM MY_CURSOR INTO @_sign,@_debit,@_credit,@_date,@_lineexp,@_accountcode,@_invoiceno,@_month,@_accountname,@_trcode
END
CLOSE MY_CURSOR
DEALLOCATE MY_CURSOR


-- ÖZET

SELECT ACCOUNTCODE,ACCOUNTNAME
,SUM(DEBIT) AS BORÇ
,SUM(CREDIT) AS ALACAK
,SUM(DEBIT)-SUM(CREDIT) AS BAKIYE
,SUM(ACILIS) as Acilis
,SUM(OCAK) as Ocak
,SUM(SUBAT) as Subat
,SUM(MART) as Mart
,SUM(NISAN) as Nisan
,SUM(MAYIS) as Mayis
,SUM(HAZIRAN) as Haziran
,SUM(TEMMUZ) as Temmuz
,SUM(AGUSTOS) as Agustos
,SUM(EYLUL) as Eylul
,SUM(EKIM) as Ekim
,SUM(KASIM) as Kasim
,SUM(ARALIK) as Aralik
,((SUM(DEBIT)-SUM(CREDIT))-SUM(ACILIS)-SUM(OCAK)-SUM(SUBAT)-SUM(MART)-SUM(NISAN)-SUM(MAYIS)-SUM(HAZIRAN)-SUM(TEMMUZ)-SUM(AGUSTOS)
-SUM(EYLUL)-SUM(EKIM)-SUM(KASIM)-SUM(ARALIK)) AS SAGLAMA
from #tempresults
GROUP BY ACCOUNTCODE,ACCOUNTNAME


-- DETAY
SELECT * FROM #tempresults






If(OBJECT_ID('tempdb..#tempcredits') Is Not Null)
Begin
    Drop Table #tempcredits
End

If(OBJECT_ID('tempdb..#tempresults') Is Not Null)
Begin
    Drop Table #tempresults
End
