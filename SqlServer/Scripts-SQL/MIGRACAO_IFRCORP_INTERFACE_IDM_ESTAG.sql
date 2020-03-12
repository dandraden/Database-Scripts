--------------------------------------------DROP TABLE ----------------------------------------------------------------------
DROP TABLE "IFRCORP"."TAB_INTERFACE_IDM_ESTAG" PURGE;

--------------------------------------------CREATE TABLE ----------------------------------------------------------------------
CREATE TABLE "IFRCORP"."TAB_INTERFACE_IDM_ESTAG"
  (
    "NUM_CPF" VARCHAR2(11 BYTE) NOT NULL ENABLE,
    "DAT_NASCIMENTO" DATE,
    "NUM_CARTEIRA_IDENTIDADE" VARCHAR2(15 BYTE),
    "NOM_ORGAO_EXPEDICAO_CI"  VARCHAR2(20 BYTE),
    "NUM_TELEFONE"            VARCHAR2(12 BYTE),
    "NME_CADASTRO"            VARCHAR2(80 BYTE) NOT NULL ENABLE,
    "DSC_ENDERECO_ELETRONICO" VARCHAR2(100 BYTE),
    "COD_DEP_FISICA"         NUMBER(4) NOT NULL ENABLE,
    "SIG_DEP_FISICA"         VARCHAR2(10 BYTE) NOT NULL ENABLE,
    "NME_DEP_FISICA"          VARCHAR2(200 BYTE) NOT NULL ENABLE,
    "COD_UOR_FISICA"          NUMBER(10) NOT NULL ENABLE,
    "SIG_UOR_FISICA"          VARCHAR2(10 BYTE) NOT NULL ENABLE,
    "NME_UOR_FISICA"          VARCHAR2(200 BYTE) NOT NULL ENABLE,
    "DSC_SITUACAO_FUNCIONAL"  VARCHAR2(20 BYTE) NOT NULL ENABLE,
    "DAT_ADMISSAO" DATE NOT NULL ENABLE,
    "NME_EMPRESA" VARCHAR2(200 BYTE) NOT NULL ENABLE,
    CONSTRAINT "PK_CPF" PRIMARY KEY ("NUM_CPF") USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645 PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT) TABLESPACE "TSD_GERAL" ENABLE
  )
  SEGMENT CREATION IMMEDIATE PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING STORAGE
  (
    INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645 PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT
  )
  TABLESPACE "TSD_GERAL" ;
  
GRANT SELECT, UPDATE, DELETE, INSERT ON IFRCORP.TAB_INTERFACE_IDM_ESTAG TO ROL_IDM_ADMIN;

---------------------------------- MIGRAR DADOS PARA TABELA IFRCORP.TAB_INTERFACE_IDM_ESTAG ----------------------------------
insert into IFRCORP.TAB_INTERFACE_IDM_ESTAG
select distinct lpad(A.NUM_CPF,11,'0') NUM_CPF, A.DAT_NASCIMENTO, A.NUM_IDENTIDADE, A.DSC_ORGAO_EMISSOR, A.NUM_TELEFONE,
       A.NOM_ESTAGIARIO, NULL EMAIL --A.END_EMAIL
       , , E.DEP_CODIGO, E.DEP_SIGLA, E.DEP_NOME, D.UOR_CODIGO, D.UOR_SIGLA, D.UOR_NOME,
       CASE FLG_DESLIGADO WHEN 'S' THEN 'INATIVO' ELSE 'ATIVO' END FLG_DESLIGADO, B.DAT_INICIO, 'CIEE' --B.COD_CIEE
from CAD_ESTAGIARIO_PESSOAL A
inner join CAD_ESTAGIARIO B
        on (B.SEQ_ESTAGIARIO_PESSOAL = A.SEQ_ESTAGIARIO_PESSOAL)
inner join CAD_ESTAGIARIO_LOCALIZACAO C
        on (C.SEQ_ESTAGIARIO = B.SEQ_ESTAGIARIO)
