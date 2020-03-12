CREATE TABLE CONCURSO_DOC_ORIGEM_VAGAS (
    COV_NUMERO_DOCUMENTO	NUMBER(2)
,   COV_DATA_DOCUMENTO		DATE
,   COV_DATA_PUBLICACAO		DATE
)
/

COMMENT ON table CONCURSO_DOC_ORIGEM_VAGAS IS 'TABELA PARA ARMAZENAR OS DOCUMENTO QUE ORIGINAM AS VAGAS PARA O QUADRO DE EMPREGADOS DA INFRAERO E SUAS RESPECTIVAS DATAS.'
/

COMMENT ON COLUMN CONCURSO_DOC_ORIGEM_VAGAS.COV_NUMERO_DOCUMENTO IS 'N�MERO DO DOCUMENTO DE ORIGEM DA VAGA.'
/

COMMENT ON COLUMN CONCURSO_DOC_ORIGEM_VAGAS.COV_DATA_DOCUMENTO IS 'DATA DE CRIA��O DO DOCUMENTO DE ORIGEM DA VAGA.'
/

COMMENT ON COLUMN CONCURSO_DOC_ORIGEM_VAGAS.COV_DATA_PUBLICACAO IS 'DATA DA PUBLICA��O DO DOCUMENTO DE ORIGEM DA VAGA.'
/


ALTER TABLE CONCURSO_DOC_ORIGEM_VAGAS
ADD CONSTRAINT COV_PK PRIMARY KEY (COV_NUMERO_DOCUMENTO, COV_DATA_DOCUMENTO)
USING INDEX
TABLESPACE TS_INDICE
/ 

grant SELECT,DELETE,INSERT, UPDATE ON CONCURSO_DOC_ORIGEM_VAGAS TO RH_PERFIL_99, SRH_CAD_99,  SRH_CAD_01, SRH_CAD_14;

CREATE PUBLIC SYNONYM CONCURSO_DOC_ORIGEM_VAGAS FOR IFRSRH.CONCURSO_DOC_ORIGEM_VAGAS
/

INSERT INTO TABELAS VALUES ('SRHSFP', 'CONCURSO_DOC_ORIGEM_VAGAS', 'IFRSRH', 'TABELA')
/