--** NOVA MARRETA - MAR�O/2015

DECLARE @SIG_AEROPORTO VARCHAR(4)
      ,	@DATA_PESQUISA VARCHAR(30)
	  ,	@SQL VARCHAR(MAX)

SELECT  @DATA_PESQUISA = CONVERT(VARCHAR(4), YEAR(DATEADD(MONTH, -1, GETDATE()))) + RIGHT('00' + CONVERT(VARCHAR(4), MONTH(DATEADD(MONTH, -1, GETDATE()))), 2) + '01 23:59'

DECLARE des_cursor_max CURSOR FOR 
SELECT	DISTINCT
		SIG_AEROPORTO
  FROM	[IEOP].[dbo].[RPE_DESEMBARQUE]  WITH (NOLOCK)

OPEN des_cursor_max

FETCH NEXT FROM des_cursor_max
INTO @SIG_AEROPORTO


WHILE @@FETCH_STATUS = 0
BEGIN
	SELECT @SQL =  '
	PRINT ''' + @SIG_AEROPORTO + '''
	BEGIN TRY
		BEGIN TRAN UPD_DESEMBARQUE
		SELECT	DES.* 
		--UPDATE [IEOP].[dbo].[RPE_DESEMBARQUE] SET FLG_MIGRADO = 0, DTH_MIGRACAO = NULL
			FROM	[IEOP].[dbo].[RPE_DESEMBARQUE] DES WITH (NOLOCK)
				,  (
					SELECT --TOP 1000 *
							NUM_VOO
							,	DTH_NORMAL_POUSO
							,  SIG_CIA_AEREA_IATA
						FROM [IEOP].[dbo].[RPE_DESEMBARQUE]  WITH (NOLOCK)
						WHERE SIG_AEROPORTO = ''' + @SIG_AEROPORTO + '''
						AND [DTH_NORMAL_POUSO] > ''' + @DATA_PESQUISA + '''
					EXCEPT
					SELECT --TOP 1000 *
							NR_CHG_VOO COLLATE SQL_Latin1_General_CP1_CI_AI
						,	DH_CHG_NRM 
						,   SG_COM_IAT_003 COLLATE SQL_Latin1_General_CP1_CI_AI
					FROM	[' + @SIG_AEROPORTO + ' - INTEGRACAO].[integracao].[dbo].INTEGRACAO_IEOP_SISO_RPE_DES AER WITH (NOLOCK)
					WHERE   DH_CHG_EFE > ''' + @DATA_PESQUISA + '''
				) AS DIF
		WHERE  DES.NUM_VOO = DIF.NUM_VOO
			AND  DES.DTH_NORMAL_POUSO = DIF.DTH_NORMAL_POUSO
			AND  DES.SIG_CIA_AEREA_IATA = DIF.SIG_CIA_AEREA_IATA

		COMMIT TRAN UPD_DESEMBARQUE
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN UPD_DESEMBARQUE
	END CATCH	

	BEGIN TRY
		BEGIN TRAN UPD_EMBARQUE
		SELECT	DES.*
		--UPDATE [IEOP].[dbo].[RPE_EMBARQUE] SET FLG_MIGRADO = 0, DTH_MIGRACAO = NULL
			FROM	[IEOP].[dbo].[RPE_EMBARQUE] DES WITH (NOLOCK)
				,  (
					SELECT --TOP 1000 *
							NUM_VOO
							,	DTH_NORMAL_DECOLAGEM
							,  SIG_CIA_AEREA_IATA
						FROM [IEOP].[dbo].[RPE_EMBARQUE]  WITH (NOLOCK)
						WHERE SIG_AEROPORTO = ''' + @SIG_AEROPORTO + '''
						AND DTH_NORMAL_DECOLAGEM > ''' + @DATA_PESQUISA + '''
					EXCEPT
					SELECT --TOP 1000 *
							NR_PAR_VOO COLLATE SQL_Latin1_General_CP1_CI_AI
						,	DH_PAR_NRM 
						,   SG_COM_IAT_003 COLLATE SQL_Latin1_General_CP1_CI_AI
					FROM	[' + @SIG_AEROPORTO + ' - INTEGRACAO].[integracao].[dbo].INTEGRACAO_IEOP_SISO_RPE_EMB AER WITH (NOLOCK)
					WHERE   DH_PAR_EFE > ''' + @DATA_PESQUISA + '''
				) AS DIF
		WHERE  DES.NUM_VOO = DIF.NUM_VOO
			AND  DES.DTH_NORMAL_DECOLAGEM = DIF.DTH_NORMAL_DECOLAGEM
			AND  DES.SIG_CIA_AEREA_IATA = DIF.SIG_CIA_AEREA_IATA

		COMMIT TRAN UPD_EMBARQUE
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN UPD_EMBARQUE
	END CATCH	'

	 EXECUTE(@SQL)

	 FETCH NEXT FROM des_cursor_max
	 INTO @SIG_AEROPORTO

END;

CLOSE des_cursor_max;
DEALLOCATE des_cursor_max;

 -- [dbo].[PRC_MIGRA_RPE_SISO] 'SBPA'

--******

SELECT  CONVERT(VARCHAR(10), DH_PAR_EFE, 112) DATA_VOO
     ,  COUNT(1) TOTAL
FROM	[SBRJ - INTEGRACAO].[integracao].[dbo].INTEGRACAO_IEOP_SISO_RPE_EMB AER WITH (NOLOCK)
WHERE   DH_PAR_EFE > '20141031'
--WHERE DTH_CARGA_SISO IS NULL
GROUP BY  CONVERT(VARCHAR(10), DH_PAR_EFE, 112)
ORDER BY 1

SELECT  CONVERT(VARCHAR(10), DH_CHG_EFE, 112) DATA_VOO
     ,  COUNT(1) TOTAL