inner join UNIDADES_ORGANIZACIONAIS D
        on (C.UOR_CODIGO = D.UOR_CODIGO)
inner join DEPENDENCIAS E
        on (D.UOR_DEP_CODIGO = E.DEP_CODIGO)
       and (E.DEP_CODIGO = B.DEP_CODIGO)
where A.NUM_CPF is not null
  and A.DAT_NASCIMENTO is not null
  and B.FLG_DESLIGADO != 'S'
  and d.uor_data_extincao is null
  and e.dep_data_extincao is null
  and (c.dat_termino is null or c.dat_termino >= sysdate)
  and A.NUM_CPF not in ('4974720902', '907394426');
  
OU

insert into IFRCORP.TAB_INTERFACE_IDM_ESTAG
select * from (
select distinct lpad(A.NUM_CPF,11,'0') NUM_CPF, A.DAT_NASCIMENTO, A.NUM_IDENTIDADE, A.DSC_ORGAO_EMISSOR, A.NUM_TELEFONE,
       A.NOM_ESTAGIARIO, NULL EMAIL --A.END_EMAIL
       , E.DEP_CODIGO, E.DEP_SIGLA, E.DEP_NOME, D.UOR_CODIGO, D.UOR_SIGLA, D.UOR_NOME,
       CASE FLG_DESLIGADO WHEN 'S' THEN 'INATIVO' ELSE 'ATIVO' END FLG_DESLIGADO, B.DAT_INICIO, 'CIEE' --B.COD_CIEE, c.dat_termino
from CAD_ESTAGIARIO_PESSOAL A
inner join CAD_ESTAGIARIO B
        on (B.SEQ_ESTAGIARIO_PESSOAL = A.SEQ_ESTAGIARIO_PESSOAL)
inner join CAD_ESTAGIARIO_LOCALIZACAO C
        on (C.SEQ_ESTAGIARIO = B.SEQ_ESTAGIARIO)
inner join UNIDADES_ORGANIZACIONAIS D
        on (C.UOR_CODIGO = D.UOR_CODIGO)
inner join DEPENDENCIAS E
        on (D.UOR_DEP_CODIGO = E.DEP_CODIGO)
       and (E.DEP_CODIGO = B.DEP_CODIGO)
where A.NUM_CPF is not null
  and A.DAT_NASCIMENTO is not null
  and B.FLG_DESLIGADO != 'S'
  and d.uor_data_extincao is null
  and e.dep_data_extincao is null
  and (c.dat_termino is null or c.dat_termino >= sysdate)
  and A.NUM_CPF not in ('4974720902', '907394426')
) where num_cpf not in (select to_number(num_cpf) from IFRCORP.TAB_INTERFACE_IDM_ESTAG);
  
----------------------------------------------------------------------------------------------------------------------------------

---------------------------------- PERMISSÃO DE INSERT E UPDATE PARA O SCHEMA IFRSRH_ESTAGIARIO ----------------------------------
grant update, select, insert on IFRCORP.TAB_INTERFACE_IDM_ESTAG to IFRSRH_ESTAGIARIO; 
----------------------------------------------------------------------------------------------------------------------------------

---------------------------------- TRIGGER PARA INSERIR E ATUALIZAR DADOS NA TABELA IFRCORP.TAB_INTERFACE_IDM_ESTAG ----------------------------------
CREATE OR REPLACE TRIGGER IFRSRH_ESTAGIARIO.TRG_CAD_EST_LOC_IAE_A AFTER
  INSERT OR
  UPDATE OR
  DELETE ON IFRSRH_ESTAGIARIO.CAD_ESTAGIARIO_LOCALIZACAO FOR EACH ROW 
