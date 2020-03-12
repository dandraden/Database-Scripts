--ATUAL
SELECT 
  O.VSP_CD_NIVEL_VERSAO,
  O.VSP_CD_VERSAO,
  O.VSP_NR_ANO,
  O.NR_ITEM,
  O.DS_ITEM,
  I.NUM_CONTA_SOLICITANTE,
  I.COD_CENTRO_CUSTO_SOLICITANTE,
  --I.COD_DEPENDENCIA_AGRUPADORA,
  I.COD_DEPENDENCIA_ELABORACAO,
  (SELECT DEP_SIGLA FROM DEPENDENCIAS WHERE DEP_CODIGO = I.COD_DEPENDENCIA_ELABORACAO) SIGLA_DEPENDENCIA_ELABORACAO,
  --I.COD_DEPENDENCIA_SOLICITANTE,
  EE.COD_EVO COD_PROGRAMA,
  EE.DSC_EVO DSC_PROGRAMA,
  E.COD_EVO COD_ACAO,
  E.DSC_EVO DSC_ACAO,
  NVL(VAL_JANEIRO, 0) VL_JAN,
  NVL(VAL_FEVEREIRO, 0) VL_FEV,
  NVL(VAL_MARCO, 0) VL_MAR,
  NVL(VAL_ABRIL, 0) VL_ABR,
  NVL(VAL_MAIO, 0) VL_MAI,
  NVL(VAL_JUNHO, 0) VL_JUN,
  NVL(VAL_JULHO, 0) VL_JUL,
  NVL(VAL_AGOSTO, 0) VL_AGO,
  NVL(VAL_SETEMBRO, 0) VL_SET,
  NVL(VAL_OUTUBRO, 0) VL_OUT,
  NVL(VAL_NOVEMBRO, 0) VL_NOV,
  NVL(VAL_DEZEMBRO, 0) VL_DEZ
FROM IFRSICOF.PROGRAMACAO_SOLIC_PROPOSTA P
   , IFRSICOF.ITEM_SOLICITANTE_PROPOSTA I
   , IFRSICOF.ITEM_PROPOSTA_ORC_SIMULADA O
   , IFRSICOF.ESTRUTURA_VISAO_ORCAMENTO E
   , IFRSICOF.ESTRUTURA_VISAO_ORCAMENTO EE
WHERE P.NUM_ANO = 2011
  AND P.SEQ_ITEM_SOLICITANTE_PROPOSTA = I.SEQ_ITEM_SOLICITANTE_PROPOSTA
  AND I.VSP_NR_ANO = 2011
  AND I.SEQ_CHAVE_GESTORA = O.SEQ_CHAVE_GESTORA
  AND O.VSP_NR_ANO = 2011
  AND O.VSP_CD_NIVEL_VERSAO = 3
  AND O.VSP_CD_VERSAO = 15 
  AND E.SEQ_EVO = O.SEQ_ESTRUT_VISAO_ORCAMENTO
  AND EE.SEQ_EVO = E.SEQ_EVO_VIN
  AND EE.SEQ_EVO_VIN IS NULL
ORDER
   BY I.COD_DEPENDENCIA_ELABORACAO,
      EE.COD_EVO,
      E.COD_EVO;
  

--REFORMULAÇÃO
SELECT 
  O.VSP_CD_NIVEL_VERSAO,
  O.VSP_CD_VERSAO,
  O.VSP_NR_ANO,
  O.NR_ITEM,
  O.DS_ITEM,
  I.NUM_CONTA_SOLICITANTE,
  I.COD_CENTRO_CUSTO_SOLICITANTE,
  --I.COD_DEPENDENCIA_AGRUPADORA,
  I.COD_DEPENDENCIA_ELABORACAO,
  (SELECT DEP_SIGLA FROM DEPENDENCIAS WHERE DEP_CODIGO = I.COD_DEPENDENCIA_ELABORACAO) SIGLA_DEPENDENCIA_ELABORACAO,
  --I.COD_DEPENDENCIA_SOLICITANTE,
  EE.COD_EVO COD_PROGRAMA,
  EE.DSC_EVO DSC_PROGRAMA,
  E.COD_EVO COD_ACAO,
  E.DSC_EVO DSC_ACAO,
  NVL(VAL_JANEIRO, 0) VL_JAN,
  NVL(VAL_FEVEREIRO, 0) VL_FEV,
  NVL(VAL_MARCO, 0) VL_MAR,
  NVL(VAL_ABRIL, 0) VL_ABR,
  NVL(VAL_MAIO, 0) VL_MAI,
  NVL(VAL_JUNHO, 0) VL_JUN,
  NVL(VAL_JULHO, 0) VL_JUL,
  NVL(VAL_AGOSTO, 0) VL_AGO,
  NVL(VAL_SETEMBRO, 0) VL_SET,
  NVL(VAL_OUTUBRO, 0) VL_OUT,
  NVL(VAL_NOVEMBRO, 0) VL_NOV,
  NVL(VAL_DEZEMBRO, 0) VL_DEZ
FROM IFRSICOF.INV_PROGRAMACAO_SOLIC_PROPOSTA P
   , IFRSICOF.INV_ITEM_SOLICITANTE_PROPOSTA I
   , IFRSICOF.INV_ITEM_PROPOSTA_ORC_SIMULADA O
   , IFRSICOF.ESTRUTURA_VISAO_ORCAMENTO E
   , IFRSICOF.ESTRUTURA_VISAO_ORCAMENTO EE
WHERE P.NUM_ANO = 2011
  AND P.SEQ_ITEM_SOLICITANTE_PROPOSTA = I.SEQ_ITEM_SOLICITANTE_PROPOSTA
  AND I.VSP_NR_ANO = 2011
  AND I.SEQ_CHAVE_GESTORA = O.SEQ_CHAVE_GESTORA
  AND O.VSP_NR_ANO = 2011
  AND O.VSP_CD_NIVEL_VERSAO = 3
  AND O.VSP_CD_VERSAO = 15 
  AND E.SEQ_EVO = O.SEQ_ESTRUT_VISAO_ORCAMENTO
  AND EE.SEQ_EVO = E.SEQ_EVO_VIN
  AND EE.SEQ_EVO_VIN IS NULL
ORDER
   BY I.COD_DEPENDENCIA_ELABORACAO,
      EE.COD_EVO,
      E.COD_EVO;