FROM	[SBRJ - INTEGRACAO].[integracao].[dbo].INTEGRACAO_IEOP_SISO_RPE_DES AER WITH (NOLOCK)
WHERE   DH_CHG_EFE > '20141031'
--WHERE DTH_CARGA_SISO IS NULL
GROUP BY  CONVERT(VARCHAR(10), DH_CHG_EFE, 112)
ORDER BY 1

SELECT	SIG_AEROPORTO
     ,	COUNT(1) AS TOTAL
 FROM	IEOP.[dbo].[RPE_DESEMBARQUE]
 --UPDATE IEOP.[dbo].[RPE_DESEMBARQUE] SET DTH_MIGRACAO = NULL, FLG_MIGRADO = 0
WHERE   DTH_EFETIVA_POUSO > '20141031' AND DTH_EFETIVA_POUSO < '20141201'
  AND   SIG_AEROPORTO IN ('SBPV', 'SBKG', 'SBLO', 'SBUR', 'SBIL', 'SBGO', 'SBCT', 'SBCF', 'SBMQ', 'SBSN', 'SBEG', 'SBCR', 'SBJV', 'SBGL', 'SBJP', 'SBPJ', 'SBRB', 'SBTE', 'SBSL', 'SBAR', 'SBFL')
GROUP BY SIG_AEROPORTO
ORDER BY 1
COMPUTE SUM(COUNT(1))


SELECT	SIG_AEROPORTO
     ,	COUNT(1) AS TOTAL
 FROM	IEOP.[dbo].[RPE_EMBARQUE]
--UPDATE IEOP.[dbo].[RPE_EMBARQUE] SET DTH_MIGRACAO = NULL, FLG_MIGRADO = 0
WHERE   DTH_EFETIVA_DECOLAGEM > '20141031' AND DTH_EFETIVA_DECOLAGEM < '20141201'
  AND   SIG_AEROPORTO IN ('SBPV', 'SBKG', 'SBLO', 'SBUR', 'SBIL', 'SBGO', 'SBCT', 'SBCF', 'SBMQ', 'SBSN', 'SBEG', 'SBCR', 'SBJV', 'SBGL', 'SBJP', 'SBPJ', 'SBRB', 'SBTE', 'SBSL', 'SBAR', 'SBFL')
GROUP BY SIG_AEROPORTO
ORDER BY 1
COMPUTE SUM(COUNT(1))


/*

DECLARE @SIG_AEROPORTO VARCHAR(10)
      ,	@SQL VARCHAR(MAX)

DECLARE des_cursor CURSOR FOR 
SELECT	DISTINCT SIG_AEROPORTO
  FROM	IEOP.[dbo].[RPE_DESEMBARQUE]
 WHERE  SIG_AEROPORTO IN (  'SBAR','SBBE','SBBH','SBBV','SBCF','SBCG','SBCR','SBCT','SBCY','SBCZ','SBEG',
							'SBFI','SBFL','SBFZ','SBGL','SBGO','SBIL','SBIZ','SBJP','SBJU','SBJV','SBKG',
							'SBLO','SBMA','SBMO','SBMQ','SBNF','SBPA','SBPJ','SBPK','SBPV','SBRB','SBRF',
							'SBRJ','SBSL','SBSN','SBSP','SBSV','SBTE','SBUL','SBUR','SBVT' )

OPEN des_cursor

SET NOCOUNT ON

FETCH NEXT FROM des_cursor
INTO @SIG_AEROPORTO

WHILE @@FETCH_STATUS = 0
BEGIN
	
	PRINT 'AEROPORTO -> ' + @SIG_AEROPORTO
	PRINT ' '

	SELECT @SQL = '
	SELECT  CONVERT(VARCHAR(10), DH_PAR_EFE, 112) DATA_VOO
			,  COUNT(1) TOTAL
	FROM	[' + @SIG_AEROPORTO + ' - INTEGRACAO].[integracao].[dbo].INTEGRACAO_IEOP_SISO_RPE_EMB AER WITH (NOLOCK)
	WHERE   DH_PAR_EFE > ''20141031''
	GROUP BY  CONVERT(VARCHAR(10), DH_PAR_EFE, 112)
	ORDER BY 1 '

	--PRINT @SQL
	EXECUTE(@SQL)

	FETCH NEXT FROM des_cursor
	INTO @SIG_AEROPORTO

END

CLOSE des_cursor;
DEALLOCATE des_cursor;

*/



