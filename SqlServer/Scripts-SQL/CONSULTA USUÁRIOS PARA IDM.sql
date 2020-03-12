
SELECT
    EMP_NUMERO_MATRICULA  AS MATRICULA
,    'I' || LPAD(TO_CHAR(EMP_NUMERO_MATRICULA),7,0) AS MATRICULA_REDE
,   LPAD(TO_CHAR(EMP_NUMERO_CPF),11,0) AS CPF
,   EMP_NOME            AS NOME
,   'I' AS I_T
FROM IFRAGENDA.VIW_CADASTROS
UNION ALL
SELECT
    TER_NUMERO_MATRICULA AS MATRICULA
,   'T' || SUBSTR(LPAD(TO_CHAR(TER_CPF),11,0),1,9) AS MATRICULA_REDE
,   LPAD(TO_CHAR(TER_CPF),11,0) AS CPF
,   TER_NOME            AS NOME
,   'T' AS I_T
FROM IFRAGENDA.VIW_TERCEIROS
UNION ALL
SELECT
    SEQ_ESTAGIARIO AS MATRICULA
,   'T' || SUBSTR(LPAD(TO_CHAR(NUM_CPF),11,0),1,9) AS MATRICULA_REDE
,   LPAD(TO_CHAR(NUM_CPF),11,0) AS CPF
,   NOM_ESTAGIARIO   AS NOME
,   'E' AS I_T
FROM IFRAGENDA.VIW_AGENDA_ESTAGIARIO
ORDER BY 4
/

