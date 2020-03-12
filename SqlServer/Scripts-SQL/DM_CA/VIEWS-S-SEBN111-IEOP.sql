USE [IEOP]
GO

/****** Object:  View [dbo].[VIW_DADOS_IEOP_INDICADORES_DA]    Script Date: 24/02/2015 13:01:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[VIW_DADOS_IEOP_INDICADORES_DA] AS 
SELECT	EMB.SIG_AEROPORTO
	 ,	EMB.MES_EMB AS MES
	 ,	EMB.ANO_EMB AS ANO
	 ,  SUM (SUM_PAX_DES + SUM_PAX_EMB) QTD_PAX
FROM  (
		SELECT	SIG_AEROPORTO
			 ,	MONTH(ISNULL([DTH_EFETIVA_POUSO], [DTH_NORMAL_POUSO])) MES_DES
			 ,	YEAR(ISNULL([DTH_EFETIVA_POUSO], [DTH_NORMAL_POUSO])) ANO_DES
			 ,	SUM([QTD_PAX_DESEMB_DOM] + [QTD_PAX_DESEMB_INT] + [QTD_CON_TRANSITO_DOM] + [QTD_CON_TRANSITO_INT]) SUM_PAX_DES
		  FROM	[IEOP].[dbo].[IEOP_DESEMBARQUE] WITH (NOLOCK)
		 WHERE  DTH_NORMAL_POUSO > '20130101'
		   AND [TIP_STATUS] <> 3
		 GROUP
			BY	SIG_AEROPORTO
			 ,	MONTH(ISNULL([DTH_EFETIVA_POUSO], [DTH_NORMAL_POUSO]))
			 ,	YEAR(ISNULL([DTH_EFETIVA_POUSO], [DTH_NORMAL_POUSO])) 
		) DES ,
		(
		SELECT	[SIG_AEROPORTO]
			 ,	MONTH(ISNULL([DTH_EFETIVA_DECOLAGEM], [DTH_NORMAL_DECOLAGEM])) MES_EMB
			 ,	YEAR(ISNULL([DTH_EFETIVA_DECOLAGEM], [DTH_NORMAL_DECOLAGEM])) ANO_EMB
			 ,	SUM([QTD_TARIFA_PAGA_BILHETE_DOM_EMB] + [QTD_TARIFA_PAGA_BILHETE_INT_EMB] + 
			        [QTD_TARIFA_PAGA_CHECKIN_DOM_EMB] + [QTD_TARIFA_PAGA_CHECKIN_INT_EMB] + 
					[QTD_ISENTA_CONEXAO_EMB_DOM] + [QTD_ISENTA_CONEXAO_EMB_INT] + 
					[QTD_TARIFA_PAG_BILHETE_EMB_DOM_ANT] + [QTD_TARIFA_PAG_BILHETE_EMB_INT_ANT] + 
					[QTD_TARIFA_PAG_CHECKIN_EMB_DOM_ANT] + [QTD_TARIFA_PAG_CHECKIN_EMB_INT_ANT]) SUM_PAX_EMB
			 ,	SUM([QTD_BAG_EMB_DOM] + [QTD_BAG_EMB_INT]) SUM_BAG_EMB
		  FROM	[IEOP].[dbo].[IEOP_EMBARQUE] WITH (NOLOCK)
		 WHERE	[DTH_NORMAL_DECOLAGEM] > '20130101'
		   AND [TIP_STATUS] <> 3
		 GROUP
			BY	[SIG_AEROPORTO]
			 ,	MONTH(ISNULL([DTH_EFETIVA_DECOLAGEM], [DTH_NORMAL_DECOLAGEM]))
			 ,	YEAR(ISNULL([DTH_EFETIVA_DECOLAGEM], [DTH_NORMAL_DECOLAGEM]))
		) AS EMB
 WHERE	EMB.SIG_AEROPORTO = DES.SIG_AEROPORTO
   AND	EMB.MES_EMB = DES.MES_DES
   AND	EMB.ANO_EMB = DES.ANO_DES
 GROUP
    BY	EMB.SIG_AEROPORTO
	 ,	EMB.MES_EMB
	 ,	EMB.ANO_EMB




GO

/****** Object:  View [dbo].[VIW_HORA_PICO_PAX_DESEMBARQUE]    Script Date: 24/02/2015 13:01:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[VIW_HORA_PICO_PAX_DESEMBARQUE] AS
SELECT	[SIGLA_AEROPORTO]
      ,	YEAR([DATA_HORA_EFETIVA_POUSO]) AS ANO
	  ,	MONTH([DATA_HORA_EFETIVA_POUSO]) AS MES
	  ,	DAY([DATA_HORA_EFETIVA_POUSO]) AS DIA
	  ,	DATEPART(HOUR, [DATA_HORA_EFETIVA_POUSO]) AS HORA
	  ,	SUM([DESEMB_PASSAGEIRO_DOM] + [DESEMB_PASSAGEIRO_INT] + [TRANSITO_CONEXAO_DOM] + [TRANSITO_CONEXAO_INT]) AS SUM_QTDE_PAX_DESEMB
	  , RANK() OVER (PARTITION BY [SIGLA_AEROPORTO], YEAR([DATA_HORA_EFETIVA_POUSO]), MONTH([DATA_HORA_EFETIVA_POUSO]),	DAY([DATA_HORA_EFETIVA_POUSO]) 
								ORDER BY SUM([DESEMB_PASSAGEIRO_DOM] + [DESEMB_PASSAGEIRO_INT] + [TRANSITO_CONEXAO_DOM] + [TRANSITO_CONEXAO_INT]) DESC) AS RANK_QTDE_PAX_DESEMB
  FROM	[BIOGER].[dbo].[VIW_BIOGER_DADOS_DES]
 WHERE	GRUPO_VOO = 1
   AND  YEAR([DATA_HORA_EFETIVA_POUSO]) =  YEAR(DATEADD(YEAR,-1,GETDATE()))
   --AND  [SIGLA_AEROPORTO] = 'SBSP'
   --AND  [DATA_HORA_EFETIVA_POUSO] >= CONVERT(VARCHAR(4), YEAR(DATEADD(MONTH,-11,GETDATE()))) + RIGHT('00'+ CONVERT(VARCHAR(2),MONTH(DATEADD(MONTH,-11,GETDATE()))),2) + '01'
 GROUP 
     BY	[SIGLA_AEROPORTO]
      ,	YEAR([DATA_HORA_EFETIVA_POUSO])
	  ,	MONTH([DATA_HORA_EFETIVA_POUSO])
	  ,	DAY([DATA_HORA_EFETIVA_POUSO])
	  ,	DATEPART(HOUR, [DATA_HORA_EFETIVA_POUSO])

GO

/****** Object:  View [dbo].[VIW_HORA_PICO_PAX_EMBARQUE]    Script Date: 24/02/2015 13:01:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[VIW_HORA_PICO_PAX_EMBARQUE] AS
SELECT	[SIGLA_AEROPORTO]
      , YEAR([DATA_HORA_EFETIVA_DECOLAGEM]) AS ANO
	  ,	MONTH([DATA_HORA_EFETIVA_DECOLAGEM]) AS MES
	  ,	DAY([DATA_HORA_EFETIVA_DECOLAGEM]) AS DIA
	  ,	DATEPART(HOUR, [DATA_HORA_EFETIVA_DECOLAGEM]) AS HORA
      ,	SUM([EMB_TARIFA_PAGA_BILHETE_DOM] + [EMB_TARIFA_PAGA_CHECKIN_DOM] + 
	        [EMB_TARIFA_PAGA_BILHETE_INT] + [EMB_TARIFA_PAGA_CHECKIN_INT] +
			[EMB_ISENTA_COLO] + [EMB_ISENTA_TRANSITO] + [EMB_ISENTA_CONEXAO_DOM] + 
			[EMB_ISENTA_CONEXAO_INT] + [EMB_ISENTA_OUTRAS]) AS SUM_QTD_PAX_EMBARQUE
      ,	RANK() OVER (PARTITION BY [SIGLA_AEROPORTO], YEAR([DATA_HORA_EFETIVA_DECOLAGEM]), MONTH([DATA_HORA_EFETIVA_DECOLAGEM]), DAY([DATA_HORA_EFETIVA_DECOLAGEM]) 
													ORDER BY SUM([EMB_TARIFA_PAGA_BILHETE_DOM] + [EMB_TARIFA_PAGA_CHECKIN_DOM] + 
																[EMB_TARIFA_PAGA_BILHETE_INT] + [EMB_TARIFA_PAGA_CHECKIN_INT] +
																[EMB_ISENTA_COLO] + [EMB_ISENTA_TRANSITO] + [EMB_ISENTA_CONEXAO_DOM] + 
																[EMB_ISENTA_CONEXAO_INT] + [EMB_ISENTA_OUTRAS]) DESC) AS RANK_QTDE_PAX_DESEMB
  FROM	[BIOGER].[dbo].[VIW_BIOGER_DADOS_EMB]
 WHERE	GRUPO_VOO = 1
   --AND  [SIGLA_AEROPORTO] = 'SBSP'
   --AND  [DATA_HORA_EFETIVA_DECOLAGEM] >= CONVERT(VARCHAR(4), YEAR(DATEADD(MONTH,-11,GETDATE()))) + RIGHT('00'+ CONVERT(VARCHAR(2),MONTH(DATEADD(MONTH,-11,GETDATE()))),2) + '01'
   AND  YEAR([DATA_HORA_EFETIVA_DECOLAGEM]) =  YEAR(DATEADD(YEAR,-1,GETDATE()))
 GROUP
    BY	[SIGLA_AEROPORTO]
      ,	YEAR([DATA_HORA_EFETIVA_DECOLAGEM])
	  ,	MONTH([DATA_HORA_EFETIVA_DECOLAGEM])
	  , DAY([DATA_HORA_EFETIVA_DECOLAGEM])
	  ,	DATEPART(HOUR, [DATA_HORA_EFETIVA_DECOLAGEM])

--GRANT SELECT ON VIW_HORA_PICO_PAX_EMBARQUE TO usr_bi_da

GO

/****** Object:  View [dbo].[VIW_IEOP_DESEMBARQUE_DA]    Script Date: 24/02/2015 13:01:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [dbo].[VIW_IEOP_DESEMBARQUE_DA] AS
SELECT [SIG_AEROPORTO] as "Sigla do Aeroporto"
      ,[NUM_VOO] as "Número do Voo"
      ,[DTH_NORMAL_POUSO] As "Data Programada do Pouso"
      ,[DTH_EFETIVA_POUSO] as "Data Real do Pouso"
	  ,YEAR([DTH_EFETIVA_POUSO]) as "Ano"
	  ,MONTH([DTH_EFETIVA_POUSO]) as "Mês"
	  ,DAY([DTH_EFETIVA_POUSO]) as "Dia"
	  ,DATEPART(HOUR, [DTH_EFETIVA_POUSO]) as "Hora"
	  ,DATEPART(MINUTE, [DTH_EFETIVA_POUSO]) as "Minuto"
      ,[SIG_CIA_AEREA_IATA] as "Sigla Iata da Cia Aérea"
      ,[NME_CIA_AEREA] as "Nome da Cia Aérea"
      ,[COD_MATRICULA_AERONAVE] as "Matricula da Aeronave"
      ,CASE 
	     WHEN [NUM_GRUPO_VOO_DESEMB] = 1 THEN 'Comercial' 
		 WHEN [NUM_GRUPO_VOO_DESEMB] = 2 THEN 'Aviação Geral' 
		 ELSE 'Outros'
	   END as "Grupo do Voo"
      ,CASE 
	     WHEN [NUM_NATUREZA_VOO_DESEMB] = 1 THEN 'Passageiros' 
		 WHEN [NUM_NATUREZA_VOO_DESEMB] = 2 THEN 'Carga' 
		 WHEN [NUM_NATUREZA_VOO_DESEMB] = 3 THEN 'Translado' 
		 WHEN [NUM_NATUREZA_VOO_DESEMB] = 4 THEN 'Misto' 
		 ELSE 'Outros'
	   END as "Natureza do Voo"
      ,CASE 
	     WHEN [NUM_CLASSE_VOO_DESEMB] = 1 THEN 'Domestico' 
		 WHEN [NUM_CLASSE_VOO_DESEMB] = 2 THEN 'Internacional' 
		 WHEN [NUM_CLASSE_VOO_DESEMB] = 3 THEN 'Regional' 
		 ELSE 'Outros'
	   END as "Classe do Voo"
      ,CASE 
	     WHEN [NUM_CATEGORIA_VOO_DESEMB] = 1 THEN 'Regular' 
		 WHEN [NUM_CATEGORIA_VOO_DESEMB] = 2 THEN 'Charter' 
		 WHEN [NUM_CATEGORIA_VOO_DESEMB] = 3 THEN 'Codeshare' 
		 WHEN [NUM_CATEGORIA_VOO_DESEMB] = 4 THEN 'Duplicate Leg' 
		 WHEN [NUM_CATEGORIA_VOO_DESEMB] = 5 THEN 'Pouso Técnico' 
		 WHEN [NUM_CATEGORIA_VOO_DESEMB] = 6 THEN 'Translado' 
		 WHEN [NUM_CATEGORIA_VOO_DESEMB] = 7 THEN 'Aviação Geral' 
		 WHEN [NUM_CATEGORIA_VOO_DESEMB] = 8 THEN 'Militar' 
		 WHEN [NUM_CATEGORIA_VOO_DESEMB] = 9 THEN 'Não Regular' 
		 WHEN [NUM_CATEGORIA_VOO_DESEMB] = 10 THEN 'Taxi Aéreo' 
		 WHEN [NUM_CATEGORIA_VOO_DESEMB] = 11 THEN 'Voo Alternado' 
		 WHEN [NUM_CATEGORIA_VOO_DESEMB] = 12 THEN 'Extra Com Hotran' 
		 WHEN [NUM_CATEGORIA_VOO_DESEMB] = 13 THEN 'Regular Postal' 
		 WHEN [NUM_CATEGORIA_VOO_DESEMB] = 14 THEN 'Extra Sem Hotran' 
		 WHEN [NUM_CATEGORIA_VOO_DESEMB] = 15 THEN 'Voo de Retorno' 
		 WHEN [NUM_CATEGORIA_VOO_DESEMB] = 16 THEN 'Fretamento' 
		 WHEN [NUM_CATEGORIA_VOO_DESEMB] = 17 THEN 'Voo de Instrução' 
		 WHEN [NUM_CATEGORIA_VOO_DESEMB] = 18 THEN 'Voo de Experiência' 
		 ELSE 'Outros'
	   END as "Categoria do Voo"
      ,CASE 
	     WHEN [NUM_CATEGORIA_VOO_DESEMB_VINCULADO] = 1 THEN 'Regular' 
		 WHEN [NUM_CATEGORIA_VOO_DESEMB_VINCULADO] = 2 THEN 'Charter' 
		 WHEN [NUM_CATEGORIA_VOO_DESEMB_VINCULADO] = 3 THEN 'Codeshare' 
		 WHEN [NUM_CATEGORIA_VOO_DESEMB_VINCULADO] = 4 THEN 'Duplicate Leg' 
		 WHEN [NUM_CATEGORIA_VOO_DESEMB_VINCULADO] = 5 THEN 'Pouso Técnico' 
		 WHEN [NUM_CATEGORIA_VOO_DESEMB_VINCULADO] = 6 THEN 'Translado' 
		 WHEN [NUM_CATEGORIA_VOO_DESEMB_VINCULADO] = 7 THEN 'Aviação Geral' 
		 WHEN [NUM_CATEGORIA_VOO_DESEMB_VINCULADO] = 8 THEN 'Militar' 
		 WHEN [NUM_CATEGORIA_VOO_DESEMB_VINCULADO] = 9 THEN 'Não Regular' 
		 WHEN [NUM_CATEGORIA_VOO_DESEMB_VINCULADO] = 10 THEN 'Taxi Aéreo' 
		 WHEN [NUM_CATEGORIA_VOO_DESEMB_VINCULADO] = 11 THEN 'Voo Alternado' 
		 WHEN [NUM_CATEGORIA_VOO_DESEMB_VINCULADO] = 12 THEN 'Extra Com Hotran' 
		 WHEN [NUM_CATEGORIA_VOO_DESEMB_VINCULADO] = 13 THEN 'Regular Postal' 
		 WHEN [NUM_CATEGORIA_VOO_DESEMB_VINCULADO] = 14 THEN 'Extra Sem Hotran' 
		 WHEN [NUM_CATEGORIA_VOO_DESEMB_VINCULADO] = 15 THEN 'Voo de Retorno' 
		 WHEN [NUM_CATEGORIA_VOO_DESEMB_VINCULADO] = 16 THEN 'Fretamento' 
		 WHEN [NUM_CATEGORIA_VOO_DESEMB_VINCULADO] = 17 THEN 'Voo de Instrução' 
		 WHEN [NUM_CATEGORIA_VOO_DESEMB_VINCULADO] = 18 THEN 'Voo de Experiência' 
		 ELSE 'Outros'
	   END as "Categoria do Voo Vinculado"
      ,[SIG_EQUIPAMENTO] as "Sigla do Equipamento"
      ,[NME_EQUIPAMENTO] as "Nome do Equipamento"
      ,[QTD_PAX_DESEMB_DOM] as "Qtde. de Pax Domésticos Desembarcados"
      ,[QTD_PAX_DESEMB_INT] as "Qtde. de Pax Internacionais Desembarcados"
      ,[QTD_BAG_DESEMB_DOM] as "Qtde. de Bagagem Doméstica Desembarcada"
      ,[QTD_BAG_DESEMB_INT] as "Qtde. de Bagagem Internacional Desembarcada"
      ,[QTD_CAR_DESEMB_DOM] as "Qtde. de Carga Doméstica Desembarcada"
      ,[QTD_CAR_DESEMB_INT] as "Qtde. de Carga Internacional Desembarcada"
      ,[QTD_COR_DESEMB_DOM] as "Qtde. de Correio Doméstico Desembarcado"
      ,[QTD_COR_DESEMB_INT] as "Qtde. de Correio Internacional Desembarcado"
      ,[QTD_BAG_TRANSITO_DOM] as "Qtde. de Bagagem Doméstica em Trânsito"
      ,[QTD_BAG_TRANSITO_INT] as "Qtde. de Bagagem Internacional em Trânsito"
      ,[QTD_CAR_TRANSITO_DOM] as "Qtde. de Carga Doméstica em Trânsito"
      ,[QTD_CAR_TRANSITO_INT] as "Qtde. de Carga Internacional em Trânsito"
      ,[QTD_COR_TRANSITO_DOM] as "Qtde. de Correio Doméstico em Trânsito"
      ,[QTD_COR_TRANSITO_INT] as "Qtde. de Correio Internacional em Trânsito"
      ,[QTD_CON_TRANSITO_DOM] as "Qtde. de Pax Doméstico em Conexão"
      ,[QTD_CON_TRANSITO_INT] as "Qtde. de Pax Internacional em Conexão"
      ,[COD_VOO_CHEGADA]
      ,[COD_DESEMB_VINCULADO]
      ,[SIG_AEROPORTO_PROCEDENCIA] as "Sigla do Aeroporto de Procedência"
      ,[NUM_BOX] as "Número do Box"
      ,CASE 
	     WHEN [TIP_BOX] = 0 THEN 'Outros' 
		 WHEN [TIP_BOX] = 1 THEN 'Pátio' 
		 WHEN [TIP_BOX] = 2 THEN 'Estadia' 
		 WHEN [TIP_BOX] = 3 THEN 'Controle' 
		 WHEN [TIP_BOX] = 9 THEN 'Outros' 
		 ELSE 'Outros'
	   END as "Tipo do Box"
      ,[NME_PONTE] as "Desc. Ponte de Desemb."
      ,[NUM_ESTEIRA] as "Desc. da Esteira"
      ,[DSC_PISTA_POUSO] as "Cabeçeira da Pista de Pouso"
      ,[DSC_PISTA_DECOLAGEM] as "Cabeçeira da Pista de Decolagem"
      ,[COD_STATUS]
      ,[FLG_ISENTO] as "Voo Isento"
      ,[FLG_AVISTA] as "Voo com Pgto a Vista"
      ,[FLG_TAXI_AEREO] as "Voo é Taxi Aéreo"
      ,[FLG_EQUIP_HELICOP] as "Voo feito com Helicoptero"
      ,[DTH_PRI_MOV] as "Data/Hora do Primeiro Movimento (Pouso)"
      ,[DTH_PRI_ENT_MOV] as "Data/Hora Primeira Entrada no Calço"
      ,[DTH_ULT_MOV] as "Data/Hora do Último Movimento (Decolagem)"
FROM (
		SELECT [SIG_AEROPORTO]
			  ,[NUM_VOO]
			  ,[DTH_NORMAL_POUSO]
			  ,CASE 
				  WHEN [DTH_EFETIVA_POUSO] IS NULL THEN [DTH_NORMAL_POUSO]
				  ELSE [DTH_EFETIVA_POUSO]
				END [DTH_EFETIVA_POUSO]
			  ,[COD_CIA_AEREA]
			  ,[SIG_CIA_AEREA_IATA]
			  ,[NME_CIA_AEREA]
			  ,[COD_MATRICULA_AERONAVE]
			  ,[NUM_GRUPO_VOO_DESEMB]
			  ,[NUM_NATUREZA_VOO_DESEMB]
			  ,[NUM_CLASSE_VOO_DESEMB]
			  ,[NUM_CATEGORIA_VOO_DESEMB]
			  ,[NUM_CATEGORIA_VOO_DESEMB_VINCULADO]
			  ,[SIG_EQUIPAMENTO]
			  ,[NME_EQUIPAMENTO]
			  ,[QTD_PAX_DESEMB_DOM]
			  ,[QTD_PAX_DESEMB_INT]
			  ,[QTD_BAG_DESEMB_DOM]
			  ,[QTD_BAG_DESEMB_INT]
			  ,[QTD_CAR_DESEMB_DOM]
			  ,[QTD_CAR_DESEMB_INT]
			  ,[QTD_COR_DESEMB_DOM]
			  ,[QTD_COR_DESEMB_INT]
			  ,[QTD_BAG_TRANSITO_DOM]
			  ,[QTD_BAG_TRANSITO_INT]
			  ,[QTD_CAR_TRANSITO_DOM]
			  ,[QTD_CAR_TRANSITO_INT]
			  ,[QTD_COR_TRANSITO_DOM]
			  ,[QTD_COR_TRANSITO_INT]
			  ,[QTD_CON_TRANSITO_DOM]
			  ,[QTD_CON_TRANSITO_INT]
			  ,[COD_VOO_CHEGADA]
			  ,[COD_DESEMB_VINCULADO]
			  ,[SIG_AEROPORTO_PROCEDENCIA]
			  ,[NUM_BOX]
			  ,[TIP_BOX]
			  ,[NME_PONTE]
			  ,[NUM_ESTEIRA]
			  ,[DSC_PISTA_POUSO]
			  ,[DSC_PISTA_DECOLAGEM]
			  ,[COD_STATUS]
			  ,[COD_STATUS_ANT]
			  ,[COD_STATUS_POS]
			  ,[TIP_STATUS]
			  ,[FLG_STATUS]
			  ,[FLG_ISENTO]
			  ,[FLG_AVISTA]
			  ,[FLG_TAXI_AEREO]
			  ,[FLG_EQUIP_HELICOP]
			  ,[DTH_PRI_MOV]
			  ,[DTH_PRI_ENT_MOV]
			  ,[DTH_ULT_MOV]
			  ,[DTH_ATUALIZACAO]
		  FROM [IEOP].[dbo].[IEOP_DESEMBARQUE] WITH (NOLOCK)
		  WHERE [DTH_NORMAL_POUSO] >= '20130101'
		    AND [TIP_STATUS] <> 3) DES 





GO

/****** Object:  View [dbo].[VIW_IEOP_EMBARQUE_DA]    Script Date: 24/02/2015 13:01:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [dbo].[VIW_IEOP_EMBARQUE_DA] AS
SELECT [SIG_AEROPORTO] as "Sigla do Aeroporto"
      ,[NUM_VOO] as "Número do Voo"
      ,[DTH_NORMAL_DECOLAGEM] As "Data Programada do Decolagem"
      ,[DTH_EFETIVA_DECOLAGEM] as "Data Real do Decolagem"
	  ,YEAR([DTH_EFETIVA_DECOLAGEM]) as "Ano"
	  ,MONTH([DTH_EFETIVA_DECOLAGEM]) as "Mês"
	  ,DAY([DTH_EFETIVA_DECOLAGEM]) as "Dia"
	  ,DATEPART(HOUR, [DTH_EFETIVA_DECOLAGEM]) as "Hora"
	  ,DATEPART(MINUTE, [DTH_EFETIVA_DECOLAGEM]) as "Minuto"
      ,[SIG_CIA_AEREA_IATA] as "Sigla Iata da Cia Aérea"
      ,[NME_CIA_AEREA] as "Nome da Cia Aérea"
      ,[COD_MATRICULA_AERONAVE] as "Matricula da Aeronave"
	  ,CASE 
	     WHEN [NUM_GRUPO_VOO_EMB] = 1 THEN 'Comercial' 
		 WHEN [NUM_GRUPO_VOO_EMB] = 2 THEN 'Aviação Geral' 
		 ELSE 'Outros'
	   END as "Grupo do Voo"
      ,CASE 
	     WHEN [NUM_NATUREZA_VOO_EMB] = 1 THEN 'Passageiros' 
		 WHEN [NUM_NATUREZA_VOO_EMB] = 2 THEN 'Carga' 
		 WHEN [NUM_NATUREZA_VOO_EMB] = 3 THEN 'Translado' 
		 WHEN [NUM_NATUREZA_VOO_EMB] = 4 THEN 'Misto' 
		 ELSE 'Outros'
	   END as "Natureza do Voo"
      ,CASE 
	     WHEN [NUM_CLASSE_VOO_EMB] = 1 THEN 'Domestico' 
		 WHEN [NUM_CLASSE_VOO_EMB] = 2 THEN 'Internacional' 
		 WHEN [NUM_CLASSE_VOO_EMB] = 3 THEN 'Regional' 
		 ELSE 'Outros'
	   END as "Classe do Voo"
      ,CASE 
	     WHEN [NUM_CATEGORIA_VOO_EMB] = 1 THEN 'Regular' 
		 WHEN [NUM_CATEGORIA_VOO_EMB] = 2 THEN 'Charter' 
		 WHEN [NUM_CATEGORIA_VOO_EMB] = 3 THEN 'Codeshare' 
		 WHEN [NUM_CATEGORIA_VOO_EMB] = 4 THEN 'Duplicate Leg' 
		 WHEN [NUM_CATEGORIA_VOO_EMB] = 5 THEN 'Pouso Técnico' 
		 WHEN [NUM_CATEGORIA_VOO_EMB] = 6 THEN 'Translado' 
		 WHEN [NUM_CATEGORIA_VOO_EMB] = 7 THEN 'Aviação Geral' 
		 WHEN [NUM_CATEGORIA_VOO_EMB] = 8 THEN 'Militar' 
		 WHEN [NUM_CATEGORIA_VOO_EMB] = 9 THEN 'Não Regular' 
		 WHEN [NUM_CATEGORIA_VOO_EMB] = 10 THEN 'Taxi Aéreo' 
		 WHEN [NUM_CATEGORIA_VOO_EMB] = 11 THEN 'Voo Alternado' 
		 WHEN [NUM_CATEGORIA_VOO_EMB] = 12 THEN 'Extra Com Hotran' 
		 WHEN [NUM_CATEGORIA_VOO_EMB] = 13 THEN 'Regular Postal' 
		 WHEN [NUM_CATEGORIA_VOO_EMB] = 14 THEN 'Extra Sem Hotran' 
		 WHEN [NUM_CATEGORIA_VOO_EMB] = 15 THEN 'Voo de Retorno' 
		 WHEN [NUM_CATEGORIA_VOO_EMB] = 16 THEN 'Fretamento' 
		 WHEN [NUM_CATEGORIA_VOO_EMB] = 17 THEN 'Voo de Instrução' 
		 WHEN [NUM_CATEGORIA_VOO_EMB] = 18 THEN 'Voo de Experiência' 
		 ELSE 'Outros'
	   END as "Categoria do Voo"
      ,CASE 
	     WHEN [NUM_CATEGORIA_VOO_EMB_VINCULADO] = 1 THEN 'Regular' 
		 WHEN [NUM_CATEGORIA_VOO_EMB_VINCULADO] = 2 THEN 'Charter' 
		 WHEN [NUM_CATEGORIA_VOO_EMB_VINCULADO] = 3 THEN 'Codeshare' 
		 WHEN [NUM_CATEGORIA_VOO_EMB_VINCULADO] = 4 THEN 'Duplicate Leg' 
		 WHEN [NUM_CATEGORIA_VOO_EMB_VINCULADO] = 5 THEN 'Pouso Técnico' 
		 WHEN [NUM_CATEGORIA_VOO_EMB_VINCULADO] = 6 THEN 'Translado' 
		 WHEN [NUM_CATEGORIA_VOO_EMB_VINCULADO] = 7 THEN 'Aviação Geral' 
		 WHEN [NUM_CATEGORIA_VOO_EMB_VINCULADO] = 8 THEN 'Militar' 
		 WHEN [NUM_CATEGORIA_VOO_EMB_VINCULADO] = 9 THEN 'Não Regular' 
		 WHEN [NUM_CATEGORIA_VOO_EMB_VINCULADO] = 10 THEN 'Taxi Aéreo' 
		 WHEN [NUM_CATEGORIA_VOO_EMB_VINCULADO] = 11 THEN 'Voo Alternado' 
		 WHEN [NUM_CATEGORIA_VOO_EMB_VINCULADO] = 12 THEN 'Extra Com Hotran' 
		 WHEN [NUM_CATEGORIA_VOO_EMB_VINCULADO] = 13 THEN 'Regular Postal' 
		 WHEN [NUM_CATEGORIA_VOO_EMB_VINCULADO] = 14 THEN 'Extra Sem Hotran' 
		 WHEN [NUM_CATEGORIA_VOO_EMB_VINCULADO] = 15 THEN 'Voo de Retorno' 
		 WHEN [NUM_CATEGORIA_VOO_EMB_VINCULADO] = 16 THEN 'Fretamento' 
		 WHEN [NUM_CATEGORIA_VOO_EMB_VINCULADO] = 17 THEN 'Voo de Instrução' 
		 WHEN [NUM_CATEGORIA_VOO_EMB_VINCULADO] = 18 THEN 'Voo de Experiência' 
		 ELSE 'Outros'
	   END as "Categoria do Voo Vinculado"
      ,[SIG_EQUIPAMENTO] as "Sigla do Equipamento"
      ,[NME_EQUIPAMENTO] as "Nome do Equipamento"
      ,([QTD_TARIFA_PAGA_BILHETE_DOM_EMB] + [QTD_TARIFA_PAGA_CHECKIN_DOM_EMB]) as "Qtde. de Pax Domésticos Embarcados"
      ,([QTD_TARIFA_PAGA_BILHETE_INT_EMB] + [QTD_TARIFA_PAGA_CHECKIN_INT_EMB]) as "Qtde. de Pax Internacionais Embarcados"
      ,[QTD_ISENTA_COLO_EMB] as "Qtde. de Pax Isento - Colo"
      ,[QTD_ISENTA_TRANSITO_EMB] as "Qtde. de Pax Embarcados em Trânsito"
      ,[QTD_ISENTA_CONEXAO_EMB_DOM] as "Qtde. de Pax Embarcados em Conexão - Doméstico"
      ,[QTD_ISENTA_CONEXAO_EMB_INT] as "Qtde. de Pax Embarcados em Conexão - Internacionais"
      ,[QTD_ISENTA_OUTRAS_EMB] as "Qtde. de Pax Isento - Outros"
      ,[QTD_BAG_EMB_DOM] as "Qtde. de Bagagem Doméstica Embarcada"
      ,[QTD_BAG_EMB_INT] as "Qtde. de Bagagem Internacional Embarcada"
      ,[QTD_CAR_EMB_DOM] as "Qtde. de Carga Doméstica Embarcada"
      ,[QTD_CAR_EMB_INT] as "Qtde. de Carga Internacional Embarcada"
      ,[QTD_COR_EMB_DOM] as "Qtde. de Correio Doméstica Embarcado"
      ,[QTD_COR_EMB_INT] as "Qtde. de Correio Internacional Embarcado"
      ,[COD_VOO_CHEGADA_ANT]
      ,[COD_EMB_VINCULADO]
      ,[SIG_AEROPORTO_DESTINO] as "Sigla do Aeroporto de Destino"
      ,[NUM_BOX] as "Número do Box"
      ,CASE 
	     WHEN [TIP_BOX] = 0 THEN 'Outros' 
		 WHEN [TIP_BOX] = 1 THEN 'Pátio' 
		 WHEN [TIP_BOX] = 2 THEN 'Estadia' 
		 WHEN [TIP_BOX] = 3 THEN 'Controle' 
		 WHEN [TIP_BOX] = 9 THEN 'Outros' 
		 ELSE 'Outros'
	   END as "Tipo do Box"
      ,[NME_PONTE] as "Desc. Ponte de Embarque"
      ,[NUM_PORTAO] as "Número do Portão de Embarque"
      ,[DSC_PISTA_POUSO] as "Cabeçeira da Pista de Pouso"
      ,[DSC_PISTA_DECOLAGEM] as "Cabeçeira da Pista de Decolagem"
      ,[COD_STATUS]
      ,[FLG_TAXI_AEREA] as "Voo é Taxi Aéreo"
      ,[FLG_EQUIP_HELICOP] as "Voo feito com Helicoptero"
      ,[DTH_PRI_MOV] as "Data/Hora do Primeiro Movimento (Pouso)"
      ,[DTH_ULT_MOV] as "Data/Hora do Último Movimento (Decolagem)"
      ,[DTH_ULT_SAI_MOV] as "Data/Hora Última Saída no Calço"

FROM (
		SELECT [SIG_AEROPORTO]
			  ,[NUM_VOO]
			  ,[DTH_NORMAL_DECOLAGEM]
			  ,CASE 
						  WHEN [DTH_EFETIVA_DECOLAGEM] IS NULL THEN [DTH_NORMAL_DECOLAGEM]
						  ELSE [DTH_EFETIVA_DECOLAGEM]
						END [DTH_EFETIVA_DECOLAGEM]
			  ,[COD_CIA_AEREA]
			  ,[SIG_CIA_AEREA_IATA]
			  ,[NME_CIA_AEREA]
			  ,[COD_MATRICULA_AERONAVE]
			  ,[NUM_GRUPO_VOO_EMB]
			  ,[NUM_NATUREZA_VOO_EMB]
			  ,[NUM_CLASSE_VOO_EMB]
			  ,[NUM_CATEGORIA_VOO_EMB]
			  ,[NUM_CATEGORIA_VOO_EMB_VINCULADO]
			  ,[SIG_EQUIPAMENTO]
			  ,[NME_EQUIPAMENTO]
			  ,[QTD_TARIFA_PAGA_BILHETE_DOM_EMB]
			  ,[QTD_TARIFA_PAGA_BILHETE_INT_EMB]
			  ,[QTD_TARIFA_PAGA_CHECKIN_DOM_EMB]
			  ,[QTD_TARIFA_PAGA_CHECKIN_INT_EMB]
			  ,[QTD_ISENTA_COLO_EMB]
			  ,[QTD_ISENTA_TRANSITO_EMB]
			  ,[QTD_ISENTA_CONEXAO_EMB_DOM]
			  ,[QTD_ISENTA_CONEXAO_EMB_INT]
			  ,[QTD_ISENTA_OUTRAS_EMB]
			  ,[QTD_BAG_EMB_DOM]
			  ,[QTD_BAG_EMB_INT]
			  ,[QTD_CAR_EMB_DOM]
			  ,[QTD_CAR_EMB_INT]
			  ,[QTD_COR_EMB_DOM]
			  ,[QTD_COR_EMB_INT]
			  ,[QTD_TARIFA_PAG_BILHETE_EMB_DOM_ANT]
			  ,[QTD_TARIFA_PAG_BILHETE_EMB_INT_ANT]
			  ,[QTD_TARIFA_PAG_CHECKIN_EMB_DOM_ANT]
			  ,[QTD_TARIFA_PAG_CHECKIN_EMB_INT_ANT]
			  ,[COD_VOO_CHEGADA_ANT]
			  ,[COD_EMB_VINCULADO]
			  ,[SIG_AEROPORTO_DESTINO]
			  ,[NUM_BOX]
			  ,[TIP_BOX]
			  ,[NME_PONTE]
			  ,[NUM_PORTAO]
			  ,[DSC_PISTA_POUSO]
			  ,[DSC_PISTA_DECOLAGEM]
			  ,[COD_STATUS]
			  ,[COD_STATUS_ANT]
			  ,[COD_STATUS_POS]
			  ,[TIP_STATUS]
			  ,[FLG_STATUS]
			  ,[FLG_TAXI_AEREA]
			  ,[FLG_EQUIP_HELICOP]
			  ,[DTH_PRI_MOV]
			  ,[DTH_ULT_MOV]
			  ,[DTH_ULT_SAI_MOV]
			  ,[DTH_ATUALIZACAO]
		  FROM [IEOP].[dbo].[IEOP_EMBARQUE] WITH (NOLOCK) 
		  WHERE [DTH_NORMAL_DECOLAGEM] >= '20130101'
		    AND [TIP_STATUS] <> 3) EMB







GO

/****** Object:  View [usr_ieop_bam].[VIW_DADOS_IEOP_INDICADORES_DA]    Script Date: 24/02/2015 13:01:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [usr_ieop_bam].[VIW_DADOS_IEOP_INDICADORES_DA] AS 
SELECT	EMB.SIG_AEROPORTO
	 ,	EMB.MES_EMB AS MES
	 ,	EMB.ANO_EMB AS ANO
	 ,  SUM (SUM_PAX_DES + SUM_PAX_EMB) QTD_PAX
FROM  (
		SELECT	SIG_AEROPORTO
			 ,	MONTH(ISNULL([DTH_EFETIVA_POUSO], [DTH_NORMAL_POUSO])) MES_DES
			 ,	YEAR(ISNULL([DTH_EFETIVA_POUSO], [DTH_NORMAL_POUSO])) ANO_DES
			 ,	SUM([QTD_PAX_DESEMB_DOM] + [QTD_PAX_DESEMB_INT] + [QTD_CON_TRANSITO_DOM] + [QTD_CON_TRANSITO_INT]) SUM_PAX_DES
		  FROM	[IEOP].[dbo].[IEOP_DESEMBARQUE] WITH (NOLOCK)
		 WHERE  DTH_NORMAL_POUSO > '20130101'
		   AND [TIP_STATUS] <> 3
		 GROUP
			BY	SIG_AEROPORTO
			 ,	MONTH(ISNULL([DTH_EFETIVA_POUSO], [DTH_NORMAL_POUSO]))
			 ,	YEAR(ISNULL([DTH_EFETIVA_POUSO], [DTH_NORMAL_POUSO])) 
		) DES ,
		(
		SELECT	[SIG_AEROPORTO]
			 ,	MONTH(ISNULL([DTH_EFETIVA_DECOLAGEM], [DTH_NORMAL_DECOLAGEM])) MES_EMB
			 ,	YEAR(ISNULL([DTH_EFETIVA_DECOLAGEM], [DTH_NORMAL_DECOLAGEM])) ANO_EMB
			 ,	SUM([QTD_TARIFA_PAGA_BILHETE_DOM_EMB] + [QTD_TARIFA_PAGA_BILHETE_INT_EMB] + 
			        [QTD_TARIFA_PAGA_CHECKIN_DOM_EMB] + [QTD_TARIFA_PAGA_CHECKIN_INT_EMB] + 
					[QTD_ISENTA_CONEXAO_EMB_DOM] + [QTD_ISENTA_CONEXAO_EMB_INT] + 
					[QTD_TARIFA_PAG_BILHETE_EMB_DOM_ANT] + [QTD_TARIFA_PAG_BILHETE_EMB_INT_ANT] + 
					[QTD_TARIFA_PAG_CHECKIN_EMB_DOM_ANT] + [QTD_TARIFA_PAG_CHECKIN_EMB_INT_ANT]) SUM_PAX_EMB
			 ,	SUM([QTD_BAG_EMB_DOM] + [QTD_BAG_EMB_INT]) SUM_BAG_EMB
		  FROM	[IEOP].[dbo].[IEOP_EMBARQUE] WITH (NOLOCK)
		 WHERE	[DTH_NORMAL_DECOLAGEM] > '20130101'
		   AND [TIP_STATUS] <> 3
		 GROUP
			BY	[SIG_AEROPORTO]
			 ,	MONTH(ISNULL([DTH_EFETIVA_DECOLAGEM], [DTH_NORMAL_DECOLAGEM]))
			 ,	YEAR(ISNULL([DTH_EFETIVA_DECOLAGEM], [DTH_NORMAL_DECOLAGEM]))
		) AS EMB
 WHERE	EMB.SIG_AEROPORTO = DES.SIG_AEROPORTO
   AND	EMB.MES_EMB = DES.MES_DES
   AND	EMB.ANO_EMB = DES.ANO_DES
 GROUP
    BY	EMB.SIG_AEROPORTO
	 ,	EMB.MES_EMB
	 ,	EMB.ANO_EMB





GO
