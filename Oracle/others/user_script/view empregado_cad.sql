CREATE OR REPLACE VIEW empregados_cad (
   emp_numero_cpf,
   emp_numero_matricula,
   emp_numero_matricula_ant,
   emp_numero_matricula_tasa,
   emp_numero_matricula_arsa,
   emp_numero_fre,
   emp_nome,
   emp_nome_abreviado,
   emp_indicador_sexo,
   emp_data_nascimento,
   emp_indicador_estado_civil,
   emp_nacionalidade,
   emp_endereco_logradouro,
   emp_endereco_numero_cep,
   emp_ramal_residencia,
   emp_endereco_bairro,
   emp_endereco_fone,
   emp_numero_celular,
   emp_ddd_residencia,
   emp_ddd_celular,
   emp_jtr_codigo,
   emp_aba_ban_codigo_cta_pgto,
   emp_aba_codigo_conta_pgto,
   emp_nu_conta_corrente_pagto,
   emp_eso_codigo,
   emp_sfu_codigo,
   emp_htd_dep_codigo,
   emp_htd_htr_codigo,
   emp_htd_sequencial,
   emp_data_chegada_brasil,
   emp_nu_registro_estrangeiro,
   emp_in_classe_registro_estrang,
   emp_data_registro_estrangeiro,
   emp_cidade_nasc_estrangeiro,
   emp_cidade_natural_estrang,
   emp_ufe_sigla_estrangeiro,
   emp_decreto_naturalizacao,
   emp_data_validade_rne,
   emp_numero_ctps_rne,
   emp_nu_serie_ctps_rne,
   emp_data_expedicao_ctps_rne,
   emp_data_validade_ctps_rne,
   emp_mun_codigo_natural,
   emp_ufe_sigla_natural,
   emp_mun_codigo_reside,
   emp_ufe_sigla_residente,
   emp_data_naturalizacao,
   emp_numero_pis_pasep,
   emp_data_pis_pasep,
   emp_nu_carteira_identidade,
   emp_sigla_orgao_emitente_ci,
   emp_data_expedicao_ci,
   emp_ufe_sigla_ci,
   emp_nu_titulo_eleitor,
   emp_nu_zona_titulo_eleitor,
   emp_nu_secao_titulo_eleitor,
   emp_ufe_sigla_tit_eleitor,
   emp_nu_certificado_reservista,
   emp_nu_categoria_cr,
   emp_nu_regiao_militar_cr,
   emp_tipo_cr,
   emp_ano_emissao_cr,
   emp_nu_livro_certidao_casam,
   emp_nu_folha_certidao_casam,
   emp_data_casamento,
   emp_numero_carteira_trabalho,
   emp_numero_serie_carteira_trab,
   emp_dt_expedicao_carteira_trab,
   emp_ufe_sigla_ctps,
   emp_data_opcao_fgts,
   emp_codigo_fgts,
   emp_numero_conta_fgts,
   emp_aba_ban_codigo_fgts,
   emp_aba_codigo_fgts,
   emp_nu_carteira_habilitacao,
   emp_in_categoria_habilitacao,
   emp_dt_validade_carteira_hab,
   emp_nu_habilitacao_lancha,
   emp_indicador_categoria_hab,
   emp_dt_validade_habilit_lancha,
   emp_nu_carteira_orgao_classe,
   emp_ufe_sigla_reg_profis,
   emp_pai_codigo,
   emp_oex_codigo_cedido,
   emp_oex_codigo_requisitado,
   emp_qlp_hcl_uor_codigo,
   emp_qlp_hcl_data_vigencia,
   emp_qlp_car_codigo,
   emp_qlp_car_codigo_nivel,
   emp_qlp_car_occ_codigo,
   emp_nsa_codigo_nivel,
   emp_nsa_codigo_padrao,
   emp_nsa_in_nivel_escolaridade,
   emp_qfu_fun_codigo,
   emp_qfu_hfl_uor_codigo,
   emp_qfu_hfl_data_vigencia,
   emp_tipo_remuneracao_funcao,
   emp_qfu_fun_codigo_acumula,
   emp_qfu_hfl_uor_cod_acum,
   emp_qfu_hfl_data_vigen_acum,
   emp_tipo_remuner_funcao_acumul,
   emp_qfu_fun_codigo_substitui,
   emp_qfu_hfl_uor_cod_subst,
   emp_qfu_hfl_data_vigen_subst,
   emp_tipo_remuner_funcao_subst,
   emp_ocl_sigla,
   emp_emp_nu_matricula_casado,
   emp_dep_codigo_lotacao,
   emp_dep_codigo_pagto,
   emp_dep_codigo_fisico,
   emp_uor_codigo_lotacao,
   emp_uor_codigo_fisico,
   emp_indicador_primeiro_emprego,
   emp_ano_primeiro_emprego,
   emp_ufe_sigla_primeiro_emprego,
   emp_status,
   emp_codigo_rais,
   emp_tipo_conta,
   emp_classe_hab_tecnologica,
   emp_numero_hab_tecnologica,
   emp_data_hab_tecnologica,
   emp_habilit_orgao_oper,
   emp_data_capacitacao_fisica,
   emp_indicador_depv,
   emp_numero_depv,
   emp_licenca_depv,
   emp_situacao_militar,
   emp_posto_graduacao_codigo,
   emp_quadro_arma_esp_codigo,
   emp_forca_armada_codigo,
   emp_data_admissao,
   emp_ati_ct_custos,
   emp_nome_pai,
   emp_nome_mae,
   emp_id_aposentadoria,
   emp_dt_aposentadoria,
   emp_dt_reserva_militar,
   emp_plano_arsaprev,
   emp_data_filiacao_arsaprev,
   emp_data_cancelamento_arsaprev,
   emp_contrib_sindical_anual,
   emp_contrib_federativa,
   emp_adianta_13,
   emp_cor_raca,
   emp_nome_guerra,
   emp_endereco_eletronico_mail )
