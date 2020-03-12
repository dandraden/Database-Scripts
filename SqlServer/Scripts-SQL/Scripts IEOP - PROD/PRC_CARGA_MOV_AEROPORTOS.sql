USE [IEOP]
GO

/****** Object:  StoredProcedure [dbo].[PRC_CARGA_MOV_AEROPORTOS]    Script Date: 27/08/2013 09:11:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[PRC_CARGA_MOV_AEROPORTOS](@SIG_AEROPORTO varchar(4))
AS
declare @QUERY VARCHAR(2000);
BEGIN
	set @QUERY='';
	--TRUNCATE TABLE IEOP.dbo.IEOP_MOVIMENTACAO_TEMP
	set @QUERY='UPDATE ['+@SIG_AEROPORTO+' - INTEGRACAO].[integracao].[dbo].[INTEGRACAO_SISO_BIOGER_MOV_NEW] 
	   SET FL_STATUS= 1
	 WHERE FL_STATUS IS NULL';
	exec(@QUERY);
	 
	set @QUERY='INSERT INTO IEOP.dbo.IEOP_MOVIMENTACAO_TEMP
	SELECT  
			 LTRIM(RTRIM(sigla_aeroporto)) sigla_aeroporto
			,CD_STA
			,CD_MOV
			,LTRIM(RTRIM(TIPO_MOV)) TIPO_MOV
			,HR_MOV
			,LTRIM(RTRIM(NR_BOX)) NR_BOX
			,TIPO_BOX
			,LTRIM(RTRIM(NR_TPS)) NR_TPS
			,DTH_ATUALIZACAO
			,0 QTD_ATUALIZACAO
			,1 FLG_MIGRADO
			,GETDATE() DTH_MIGRACAO			
		FROM ['+@SIG_AEROPORTO+' - INTEGRACAO].[integracao].[dbo].[INTEGRACAO_SISO_BIOGER_MOV_NEW] WITH (NOLOCK)
	   WHERE FL_STATUS = 1'
	exec(@QUERY);

	set @QUERY='UPDATE ['+@SIG_AEROPORTO+' - INTEGRACAO].[integracao].[dbo].[INTEGRACAO_SISO_BIOGER_MOV_NEW] 
	   SET FL_STATUS = 2
	 WHERE FL_STATUS = 1';
	exec(@QUERY);
END;
GO