--RPE N�O MIGRADOS POR FALHA NA TRIGGER - DESEMBARQUE
/*

DECLARE @SGL_AEROPORTO VARCHAR(10)
      , @COD_AEROPORTO INT
	  , @DTH_VOO DATETIME
	  , @NOM_EMPRESA VARCHAR(100)
	  , @NUM_VOO VARCHAR(10)
      ,	@SQL VARCHAR(MAX)
	  , @FLAG INT
	  , @SEQ_RPE_DESEMBARQUE INT

DECLARE des_cursor CURSOR FOR 
SELECT  COD_AEROPORTO = UPD.[COD_AEROPORTO]
	,	SGL_AEROPORTO = (SELECT DEP_SIGLA FROM IFRCORP..DEPENDENCIAS WHERE DEP_CODIGO = UPD.[COD_AEROPORTO]) 
	,	DTH_VOO = UPD.[DTH_VOO]
	,	NOM_EMPRESA = UPD.[NOM_EMPRESA]
	,	NUM_VOO = UPD.[NUM_VOO]
	,   SEQ_RPE_DESEMBARQUE
 FROM	[IFRRPEWEB].[dbo].[CAD_RPE_DESEMBARQUE]  UPD WITH (NOLOCK)
WHERE   DTH_VOO > '20141210' AND DTH_VOO < '20141221'

OPEN des_cursor

SET NOCOUNT ON

FETCH NEXT FROM des_cursor
INTO    @COD_AEROPORTO
	,	@SGL_AEROPORTO
	,	@DTH_VOO
	,	@NOM_EMPRESA
	,	@NUM_VOO
	,   @SEQ_RPE_DESEMBARQUE

WHILE @@FETCH_STATUS = 0
BEGIN

	SET @FLAG = 0 

	SELECT @FLAG = 1
	 FROM [IEOP].[dbo].[RPE_DESEMBARQUE]  WITH (NOLOCK)
	 WHERE	NUM_GRUPO_VOO_DESEMB = 1
	   AND	SIG_AEROPORTO = @SGL_AEROPORTO 
	   AND	DTH_NORMAL_POUSO = @DTH_VOO
	   AND	SIG_CIA_AEREA_IATA = @NOM_EMPRESA
	   AND	CONVERT(INT, NUM_VOO) = CONVERT(INT, @NUM_VOO)

	IF (@FLAG = 0) BEGIN
		SELECT @SQL = 'UPDATE [IFRRPEWEB].[dbo].[CAD_RPE_DESEMBARQUE] SET NOM_EMPRESA = ''' + @NOM_EMPRESA + ''' WHERE SEQ_RPE_DESEMBARQUE = ' + CONVERT(VARCHAR(MAX), @SEQ_RPE_DESEMBARQUE)
		
		PRINT @SQL
	END
		
	FETCH NEXT FROM des_cursor
	INTO    @COD_AEROPORTO
		,	@SGL_AEROPORTO
		,	@DTH_VOO
		,	@NOM_EMPRESA
		,	@NUM_VOO
		,   @SEQ_RPE_DESEMBARQUE

END

CLOSE des_cursor;
DEALLOCATE des_cursor;

*/

--VALIDA RPE DESEMBARQUE
/*



SELECT * FROM (
SELECT  *,	SGL_AEROPORTO = (SELECT DEP_SIGLA FROM IFRCORP..DEPENDENCIAS WHERE DEP_CODIGO = UPD.[COD_AEROPORTO]) 
 FROM	[IFRRPEWEB].[DBO].[CAD_RPE_DESEMBARQUE] UPD ) A
 WHERE SGL_AEROPORTO='SBBE'
 AND   CONVERT(VARCHAR(8),DTH_VOO,112) = '20141221'
 AND   NOM_EMPRESA = 'GLO'
 AND   NUM_VOO = 1255
 

DECLARE @SGL_AEROPORTO VARCHAR(10)
      , @COD_AEROPORTO INT
	  , @DTH_VOO DATETIME
	  , @NOM_EMPRESA VARCHAR(100)
	  , @NUM_VOO VARCHAR(10)
      ,	@SQL VARCHAR(MAX)
	  , @FLAG INT
	  , @SEQ_RPE_DESEMBARQUE INT

SET @SEQ_RPE_DESEMBARQUE = 227591

SELECT  *,	SGL_AEROPORTO = (SELECT DEP_SIGLA FROM IFRCORP..DEPENDENCIAS WHERE DEP_CODIGO = UPD.[COD_AEROPORTO]) 
 FROM	[IFRRPEWEB].[dbo].[CAD_RPE_DESEMBARQUE]  UPD WITH (NOLOCK)
 WHERE SEQ_RPE_DESEMBARQUE = @SEQ_RPE_DESEMBARQUE

 SELECT  @COD_AEROPORTO = UPD.[COD_AEROPORTO]
	,	@SGL_AEROPORTO = (SELECT DEP_SIGLA FROM IFRCORP..DEPENDENCIAS WHERE DEP_CODIGO = UPD.[COD_AEROPORTO]) 
	,	@DTH_VOO = UPD.[DTH_VOO]
	,	@NOM_EMPRESA = UPD.[NOM_EMPRESA]
	,	@NUM_VOO = UPD.[NUM_VOO]
 FROM	[IFRRPEWEB].[dbo].[CAD_RPE_DESEMBARQUE]  UPD WITH (NOLOCK)
 WHERE SEQ_RPE_DESEMBARQUE = @SEQ_RPE_DESEMBARQUE

 SELECT TOP 1000 *
  FROM [IEOP].[dbo].[RPE_DESEMBARQUE]
 WHERE NUM_GRUPO_VOO_DESEMB = 1
   AND	SIG_AEROPORTO = @SGL_AEROPORTO 
   AND	DTH_NORMAL_POUSO = @DTH_VOO
   AND	SIG_CIA_AEREA_IATA = @NOM_EMPRESA
   AND	CONVERT(INT, NUM_VOO) = CONVERT(INT, @NUM_VOO)

 SELECT TOP 1000 *
  FROM [IEOP].[dbo].[RPE_DESEMBARQUE]
 WHERE NUM_GRUPO_VOO_DESEMB = 1
   AND	SIG_AEROPORTO = @SGL_AEROPORTO 
   AND	CONVERT(VARCHAR(10), DTH_NORMAL_POUSO, 112) = CONVERT(VARCHAR(10), @DTH_VOO, 112)
   AND	SIG_CIA_AEREA_IATA = @NOM_EMPRESA
   AND	CONVERT(INT, NUM_VOO) = CONVERT(INT, @NUM_VOO)

 SELECT TOP 1000 *
  FROM [IEOP].[dbo].[IEOP_DESEMBARQUE]
 WHERE NUM_GRUPO_VOO_DESEMB = 1
   AND	SIG_AEROPORTO = @SGL_AEROPORTO 
   AND	CONVERT(VARCHAR(10), DTH_NORMAL_POUSO, 112) = CONVERT(VARCHAR(10), @DTH_VOO, 112)
   AND	SIG_CIA_AEREA_IATA = @NOM_EMPRESA
   AND	CONVERT(INT, NUM_VOO) = CONVERT(INT, @NUM_VOO)

SELECT  *
FROM	[SBBE - INTEGRACAO].[integracao].[dbo].INTEGRACAO_IEOP_SISO_RPE_DES AER WITH (NOLOCK)
WHERE   CONVERT(VARCHAR(10), DH_CHG_NRM, 112) = CONVERT(VARCHAR(10), @DTH_VOO, 112)
AND     CONVERT(INT, NR_CHG_VOO) = CONVERT(INT, @NUM_VOO) 
AND	    SG_COM_IAT_003 = @NOM_EMPRESA


*/