AS
select "EMP_NUMERO_CPF",
"EMP_NUMERO_MATRICULA","EMP_NUMERO_MATRICULA_ANT",
"EMP_NUMERO_MATRICULA_TASA","EMP_NUMERO_MATRICULA_ARSA",
"EMP_NUMERO_FRE","EMP_NOME","EMP_NOME_ABREVIADO","EMP_INDICADOR_SEXO",
"EMP_DATA_NASCIMENTO","EMP_INDICADOR_ESTADO_CIVIL","EMP_NACIONALIDADE",
"EMP_ENDERECO_LOGRADOURO","EMP_ENDERECO_NUMERO_CEP",
"EMP_RAMAL_RESIDENCIA","EMP_ENDERECO_BAIRRO",
"EMP_ENDERECO_FONE","EMP_NUMERO_CELULAR","EMP_DDD_RESIDENCIA",
"EMP_DDD_CELULAR","EMP_JTR_CODIGO","EMP_ABA_BAN_CODIGO_CTA_PGTO",
"EMP_ABA_CODIGO_CONTA_PGTO","EMP_NU_CONTA_CORRENTE_PAGTO",
"EMP_ESO_CODIGO","EMP_SFU_CODIGO","EMP_HTD_DEP_CODIGO",
"EMP_HTD_HTR_CODIGO","EMP_HTD_SEQUENCIAL","EMP_DATA_CHEGADA_BRASIL",
"EMP_NU_REGISTRO_ESTRANGEIRO","EMP_IN_CLASSE_REGISTRO_ESTRANG",
"EMP_DATA_REGISTRO_ESTRANGEIRO","EMP_CIDADE_NASC_ESTRANGEIRO",
"EMP_CIDADE_NATURAL_ESTRANG","EMP_UFE_SIGLA_ESTRANGEIRO",
"EMP_DECRETO_NATURALIZACAO","EMP_DATA_VALIDADE_RNE",
"EMP_NUMERO_CTPS_RNE",
"EMP_NU_SERIE_CTPS_RNE","EMP_DATA_EXPEDICAO_CTPS_RNE",
"EMP_DATA_VALIDADE_CTPS_RNE","EMP_MUN_CODIGO_NATURAL",
"EMP_UFE_SIGLA_NATURAL","EMP_MUN_CODIGO_RESIDE",
"EMP_UFE_SIGLA_RESIDENTE","EMP_DATA_NATURALIZACAO",
"EMP_NUMERO_PIS_PASEP","EMP_DATA_PIS_PASEP","EMP_NU_CARTEIRA_IDENTIDADE",
"EMP_SIGLA_ORGAO_EMITENTE_CI","EMP_DATA_EXPEDICAO_CI","EMP_UFE_SIGLA_CI",
"EMP_NU_TITULO_ELEITOR","EMP_NU_ZONA_TITULO_ELEITOR","EMP_NU_SECAO_TITULO_ELEITOR",
"EMP_UFE_SIGLA_TIT_ELEITOR","EMP_NU_CERTIFICADO_RESERVISTA","EMP_NU_CATEGORIA_CR",
"EMP_NU_REGIAO_MILITAR_CR","EMP_TIPO_CR","EMP_ANO_EMISSAO_CR",
"EMP_NU_LIVRO_CERTIDAO_CASAM","EMP_NU_FOLHA_CERTIDAO_CASAM",
"EMP_DATA_CASAMENTO","EMP_NUMERO_CARTEIRA_TRABALHO",
"EMP_NUMERO_SERIE_CARTEIRA_TRAB","EMP_DT_EXPEDICAO_CARTEIRA_TRAB",
"EMP_UFE_SIGLA_CTPS","EMP_DATA_OPCAO_FGTS","EMP_CODIGO_FGTS","EMP_NUMERO_CONTA_FGTS",
"EMP_ABA_BAN_CODIGO_FGTS","EMP_ABA_CODIGO_FGTS","EMP_NU_CARTEIRA_HABILITACAO",
"EMP_IN_CATEGORIA_HABILITACAO","EMP_DT_VALIDADE_CARTEIRA_HAB","EMP_NU_HABILITACAO_LANCHA",
"EMP_INDICADOR_CATEGORIA_HAB","EMP_DT_VALIDADE_HABILIT_LANCHA","EMP_NU_CARTEIRA_ORGAO_CLASSE",
"EMP_UFE_SIGLA_REG_PROFIS","EMP_PAI_CODIGO","EMP_OEX_CODIGO_CEDIDO",
"EMP_OEX_CODIGO_REQUISITADO",
"EMP_QLP_HCL_UOR_CODIGO","EMP_QLP_HCL_DATA_VIGENCIA","EMP_QLP_CAR_CODIGO",
"EMP_QLP_CAR_CODIGO_NIVEL","EMP_QLP_CAR_OCC_CODIGO","EMP_NSA_CODIGO_NIVEL",
"EMP_NSA_CODIGO_PADRAO","EMP_NSA_IN_NIVEL_ESCOLARIDADE","EMP_QFU_FUN_CODIGO",
"EMP_QFU_HFL_UOR_CODIGO","EMP_QFU_HFL_DATA_VIGENCIA","EMP_TIPO_REMUNERACAO_FUNCAO",
"EMP_QFU_FUN_CODIGO_ACUMULA","EMP_QFU_HFL_UOR_COD_ACUM","EMP_QFU_HFL_DATA_VIGEN_ACUM",
"EMP_TIPO_REMUNER_FUNCAO_ACUMUL","EMP_QFU_FUN_CODIGO_SUBSTITUI","EMP_QFU_HFL_UOR_COD_SUBST",
"EMP_QFU_HFL_DATA_VIGEN_SUBST","EMP_TIPO_REMUNER_FUNCAO_SUBST","EMP_OCL_SIGLA",
"EMP_EMP_NU_MATRICULA_CASADO","EMP_DEP_CODIGO_LOTACAO","EMP_DEP_CODIGO_PAGTO",
"EMP_DEP_CODIGO_FISICO","EMP_UOR_CODIGO_LOTACAO","EMP_UOR_CODIGO_FISICO","EMP_INDICADOR_PRIMEIRO_EMPREGO",
"EMP_ANO_PRIMEIRO_EMPREGO","EMP_UFE_SIGLA_PRIMEIRO_EMPREGO","EMP_STATUS","EMP_CODIGO_RAIS",
"EMP_TIPO_CONTA","EMP_CLASSE_HAB_TECNOLOGICA","EMP_NUMERO_HAB_TECNOLOGICA",
"EMP_DATA_HAB_TECNOLOGICA","EMP_HABILIT_ORGAO_OPER","EMP_DATA_CAPACITACAO_FISICA",
"EMP_INDICADOR_DEPV",
"EMP_NUMERO_DEPV","EMP_LICENCA_DEPV","EMP_SITUACAO_MILITAR","EMP_POSTO_GRADUACAO_CODIGO",
"EMP_QUADRO_ARMA_ESP_CODIGO","EMP_FORCA_ARMADA_CODIGO","EMP_DATA_ADMISSAO",
"EMP_ATI_CT_CUSTOS","EMP_NOME_PAI","EMP_NOME_MAE","EMP_ID_APOSENTADORIA",
"EMP_DT_APOSENTADORIA","EMP_DT_RESERVA_MILITAR","EMP_PLANO_ARSAPREV",
"EMP_DATA_FILIACAO_ARSAPREV","EMP_DATA_CANCELAMENTO_ARSAPREV",
"EMP_CONTRIB_SINDICAL_ANUAL","EMP_CONTRIB_FEDERATIVA","EMP_ADIANTA_13","EMP_COR_RACA",
"EMP_NOME_GUERRA","EMP_ENDERECO_ELETRONICO_MAIL"
from cadastros cad
  where cad.emp_dep_codigo_fisico in
        (select cud.dep_cd_dependencia
           from CONTROLE_USUARIO_DEPENDENCIA cud
          where cud.ssi_cd_sistema = 5
            and cud.sgu_id_usuario = (select user from dual))
/
