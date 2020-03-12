USE [IEOP]
GO

/****** Object:  StoredProcedure [dbo].[PRC_MERGE_MOV_NOVO_BIOGER]    Script Date: 27/08/2013 09:13:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[PRC_MERGE_MOV_NOVO_BIOGER]
AS
SET NOCOUNT ON;

declare	@SIG_AEROPORTO char(4)
	,@COD_STATUS int
	,@COD_MOVIMENTO int
	,@TIP_MOVIMENTO char(2)
	,@DTH_MOVIMENTO smalldatetime
	,@NUM_BOX varchar(50)
	,@TIP_BOX tinyint
	,@NUM_TPS char(1)
	,@DTH_ATUALIZACAO datetime
	,@QTD_ATUALIZACAO smallint
	,@FLG_MIGRADO tinyint
	,@DTH_MIGRACAO datetime

UPDATE [IEOP].[dbo].[IEOP_MOVIMENTACAO_TEMP] 
SET FLG_MIGRADO = 2
WHERE FLG_MIGRADO = 1;

DECLARE mov_cursor CURSOR FOR 
	SELECT	ISNULL(LTRIM(RTRIM(SIG_AEROPORTO)),0) SIG_AEROPORTO
			,[COD_STATUS]
			,[COD_MOVIMENTO]
			,[TIP_MOVIMENTO]
			,[DTH_MOVIMENTO]
			,[NUM_BOX]
			,[TIP_BOX]
			,[NUM_TPS]
			,[DTH_ATUALIZACAO]
			,[QTD_ATUALIZACAO]
			,[FLG_MIGRADO]
			,[DTH_MIGRACAO]
	FROM	[IEOP].[dbo].[IEOP_MOVIMENTACAO_TEMP] 
   WHERE	FLG_MIGRADO = 2 
   ORDER 
      BY	 SIG_AEROPORTO ASC
			,COD_STATUS  ASC
			,[COD_MOVIMENTO] ASC
			,[DTH_MIGRACAO] ASC;

OPEN mov_cursor
FETCH NEXT FROM mov_cursor
INTO @SIG_AEROPORTO
	,@COD_STATUS
	,@COD_MOVIMENTO
	,@TIP_MOVIMENTO
	,@DTH_MOVIMENTO
	,@NUM_BOX
	,@TIP_BOX
	,@NUM_TPS
	,@DTH_ATUALIZACAO
	,@QTD_ATUALIZACAO
	,@FLG_MIGRADO
	,@DTH_MIGRACAO

WHILE @@FETCH_STATUS = 0
BEGIN
	DELETE	IEOP.DBO.IEOP_MOVIMENTACAO
	 WHERE	SIG_AEROPORTO = @SIG_AEROPORTO
	   AND	COD_STATUS = @COD_STATUS
	   AND  COD_MOVIMENTO = @COD_MOVIMENTO;
				
	INSERT 
	  INTO	IEOP.dbo.IEOP_MOVIMENTACAO 
	VALUES	(@SIG_AEROPORTO
			,@COD_STATUS
			,@COD_MOVIMENTO
			,@TIP_MOVIMENTO
			,@DTH_MOVIMENTO
			,@NUM_BOX
			,@TIP_BOX
			,@NUM_TPS
			,@DTH_ATUALIZACAO
			,@QTD_ATUALIZACAO
			,@FLG_MIGRADO
			,@DTH_MIGRACAO );

	FETCH NEXT FROM mov_cursor
	INTO @SIG_AEROPORTO
		,@COD_STATUS
		,@COD_MOVIMENTO
		,@TIP_MOVIMENTO
		,@DTH_MOVIMENTO
		,@NUM_BOX
		,@TIP_BOX
		,@NUM_TPS
		,@DTH_ATUALIZACAO
		,@QTD_ATUALIZACAO
		,@FLG_MIGRADO
		,@DTH_MIGRACAO
END

UPDATE [IEOP].[dbo].[IEOP_MOVIMENTACAO_TEMP] 
SET FLG_MIGRADO = 3
WHERE FLG_MIGRADO = 2;

CLOSE mov_cursor;
DEALLOCATE mov_cursor;
GO