DECLARE
  CPF VARCHAR2(11);
  DATA_NASCIMENTO DATE;
  RG              VARCHAR2(15);
  ORGAO_EXPEDIDOR VARCHAR2(20);
  TELEFONE        VARCHAR2(12);
  CADASTRO        VARCHAR2(80);
  EMAIL           VARCHAR2(100);
  CODIGO_DEP			NUMBER(4);
  SIGLA_DEP       VARCHAR2(10);
  NOME_DEP        VARCHAR2(200);
  CODIGO_UOR			NUMBER(10);
  SIGLA_UOR       VARCHAR2(10);
  NOME_UOR        VARCHAR2(200);
  SEQ_EST_PES     NUMBER(10);
  CIEE            VARCHAR2(15);
  DESLIGADO       VARCHAR2(20);
  BEGIN
    IF INSERTING THEN
      ---------------------------------- Recuperar dados tabela CAD_ESTAGIARIO ----------------------------------
      SELECT SEQ_ESTAGIARIO_PESSOAL,
        COD_CIEE,
        CASE FLG_DESLIGADO
          WHEN 'S'
          THEN 'INATIVO'
          ELSE 'ATIVO'
        END FLG_DESLIGADO
      INTO SEQ_EST_PES,
        CIEE,
        DESLIGADO
      FROM IFRSRH_ESTAGIARIO.CAD_ESTAGIARIO
      WHERE SEQ_ESTAGIARIO = :NEW.SEQ_ESTAGIARIO;
      ---------------------------------- Recuperar dados tabela CAD_ESTAGIARIO_PESSOAL ----------------------------------
      SELECT A.NUM_CPF,
        A.DAT_NASCIMENTO,
        A.NUM_IDENTIDADE,
        A.DSC_ORGAO_EMISSOR,
        A.NUM_TELEFONE,
        A.NOM_ESTAGIARIO,
        A.END_EMAIL
      INTO CPF,
        DATA_NASCIMENTO,
        RG,
        ORGAO_EXPEDIDOR,
        TELEFONE,
        CADASTRO,
        EMAIL
      FROM CAD_ESTAGIARIO_PESSOAL A
      WHERE A.SEQ_ESTAGIARIO_PESSOAL = SEQ_EST_PES;
      ---------------------------------- Recuperar dados tabelas DEPENDENCIAS E UNIDADES_ORGANIZACIONAIS ----------------------------------
      SELECT B.DEP_CODIGO,
        B.DEP_SIGLA,
        B.DEP_NOME,
        A.UOR_NOME,
        A.UOR_SIGLA,
        A.UOR_CODIGO
      INTO CODIGO_DEP,
        SIGLA_DEP,
        NOME_DEP,
        NOME_UOR,
        SIGLA_UOR,
        CODIGO_UOR
      FROM UNIDADES_ORGANIZACIONAIS A
      INNER JOIN DEPENDENCIAS B
      ON (A.UOR_DEP_CODIGO = B.DEP_CODIGO)
      WHERE UOR_CODIGO     = :NEW.UOR_CODIGO;
      ---------------------------------- Inserir as informações na tabela de TAB_INTERFACE_IDM_ESTAG ----------------------------------
      INSERT
      INTO IFRCORP.TAB_INTERFACE_IDM_ESTAG
        (
          NUM_CPF,
          DAT_NASCIMENTO,
          NUM_CARTEIRA_IDENTIDADE,
          NOM_ORGAO_EXPEDICAO_CI,
          NUM_TELEFONE,
          NME_CADASTRO,
          DSC_ENDERECO_ELETRONICO,
          COD_DEP_FISICA,
          SIG_DEP_FISICA,
          NME_DEP_FISICA,
          COD_UOR_FISICA,
          SIG_UOR_FISICA,
          NME_UOR_FISICA,
          DSC_SITUACAO_FUNCIONAL,
          DAT_ADMISSAO,
          NME_EMPRESA
        )
        VALUES
        (
          CPF,
          DATA_NASCIMENTO,
          RG,
          ORGAO_EXPEDIDOR,
          TELEFONE,
          CADASTRO,
          NULL,
          CODIGO_DEP,
          SIGLA_DEP,
          NOME_DEP,
          CODIGO_UOR,
          SIGLA_UOR,
          NOME_UOR,
          DESLIGADO,
          :NEW.DAT_INICIO,
          CIEE
        );
    ELSIF UPDATING THEN
      IF :NEW.UOR_CODIGO != :OLD.UOR_CODIGO THEN
        ---------------------------------- Recuperar dados tabela CAD_ESTAGIARIO ----------------------------------
        SELECT SEQ_ESTAGIARIO_PESSOAL,
          CASE FLG_DESLIGADO
            WHEN 'S'
            THEN 'INATIVO'
            ELSE 'ATIVO'
          END FLG_DESLIGADO
        INTO SEQ_EST_PES,
          DESLIGADO
        FROM IFRSRH_ESTAGIARIO.CAD_ESTAGIARIO
        WHERE SEQ_ESTAGIARIO = :NEW.SEQ_ESTAGIARIO;
        ---------------------------------- Recuperar dados tabelas DEPENDENCIAS E UNIDADES_ORGANIZACIONAIS ----------------------------------
        SELECT B.DEP_CODIGO,
	        B.DEP_SIGLA,
	        B.DEP_NOME,
	        A.UOR_NOME,
	        A.UOR_SIGLA,
	        A.UOR_CODIGO
	      INTO CODIGO_DEP,
	        SIGLA_DEP,
	        NOME_DEP,
	        NOME_UOR,
	        SIGLA_UOR,
	        CODIGO_UOR
        FROM UNIDADES_ORGANIZACIONAIS A
        INNER JOIN DEPENDENCIAS B
        ON (A.UOR_DEP_CODIGO = B.DEP_CODIGO)
        WHERE UOR_CODIGO     = :NEW.UOR_CODIGO;
        ---------------------------------- Atualizar as informações na tabela de TAB_INTERFACE_IDM_ESTAG ----------------------------------
        UPDATE IFRCORP.TAB_INTERFACE_IDM_ESTAG
        SET COD_DEP_FISICA       = CODIGO_DEP,
          SIG_DEP_FISICA         = SIGLA_DEP,
          NME_DEP_FISICA         = NOME_DEP,
          COD_UOR_FISICA         = CODIGO_UOR,
          SIG_UOR_FISICA         = SIGLA_UOR,
          NME_UOR_FISICA         = NOME_UOR,
          DSC_SITUACAO_FUNCIONAL = DESLIGADO
        WHERE NUM_CPF            =
          (SELECT NUM_CPF
          FROM CAD_ESTAGIARIO_PESSOAL
          WHERE SEQ_ESTAGIARIO_PESSOAL = SEQ_EST_PES
          );
      END IF;
    END IF;
  END;
  /