--RPE N�O MIGRADOS POR FALHA NA TRIGGER - EMBARQUE
/*

DECLARE @SGL_AEROPORTO VARCHAR(10)
      , @COD_AEROPORTO INT
	  , @DTH_VOO DATETIME
	  , @NOM_EMPRESA VARCHAR(100)
	  , @NUM_VOO VARCHAR(10)
      ,	@SQL VARCHAR(MAX)
	  , @FLAG INT
	  , @SEQ_RPE_EMBARQUE INT

DECLARE des_cursor CURSOR FOR 
SELECT  COD_AEROPORTO = UPD.[COD_AEROPORTO]
	,	SGL_AEROPORTO = (SELECT DEP_SIGLA FROM IFRCORP..DEPENDENCIAS WHERE DEP_CODIGO = UPD.[COD_AEROPORTO]) 
	,	DTH_VOO = UPD.[DTH_VOO]
	,	NOM_EMPRESA = UPD.[NOM_EMPRESA]
	,	NUM_VOO = UPD.[NUM_VOO]
	,   SEQ_RPE_EMBARQUE
 FROM	[IFRRPEWEB].[dbo].[CAD_RPE_EMBARQUE]  UPD WITH (NOLOCK)
WHERE   DTH_VOO > '20141031' AND DTH_VOO < '20141201'

OPEN des_cursor

SET NOCOUNT ON

FETCH NEXT FROM des_cursor
INTO    @COD_AEROPORTO
	,	@SGL_AEROPORTO
	,	@DTH_VOO
	,	@NOM_EMPRESA
	,	@NUM_VOO
	,   @SEQ_RPE_EMBARQUE

WHILE @@FETCH_STATUS = 0
BEGIN

	SET @FLAG = 0 

	SELECT @FLAG = 1
	 FROM [IEOP].[dbo].[RPE_EMBARQUE]  WITH (NOLOCK)
	 WHERE	NUM_GRUPO_VOO_EMB = 1
	   AND	SIG_AEROPORTO = @SGL_AEROPORTO 
	   AND	DTH_NORMAL_DECOLAGEM = @DTH_VOO
	   AND	SIG_CIA_AEREA_IATA = @NOM_EMPRESA
	   AND	CONVERT(INT, NUM_VOO) = CONVERT(INT, @NUM_VOO)

	IF (@FLAG = 0) BEGIN
		SELECT @SQL = 'UPDATE [IFRRPEWEB].[dbo].[CAD_RPE_EMBARQUE] SET NOM_EMPRESA = ''' + @NOM_EMPRESA + ''' WHERE SEQ_RPE_EMBARQUE = ' + CONVERT(VARCHAR(MAX), @SEQ_RPE_EMBARQUE)
		
		PRINT @SQL
	END
		
	FETCH NEXT FROM des_cursor
	INTO    @COD_AEROPORTO
		,	@SGL_AEROPORTO
		,	@DTH_VOO
		,	@NOM_EMPRESA
		,	@NUM_VOO
		,   @SEQ_RPE_EMBARQUE

END

CLOSE des_cursor;
DEALLOCATE des_cursor;

*/