--------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------- TRIGGER PARA ATUALIZAR DADOS NA TABELA IFRCORP.TAB_INTERFACE_IDM_ESTAG ------------------------  
CREATE OR REPLACE TRIGGER IFRSRH_ESTAGIARIO.TRG_CAD_ESTAGIARIO_A_A AFTER
UPDATE ON IFRSRH_ESTAGIARIO.CAD_ESTAGIARIO
FOR EACH ROW 
DECLARE
CPF VARCHAR2(11);
DESLIGADO VARCHAR2(20);
BEGIN
IF :NEW.FLG_DESLIGADO != :OLD.FLG_DESLIGADO THEN
 SELECT DISTINCT NUM_CPF
   INTO CPF
   FROM CAD_ESTAGIARIO_PESSOAL 
  WHERE SEQ_ESTAGIARIO_PESSOAL = :NEW.SEQ_ESTAGIARIO_PESSOAL;
  
  IF :NEW.FLG_DESLIGADO = 'S' THEN DESLIGADO := 'INATIVO'; ELSE DESLIGADO := 'ATIVO'; END IF;
  
  UPDATE IFRCORP.TAB_INTERFACE_IDM_ESTAG
     SET DSC_SITUACAO_FUNCIONAL = DESLIGADO
   WHERE NUM_CPF = CPF;
  