--VALIDA RPE EMBARQUE
/*

SELECT * FROM (
SELECT  *,	SGL_AEROPORTO = (SELECT DEP_SIGLA FROM IFRCORP..DEPENDENCIAS WHERE DEP_CODIGO = UPD.[COD_AEROPORTO]) 
 FROM	[IFRRPEWEB].[DBO].[CAD_RPE_EMBARQUE] UPD ) A
 WHERE SGL_AEROPORTO='SBPA'
 AND   CONVERT(VARCHAR(8),DTH_VOO,112) = '20141214'
 AND   NOM_EMPRESA = 'AZU'
 AND   NUM_VOO = 4042

DECLARE @SGL_AEROPORTO VARCHAR(10)
      , @COD_AEROPORTO INT
	  , @DTH_VOO DATETIME
	  , @NOM_EMPRESA VARCHAR(100)
	  , @NUM_VOO VARCHAR(10)
      ,	@SQL VARCHAR(MAX)
	  , @FLAG INT
	  , @SEQ_RPE_EMBARQUE INT

SET @SEQ_RPE_EMBARQUE = 196245

SELECT  SGL_AEROPORTO = (SELECT DEP_SIGLA FROM IFRCORP..DEPENDENCIAS WHERE DEP_CODIGO = UPD.[COD_AEROPORTO]), *
 FROM	[IFRRPEWEB].[dbo].[CAD_RPE_EMBARQUE]  UPD WITH (NOLOCK)
 WHERE SEQ_RPE_EMBARQUE = @SEQ_RPE_EMBARQUE

 SELECT  @COD_AEROPORTO = UPD.[COD_AEROPORTO]
	,	@SGL_AEROPORTO = (SELECT DEP_SIGLA FROM IFRCORP..DEPENDENCIAS WHERE DEP_CODIGO = UPD.[COD_AEROPORTO]) 
	,	@DTH_VOO = UPD.[DTH_VOO]
	,	@NOM_EMPRESA = UPD.[NOM_EMPRESA]
	,	@NUM_VOO = UPD.[NUM_VOO]
 FROM	[IFRRPEWEB].[dbo].[CAD_RPE_EMBARQUE]  UPD WITH (NOLOCK)
 WHERE SEQ_RPE_EMBARQUE = @SEQ_RPE_EMBARQUE

 SELECT TOP 1000 *
  FROM [IEOP].[dbo].[RPE_EMBARQUE]
 WHERE NUM_GRUPO_VOO_EMB = 1
   AND	SIG_AEROPORTO = @SGL_AEROPORTO 
   AND	DTH_NORMAL_DECOLAGEM = @DTH_VOO
   AND	SIG_CIA_AEREA_IATA = @NOM_EMPRESA
   AND	CONVERT(INT, NUM_VOO) = CONVERT(INT, @NUM_VOO)

 SELECT TOP 1000 *
  FROM [IEOP].[dbo].[RPE_EMBARQUE]
 WHERE NUM_GRUPO_VOO_EMB = 1
   AND	SIG_AEROPORTO = @SGL_AEROPORTO 
   AND	CONVERT(VARCHAR(10), DTH_NORMAL_DECOLAGEM, 112) = CONVERT(VARCHAR(10), @DTH_VOO, 112)
   AND	SIG_CIA_AEREA_IATA = @NOM_EMPRESA
   AND	CONVERT(INT, NUM_VOO) = CONVERT(INT, @NUM_VOO)

 SELECT TOP 1000 *
  FROM [IEOP].[dbo].[IEOP_EMBARQUE]
 WHERE NUM_GRUPO_VOO_EMB = 1
   AND	SIG_AEROPORTO = @SGL_AEROPORTO 
   AND	CONVERT(VARCHAR(10), DTH_NORMAL_DECOLAGEM, 112) = CONVERT(VARCHAR(10), @DTH_VOO, 112)
   AND	SIG_CIA_AEREA_IATA = @NOM_EMPRESA
   AND	CONVERT(INT, NUM_VOO) = CONVERT(INT, @NUM_VOO)

SELECT  *
FROM	[SBBE - INTEGRACAO].[integracao].[dbo].INTEGRACAO_IEOP_SISO_RPE_DES AER WITH (NOLOCK)
WHERE   CONVERT(VARCHAR(10), DH_CHG_NRM, 112) = CONVERT(VARCHAR(10), @DTH_VOO, 112)
AND     CONVERT(INT, NR_CHG_VOO) = CONVERT(INT, @NUM_VOO) 
AND	    SG_COM_IAT_003 = @NOM_EMPRESA

*/

/*

SELECT * FROM IEOP..IEOP_DESEMBARQUE WHERE SIG_AEROPORTO = 'SBBE' AND COD_STATUS = 241182

*/

/*

 SELECT --TOP 1000 
       SIG_AEROPORTO,	
	   NUM_VOO,
	   DTH_NORMAL_DECOLAGEM,
	   COD_CIA_AEREA,
	   COD_MATRICULA_AERONAVE,
	   COD_STATUS,
	   TIP_STATUS,
	   DTH_ATUALIZACAO,
	   FLG_MIGRADO,
	   DTH_MIGRACAO,
	   COUNT(1) TOTAL
  FROM [IEOP].[dbo].[RPE_EMBARQUE]
 WHERE  CONVERT(VARCHAR(10), DTH_NORMAL_DECOLAGEM, 112) >= '20141201'
 GROUP BY SIG_AEROPORTO,	
	   NUM_VOO,
	   DTH_NORMAL_DECOLAGEM,
	   COD_CIA_AEREA,
	   COD_MATRICULA_AERONAVE,
	   COD_STATUS,
	   TIP_STATUS,
	   DTH_ATUALIZACAO,
	   FLG_MIGRADO,
	   DTH_MIGRACAO
  HAVING COUNT(1) > 1
  ORDER BY SIG_AEROPORTO,	
	   DTH_NORMAL_DECOLAGEM

*/


--MARRETA PARA REPROCESSAR VOOS QUE FORAM GRAVADOS MAIS DE UMA VEZ - EMBARQUE
/*

DECLARE	@SIG_AEROPORTO		VARCHAR(10)
	  ,	@DTA_BUSCA			VARCHAR(8)
	  ,	@SEQ_RPE_EMBARQUE	INT
      ,	@COD_AEROPORTO		VARCHAR(4)	
	  ,	@DTH_VOO			DATETIME
	  ,	@NUM_VOO			VARCHAR(4)
	  ,	@NOM_EMPRESA		VARCHAR(100)

SET		@SIG_AEROPORTO	=	'SBBE'
SET		@DTA_BUSCA		=	'20141201'

--BEGIN TRAN
--ROLLBACK TRAN
--COMMIT TRAN

DECLARE des_cursor CURSOR FOR 
SELECT	DISTINCT
		RPE.COD_AEROPORTO
	 ,	RPE.DTH_VOO
	 ,  RPE.NUM_VOO
	 ,  RPE.NOM_EMPRESA
	 ,  IEOP.SIG_AEROPORTO
  FROM  (
		SELECT	DISTINCT
				(SELECT DEP_CODIGO FROM IFRCORP..DEPENDENCIAS WHERE DEP_SIGLA = SIG_AEROPORTO ) AS COD_AEROPORTO
			 ,	SIG_AEROPORTO
			 ,	DTH_NORMAL_DECOLAGEM AS DTH_VOO
			 ,	SIG_CIA_AEREA_IATA AS NOM_EMPRESA
			 ,	TMP.NUM_VOO
		  FROM (
				SELECT --TOP 1000 
					SIG_AEROPORTO,	
					NUM_VOO,
					DTH_NORMAL_DECOLAGEM,
					SIG_CIA_AEREA_IATA,
					COD_MATRICULA_AERONAVE,
					COD_STATUS,
					TIP_STATUS,
					DTH_ATUALIZACAO,
					FLG_MIGRADO,
					DTH_MIGRACAO,
					COUNT(1) TOTAL
				FROM [IEOP].[dbo].[RPE_EMBARQUE] WITH (NOLOCK)
				WHERE  CONVERT(VARCHAR(10), DTH_NORMAL_DECOLAGEM, 112) >= @DTA_BUSCA
				GROUP BY SIG_AEROPORTO,	
					NUM_VOO,
					DTH_NORMAL_DECOLAGEM,
					SIG_CIA_AEREA_IATA,
					COD_MATRICULA_AERONAVE,
					COD_STATUS,
					TIP_STATUS,
					DTH_ATUALIZACAO,
					FLG_MIGRADO,
					DTH_MIGRACAO
				HAVING COUNT(1) > 1 ) AS TMP ) AS IEOP
	 ,  [IFRRPEWEB].[dbo].[CAD_RPE_EMBARQUE]  RPE WITH (NOLOCK)
 WHERE  IEOP.SIG_AEROPORTO = @SIG_AEROPORTO
   AND  IEOP.COD_AEROPORTO = RPE.COD_AEROPORTO
   AND  IEOP.DTH_VOO = RPE.DTH_VOO
   AND  IEOP.NOM_EMPRESA = RPE.NOM_EMPRESA
   AND  IEOP.NUM_VOO = RPE.NUM_VOO
 ORDER
    BY	1, 2, 3, 4
 
 
OPEN des_cursor

SET NOCOUNT ON

FETCH NEXT FROM des_cursor
INTO    @COD_AEROPORTO
	 ,	@DTH_VOO
	 ,  @NUM_VOO
	 ,  @NOM_EMPRESA
	 ,  @SIG_AEROPORTO

WHILE @@FETCH_STATUS = 0
BEGIN
		
	--UPDATE	[IFRRPEWEB].[dbo].[CAD_RPE_EMBARQUE]  SET	COD_AEROPORTO = RPE.COD_AEROPORTO
	SELECT	TOP 10 *
	  FROM (
			SELECT	MAX(SEQ_RPE_EMBARQUE) AS MAX_SEQ_RPE_EMBARQUE
			FROM	[IFRRPEWEB].[dbo].[CAD_RPE_EMBARQUE]  RPE WITH (NOLOCK)
			WHERE	CONVERT(VARCHAR(10), DTH_VOO, 112) = CONVERT(VARCHAR(8), @DTH_VOO, 112)
			  AND	COD_AEROPORTO = @COD_AEROPORTO
			  AND   NOM_EMPRESA =  @NOM_EMPRESA
			  AND   NUM_VOO = @NUM_VOO) AS TMP
		 ,  [IFRRPEWEB].[dbo].[CAD_RPE_EMBARQUE]  RPE WITH (NOLOCK)
	 WHERE	RPE.SEQ_RPE_EMBARQUE = TMP.MAX_SEQ_RPE_EMBARQUE

	FETCH NEXT FROM des_cursor
	INTO    @COD_AEROPORTO
		 ,	@DTH_VOO
		 ,  @NUM_VOO
		 ,  @NOM_EMPRESA
		 ,  @SIG_AEROPORTO

END

CLOSE des_cursor;
DEALLOCATE des_cursor;  

*/