END IF;
END;
/  
--------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------- DADOS UTILIZADOS EM TESTE -------------------------------------------
Insert into IFRSRH_ESTAGIARIO.CAD_ESTAGIARIO_PESSOAL 
(NOM_ESTAGIARIO,TIP_SEXO,END_EMAIL,DAT_NASCIMENTO,COD_NATURALIDADE,SIG_UF_NATURALIDADE,COD_INDICADOR_ESTADO_CIVIL,NOM_PAI,NOM_MAE,TIP_SANGUINEO,END_ENDERECO,END_CIDADE,END_UF,END_CEP,NUM_DDD_TELEFONE,NUM_TELEFONE,NUM_DDD_CELULAR,NUM_CELULAR,NUM_IDENTIDADE,DSC_ORGAO_EMISSOR,DAT_ID_EMISSAO,NUM_CPF,NUM_TITULO_ELEITOR,NUM_TE_ZONA,NUM_TE_SECAO,NUM_CARTEIRA_TRABALHO,NUM_CT_SERIE,DAT_CT_EMISSAO,NUM_CERTIFICADO_RESERVISTA,DSC_CR_SERIE,DSC_CR_CATEGORIA,DAT_INCLUSAO,DSC_USUARIO,TIP_FORMULARIO,SEQ_ESTAGIARIO_PESSOAL,COD_COR_RACA) 
values ('DEISE ROSA DO NASCIMENTO','F','DEISEROSAA@HOTMAIL.COM',to_timestamp('03/06/86','DD/MM/RR HH24:MI:SSXFF'),22400,'RS',1,'IRINEU MARCEDO NASCIMENTO','DENISE ROSA DO NASCIMENTO',null,'SQSW 302 BL G APTO 307',108,'DF',70673207,61,33449104,61,81360706,'34921732-4','SSP/SP',to_timestamp('17/05/96','DD/MM/RR HH24:MI:SSXFF'),4974720901,'00306645191','011','0153','6259220','001-0',to_timestamp('15/05/04','DD/MM/RR HH24:MI:SSXFF'),null,null,null,to_timestamp('11/10/07','DD/MM/RR HH24:MI:SSXFF'),'E726867231','CADASTRO - DADOS PESSOAIS',99999,null);

Insert into IFRSRH_ESTAGIARIO.CAD_ESTAGIARIO 
(SEQ_ESTAGIARIO,DEP_CODIGO,COD_CIEE,COD_CONTRATO_TCE,DAT_CONTRATO_TCE,SEQ_ESTAB_ENSINO,SEQ_NIVEL_ESTAGIARIO,SEQ_FORMACAO_ESTAGIARIO,SEQ_MOTIVO_DESLIGAMENTO,DAT_INICIO,DAT_TERMINO_PREVISTO,DAT_SAIDA,FLG_DESLIGADO,TXT_OBSERVACAO,DAT_PREV_RENOVACAO_1,DAT_PREV_RENOVACAO_2,DAT_PREV_RENOVACAO_3,DAT_PREV_RENOVACAO_4,DAT_RENOVACAO_1,DAT_RENOVACAO_2,DAT_RENOVACAO_3,DAT_RENOVACAO_4,DAT_INCLUSAO,DSC_USUARIO,TIP_FORMULARIO,SEQ_PARAMETRO,SEQ_ESTAGIARIO_PESSOAL,TIP_PROJETO) 
values (99999,1,'3227251','0000661624',to_timestamp('22/08/05','DD/MM/RR HH24:MI:SSXFF'),123,2,35,null,to_timestamp('22/08/05','DD/MM/RR HH24:MI:SSXFF'),to_timestamp('30/06/06','DD/MM/RR HH24:MI:SSXFF'),to_timestamp('30/06/06','DD/MM/RR HH24:MI:SSXFF'),'S',null,to_timestamp('21/02/06','DD/MM/RR HH24:MI:SSXFF'),null,null,null,null,null,null,null,to_timestamp('10/10/05','DD/MM/RR HH24:MI:SSXFF'),'MIGRACAO','CADASTRO',61,99999,null);