--MARRETA PARA REPROCESSAR VOOS QUE FORAM GRAVADOS MAIS DE UMA VEZ - DESEMBARQUE
/*

DECLARE	@SIG_AEROPORTO		VARCHAR(10)
	  ,	@DTA_BUSCA			VARCHAR(8)
      ,	@COD_AEROPORTO		VARCHAR(4)	
	  ,	@DTH_VOO			DATETIME
	  ,	@NUM_VOO			VARCHAR(4)
	  ,	@NOM_EMPRESA		VARCHAR(100)

SET		@SIG_AEROPORTO	=	'SBVT'
SET		@DTA_BUSCA		=	'20141201'

--BEGIN TRAN
--ROLLBACK TRAN
--COMMIT TRAN

DECLARE emb_cursor CURSOR FOR 
SELECT	DISTINCT
		RPE.COD_AEROPORTO
	 ,	RPE.DTH_VOO
	 ,  RPE.NUM_VOO
	 ,  RPE.NOM_EMPRESA
	 ,  IEOP.SIG_AEROPORTO
  FROM  (
		SELECT	DISTINCT
				(SELECT DEP_CODIGO FROM IFRCORP..DEPENDENCIAS WHERE DEP_SIGLA = SIG_AEROPORTO ) AS COD_AEROPORTO
			 ,	SIG_AEROPORTO
			 ,	DTH_NORMAL_POUSO AS DTH_VOO
			 ,	SIG_CIA_AEREA_IATA AS NOM_EMPRESA
			 ,	TMP.NUM_VOO
		  FROM (
				SELECT --TOP 1000 
					SIG_AEROPORTO,	
					NUM_VOO,
					DTH_NORMAL_POUSO,
					SIG_CIA_AEREA_IATA,
					COD_MATRICULA_AERONAVE,
					COD_STATUS,
					TIP_STATUS,
					DTH_ATUALIZACAO,
					FLG_MIGRADO,
					DTH_MIGRACAO,
					COUNT(1) TOTAL
				FROM [IEOP].[dbo].[RPE_DESEMBARQUE] WITH (NOLOCK)
				WHERE  CONVERT(VARCHAR(10), DTH_NORMAL_POUSO, 112) >= @DTA_BUSCA
				GROUP BY SIG_AEROPORTO,	
					NUM_VOO,
					DTH_NORMAL_POUSO,
					SIG_CIA_AEREA_IATA,
					COD_MATRICULA_AERONAVE,
					COD_STATUS,
					TIP_STATUS,
					DTH_ATUALIZACAO,
					FLG_MIGRADO,
					DTH_MIGRACAO
				HAVING COUNT(1) > 1 ) AS TMP ) AS IEOP
	 ,  [IFRRPEWEB].[dbo].[CAD_RPE_DESEMBARQUE]  RPE WITH (NOLOCK)
 WHERE  IEOP.SIG_AEROPORTO = @SIG_AEROPORTO
   AND  IEOP.COD_AEROPORTO = RPE.COD_AEROPORTO
   AND  IEOP.DTH_VOO = RPE.DTH_VOO
   AND  IEOP.NOM_EMPRESA = RPE.NOM_EMPRESA
   AND  IEOP.NUM_VOO = RPE.NUM_VOO
 ORDER
    BY	1, 2, 3, 4
 
 
OPEN emb_cursor

SET NOCOUNT ON

FETCH NEXT FROM emb_cursor
INTO    @COD_AEROPORTO
	 ,	@DTH_VOO
	 ,  @NUM_VOO
	 ,  @NOM_EMPRESA
	 ,  @SIG_AEROPORTO

WHILE @@FETCH_STATUS = 0
BEGIN
		
	--UPDATE	[IFRRPEWEB].[dbo].[CAD_RPE_DESEMBARQUE]  SET	COD_AEROPORTO = RPE.COD_AEROPORTO
	SELECT	TOP 10 *
	  FROM (
			SELECT	MAX(SEQ_RPE_DESEMBARQUE) AS MAX_SEQ_RPE_DESEMBARQUE
			FROM	[IFRRPEWEB].[dbo].[CAD_RPE_DESEMBARQUE]  RPE WITH (NOLOCK)
			WHERE	CONVERT(VARCHAR(10), DTH_VOO, 112) = CONVERT(VARCHAR(8), @DTH_VOO, 112)
			  AND	COD_AEROPORTO = @COD_AEROPORTO
			  AND   NOM_EMPRESA =  @NOM_EMPRESA
			  AND   NUM_VOO = @NUM_VOO) AS TMP
		 ,  [IFRRPEWEB].[dbo].[CAD_RPE_DESEMBARQUE]  RPE WITH (NOLOCK)
	 WHERE	RPE.SEQ_RPE_DESEMBARQUE = TMP.MAX_SEQ_RPE_DESEMBARQUE

	FETCH NEXT FROM emb_cursor
	INTO    @COD_AEROPORTO
		 ,	@DTH_VOO
		 ,  @NUM_VOO
		 ,  @NOM_EMPRESA
		 ,  @SIG_AEROPORTO

END

CLOSE emb_cursor;
DEALLOCATE emb_cursor;  

*/

/*

DECLARE  @DTA VARCHAR(8)
      ,  @VOO_PAR VARCHAR(8)
	  ,  @VOO_CHG VARCHAR(8)
	  ,  @AER VARCHAR(8)
	  ,  @CIA VARCHAR(8)
	  ,  @SQL VARCHAR(MAX)


SELECT	 @DTA = '20141225'
      ,  @VOO_PAR = 9030
	  ,  @VOO_CHG = 3062
	  ,  @AER = 'SBFZ'
	  ,  @CIA = 'TAM'

SELECT @SQL = '
--EMBARQUE
SELECT  *
FROM   [' + @AER + ' - INTEGRACAO].[integracao].[dbo].INTEGRACAO_IEOP_SISO_RPE_EMB AER WITH (NOLOCK)
WHERE   CONVERT(VARCHAR(10), DH_PAR_NRM, 112) = ''' + @DTA + '''
AND     CONVERT(INT, NR_PAR_VOO) = ' + @VOO_PAR + '
AND        SG_COM_IAT_003 = ''' + @CIA + '''


 SELECT TOP 1000 *
  FROM [IEOP].[dbo].[RPE_EMBARQUE]
 WHERE NUM_GRUPO_VOO_EMB = 1
   AND	SIG_AEROPORTO = ''' + @AER + '''
   AND	CONVERT(VARCHAR(10), DTH_NORMAL_DECOLAGEM, 112) = ''' + @DTA + '''
   AND	SIG_CIA_AEREA_IATA = ''' + @CIA + '''
   AND	CONVERT(INT, NUM_VOO) = ' + @VOO_PAR + '


 SELECT TOP 1000 *
  FROM [IEOP].[dbo].[IEOP_EMBARQUE]
 WHERE NUM_GRUPO_VOO_EMB = 1
   AND	SIG_AEROPORTO = ''' + @AER + '''
   AND	CONVERT(VARCHAR(10), DTH_NORMAL_DECOLAGEM, 112) = ''' + @DTA + '''
   AND	SIG_CIA_AEREA_IATA = ''' + @CIA + '''
   AND	CONVERT(INT, NUM_VOO) = ' + @VOO_PAR + '


--DESEMBARQUE
SELECT  *
FROM   [' + @AER + ' - INTEGRACAO].[integracao].[dbo].INTEGRACAO_IEOP_SISO_RPE_DES AER WITH (NOLOCK)
WHERE   CONVERT(VARCHAR(10), DH_CHG_NRM, 112) = ''' + @DTA + '''
AND     CONVERT(INT, NR_CHG_VOO) = ' + @VOO_CHG + '
AND        SG_COM_IAT_003 = ''' + @CIA + '''

 SELECT TOP 1000 *
  FROM [IEOP].[dbo].[RPE_DESEMBARQUE]
 WHERE NUM_GRUPO_VOO_DESEMB = 1
   AND	SIG_AEROPORTO = ''' + @AER + '''
   AND	CONVERT(VARCHAR(10), DTH_NORMAL_POUSO, 112) = ''' + @DTA + '''
   AND	SIG_CIA_AEREA_IATA = ''' + @CIA + '''
   AND	CONVERT(INT, NUM_VOO) = ' + @VOO_CHG + '

 SELECT TOP 1000 *
  FROM [IEOP].[dbo].[IEOP_DESEMBARQUE]
 WHERE NUM_GRUPO_VOO_DESEMB = 1
   AND	SIG_AEROPORTO = ''' + @AER + '''
   AND	CONVERT(VARCHAR(10), DTH_NORMAL_POUSO, 112) = ''' + @DTA + '''
   AND	SIG_CIA_AEREA_IATA = ''' + @CIA + '''
   AND	CONVERT(INT, NUM_VOO) = ' + @VOO_CHG + '
'

--PRINT @SQL
EXECUTE (@SQL)

*/

--CORRIGINDO MAIS 1 ERRO DO RPE - QUANDO N�O EXISTIA COD_PARTIDA
/*

DECLARE	@SIG_AEROPORTO		VARCHAR(10)
	  ,	@DTA_BUSCA			VARCHAR(8)
      ,	@COD_AEROPORTO		VARCHAR(4)	
	  ,	@DTH_VOO			DATETIME
	  ,	@NUM_VOO			VARCHAR(4)
	  ,	@NOM_EMPRESA		VARCHAR(100)

SET		@SIG_AEROPORTO	=	'SBVT'
SET		@DTA_BUSCA		=	'20141130'

--BEGIN TRAN
--ROLLBACK TRAN
--COMMIT TRAN

DECLARE emb_cursor CURSOR FOR 
SELECT	DISTINCT
	    (SELECT DEP_CODIGO FROM IFRCORP..DEPENDENCIAS WHERE DEP_SIGLA = SIG_AEROPORTO ) AS COD_AEROPORTO
	,	DTH_NORMAL_DECOLAGEM AS DTH_VOO
	,	TMP.NUM_VOO
	,	SIG_CIA_AEREA_IATA AS NOM_EMPRESA
	,	SIG_AEROPORTO
FROM (SELECT TOP 1000 *
		FROM [IEOP].[dbo].[RPE_EMBARQUE] WITH (NOLOCK)
		WHERE COD_VOO_PARTIDA = 0
		AND NUM_VOO NOT IN (6127, 1635, 0)
		AND TIP_STATUS != 3
		AND DTH_NORMAL_DECOLAGEM > @DTA_BUSCA
		ORDER
		BY 1, 2, 3 DESC, COD_STATUS) AS TMP


OPEN emb_cursor

SET NOCOUNT ON

FETCH NEXT FROM emb_cursor
INTO    @COD_AEROPORTO
	 ,	@DTH_VOO
	 ,  @NUM_VOO
	 ,  @NOM_EMPRESA
	 ,  @SIG_AEROPORTO

WHILE @@FETCH_STATUS = 0
BEGIN

	--PRINT @COD_AEROPORTO + ' - ' + @NUM_VOO + ' - ' + @NOM_EMPRESA + ' - ' + CONVERT(VARCHAR(8), @DTH_VOO, 112)

	--UPDATE	[IFRRPEWEB].[dbo].[CAD_RPE_EMBARQUE]  SET	COD_AEROPORTO = RPE.COD_AEROPORTO
	SELECT	TOP 10 *
	  FROM (
			SELECT	MAX(SEQ_RPE_EMBARQUE) AS MAX_SEQ_RPE_EMBARQUE
			FROM	[IFRRPEWEB].[dbo].[CAD_RPE_EMBARQUE]  RPE WITH (NOLOCK)
			WHERE	CONVERT(VARCHAR(10), DTH_VOO, 112) = CONVERT(VARCHAR(8), @DTH_VOO, 112)
			  AND	COD_AEROPORTO = @COD_AEROPORTO
			  AND   NOM_EMPRESA =  @NOM_EMPRESA
			  AND   NUM_VOO = @NUM_VOO  ) AS TMP
		 ,  [IFRRPEWEB].[dbo].[CAD_RPE_EMBARQUE]  RPE WITH (NOLOCK)
	 WHERE	RPE.SEQ_RPE_EMBARQUE = TMP.MAX_SEQ_RPE_EMBARQUE

	FETCH NEXT FROM emb_cursor
	INTO    @COD_AEROPORTO
		 ,	@DTH_VOO
		 ,  @NUM_VOO
		 ,  @NOM_EMPRESA
		 ,  @SIG_AEROPORTO

END

CLOSE emb_cursor;
DEALLOCATE emb_cursor;  




*/

SELECT	*
  FROM	[IEOP].[dbo].[IEOP_EMBARQUE]
 WHERE	COD_STATUS = 827557
   AND	SIG_AEROPORTO = 'SBSV'

SELECT	*
  FROM	[IEOP].[dbo].[IEOP_DESEMBARQUE]
 WHERE	COD_STATUS = 827557
   AND	SIG_AEROPORTO = 'SBSV'

SELECT	*
  FROM	[IEOP].[dbo].[IEOP_MOVIMENTACAO]
 WHERE	COD_STATUS = 827557
   AND	SIG_AEROPORTO = 'SBSV'
   
SELECT	 @DTA = '20141222'
      ,  @VOO_PAR = 0
	  ,  @VOO_CHG = 2171
	  ,  @AER = 'SBSV'
	  ,  @CIA = 'GLO'


SELECT TOP 1000 *
FROM [IEOP].[dbo].[RPE_EMBARQUE] WITH (NOLOCK)
WHERE COD_VOO_PARTIDA = 0
AND NUM_VOO IN ( 0)
AND TIP_STATUS != 3
AND DTH_NORMAL_DECOLAGEM > '20141130'
ORDER
BY 1, 2, 3 DESC, COD_STATUS