Insert into IFRSRH_ESTAGIARIO.CAD_ESTAGIARIO_LOCALIZACAO
(SEQ_ESTAGIARIO,DAT_INICIO,DAT_TERMINO,UOR_CODIGO,NUM_RAMAL,EMP_NUMERO_MATRICULA,END_DDD_TELEFONE,END_TELEFONE,CD_CENTRO_CUSTO,DAT_INCLUSAO,DSC_USUARIO,TIP_FORMULARIO,COD_DEPENDENCIA_CENTRO_CUSTO) 
values (99999,to_timestamp('01/09/05','DD/MM/RR HH24:MI:SSXFF'),to_timestamp('03/01/06','DD/MM/RR HH24:MI:SSXFF'),6856,6204,9093393,null,null,20117,to_timestamp('16/11/05','DD/MM/RR HH24:MI:SSXFF'),'I9892552','CADASTRO - DADOS FUNCIONAIS',4);

Update CAD_ESTAGIARIO_LOCALIZACAO
   set UOR_CODIGO = 1
where SEQ_ESTAGIARIO = 99999;
---------------------------------------------------------------------------------------------------------------------------------
select * from IFRSRH_ESTAGIARIO.CAD_ESTAGIARIO where seq_estagiario = '99999';

select * from IFRSRH_ESTAGIARIO.CAD_ESTAGIARIO_PESSOAL where SEQ_ESTAGIARIO_PESSOAL = '99999';

select * from IFRSRH_ESTAGIARIO.CAD_ESTAGIARIO_LOCALIZACAO where seq_estagiario = '99999';

SELECT * FROM IFRCORP.TAB_INTERFACE_IDM_ESTAG; 
---------------------------------------------------------------------------------------------------------------------------------
delete from IFRSRH_ESTAGIARIO.CAD_ESTAGIARIO_PESSOAL where SEQ_ESTAGIARIO_PESSOAL = '99999';

delete from IFRSRH_ESTAGIARIO.CAD_ESTAGIARIO_LOCALIZACAO where seq_estagiario = '99999';

delete from IFRSRH_ESTAGIARIO.CAD_ESTAGIARIO where SEQ_ESTAGIARIO = '99999';

DELETE FROM IFRCORP.TAB_INTERFACE_IDM_ESTAG;
---------------------------------------------------------------------------------------------------------------------------------

select *
from (
select distinct A.NUM_CPF, ifrcorp.FUN_VALIDA_CPF(num_cpf) as teste_cpf, A.DAT_NASCIMENTO, A.NUM_IDENTIDADE, A.DSC_ORGAO_EMISSOR, A.NUM_TELEFONE,
       A.NOM_ESTAGIARIO, A.END_EMAIL, E.DEP_CODIGO, E.DEP_SIGLA, E.DEP_NOME, E.DEP_DATA_EXTINCAO,
       D.UOR_CODIGO, D.UOR_SIGLA, D.UOR_NOME, D.UOR_DATA_EXTINCAO,
       CASE FLG_DESLIGADO WHEN 'S' THEN 'INATIVO' ELSE 'ATIVO' END FLG_DESLIGADO, B.DAT_INICIO, B.COD_CIEE, c.dat_termino
from CAD_ESTAGIARIO_PESSOAL A
inner join CAD_ESTAGIARIO B
        on (B.SEQ_ESTAGIARIO_PESSOAL = A.SEQ_ESTAGIARIO_PESSOAL)
inner join CAD_ESTAGIARIO_LOCALIZACAO C
        on (C.SEQ_ESTAGIARIO = B.SEQ_ESTAGIARIO)
inner join UNIDADES_ORGANIZACIONAIS D
        on (C.UOR_CODIGO = D.UOR_CODIGO)
inner join DEPENDENCIAS E
        on (D.UOR_DEP_CODIGO = E.DEP_CODIGO)
       and (E.DEP_CODIGO = B.DEP_CODIGO)
where B.FLG_DESLIGADO != 'S')
WHERE NUM_CPF NOT IN (SELECT NUM_CPF from IFRCORP.TAB_INTERFACE_IDM_ESTAG);


select * from (
SELECT num_cpf, ifrcorp.FUN_VALIDA_CPF(num_cpf) as teste_cpf
from IFRCORP.TAB_INTERFACE_IDM_ESTAG)
where teste_cpf != 1;
