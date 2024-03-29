DECLARE

CURSOR C1 IS
SELECT E.EMP_NUMERO_MATRICULA, E.EMP_NOME, E.EMP_ENDERECO_ELETRONICO_MAIL, O.LOGIN, O.NOME, O.EMAIL
  FROM CADASTROS E,
       (SELECT LOGIN, NOME, EMAIL, RAMAL_IP, TO_NUMBER(SUBSTR(LOGIN,2)) AS MATRICULA
          FROM ORGANICOS 
         WHERE EMAIL != 'N/D'
           AND LOGIN NOT LIKE '%IN%') O
WHERE  E.EMP_NUMERO_MATRICULA = O.MATRICULA
  AND  E.EMP_STATUS <> 2;
  
BEGIN

	FOR X IN C1 LOOP
			 UPDATE  CADASTROS 
			    SET  EMP_ENDERECO_ELETRONICO_MAIL	= X.EMAIL
			  WHERE  EMP_NUMERO_MATRICULA = X.EMP_NUMERO_MATRICULA;
			  
			 UPDATE  IFRCORP.TAB_INTERFACE_IDM
			    SET  DSC_ENDERECO_ELETRONICO = X.EMAIL
			  WHERE  NUM_MATRICULA = X.EMP_NUMERO_MATRICULA;
	END LOOP;
	
END;
/

/*

SELECT E.EMP_NUMERO_MATRICULA, E.EMP_NOME, E.EMP_ENDERECO_ELETRONICO_MAIL, E.EMP_DEP_FISICO_SIGLA, E.EMP_UOR_SIGLA
  FROM VIW_CADASTROS E
WHERE  E.EMP_ENDERECO_ELETRONICO_MAIL IS NULL
  AND  E.EMP_STATUS <> 'DESLIGADO'
ORDER 
   BY  4,5,1;


SELECT  'I' || LPAD(EMP_NUMERO_MATRICULA, 7, '0') AS MATRICULA
     ,  EMP_NOME  AS NOME
     ,  EMP_ENDERECO_ELETRONICO_MAIL AS EMAIL
  FROM  CADASTROS
 WHERE  EMP_STATUS != 2
   AND  EMP_NUMERO_MATRICULA NOT IN
          (SELECT SUBSTR(LOGIN,2)
             FROM ORGANICOS)
   AND  EMP_ENDERECO_ELETRONICO_MAIL IS NOT NULL
 ORDER
    BY  1 

SELECT E.NUM_MATRICULA, E.NME_CADASTRO, E.DSC_ENDERECO_ELETRONICO, O.LOGIN, O.NOME, O.EMAIL
  FROM IFRCORP.TAB_INTERFACE_IDM E,
       (SELECT LOGIN, NOME, EMAIL, RAMAL_IP, TO_NUMBER(SUBSTR(LOGIN,2)) AS MATRICULA
          FROM ORGANICOS 
         WHERE EMAIL != 'N/D'
           AND LOGIN NOT LIKE '%IN%') O
WHERE  E.NUM_MATRICULA = O.MATRICULA;
  
  

select o.login, o.nome, o.email, TO_NUMBER(SUBSTR(o.LOGIN,2)) as matricula
from organicos o, (
SELECT EMAIL, count(1) --, NOME, EMAIL, RAMAL_IP 
FROM ORGANICOS
group by EMAIL
having count(1) > 1) r
where o.email = r.email
order by o.email;

SELECT o.login, o.nome, o.email, c.emp_numero_matricula
, DECODE(c.emp_status,0,'TEMPORARIAMENTEAFASTADO',1,'ATIVO',2,'DESLIGADO',c.emp_status) AS EMP_STATUS
, emp_endereco_eletronico_mail
from cadastros c, (
select o.login, o.nome, o.email, TO_NUMBER(SUBSTR(o.LOGIN,2)) as matricula
from organicos o, (
SELECT EMAIL, count(1) --, NOME, EMAIL, RAMAL_IP 
FROM ORGANICOS
group by EMAIL
having count(1) > 1) r
where o.email = r.email
) o
where c.emp_numero_matricula = o.matricula
order by o.email;

SELECT E.EMP_NUMERO_MATRICULA, E.EMP_NOME, E.EMP_ENDERECO_ELETRONICO_MAIL, O.LOGIN, O.NOME, O.EMAIL
FROM CADASTROS E,
    (SELECT LOGIN, NOME, EMAIL, RAMAL_IP, TO_NUMBER(SUBSTR(LOGIN,2)) AS MATRICULA
       FROM ORGANICOS 
      WHERE EMAIL != 'N/D'
        AND LOGIN NOT LIKE '%in%') O
WHERE E.EMP_NUMERO_MATRICULA = O.MATRICULA;


SELECT LOGIN, NOME, EMAIL, RAMAL_IP, TO_NUMBER(SUBSTR(LOGIN,2)) AS MATRICULA
 FROM ORGANICOS 
WHERE EMAIL != 'N/D'
  AND LOGIN NOT LIKE '%in%'
order by 5 desc


SELECT EMAIL, COUNT(1) AS TOTAL
 FROM ORGANICOS 
WHERE EMAIL != 'N/D'
  AND LOGIN NOT LIKE '%in%'
GROUP BY EMAIL  
HAVING COUNT(1) > 1

SELECT o.login, o.nome, o.email, c.emp_numero_matricula
, DECODE(c.emp_status,0,'TEMPORARIAMENTEAFASTADO',1,'ATIVO',2,'DESLIGADO',c.emp_status) AS EMP_STATUS
from cadastros c, (
select o.login, o.nome, o.email, TO_NUMBER(SUBSTR(o.LOGIN,2)) as matricula
from organicos_full o
) o
where c.emp_numero_matricula = o.matricula
and c.emp_status = 2
order by o.email;

delete
FROM ORGANICOS 
WHERE LENGTH(LOGIN) > 8

delete
FROM ORGANICOS 
WHERE UPPER(LOGIN) LIKE '%IN%'

delete 
FROM ORGANICOS 
WHERE EMAIL = '@infraero.gov.br';

delete 
FROM ORGANICOS 
WHERE EMAIL is null;

delete
FROM ORGANICOS 
WHERE EMAIL = 'N/D';

LOGIN IN ('I123', 'IANAC','isiv')

--RAMAL
SELECT  *
  FROM  EMPREGADO_FONE_COMERCIAL
 WHERE  EFC_UFF_TIPO = 4
   AND  EFC_EMP_NUMERO_MATRICULA IN (SELECT EMP_NUMERO_MATRICULA FROM CADASTROS WHERE EMP_STATUS != 2)
   AND  efc_emp_numero_matricula = 1585021
 ORDER
    BY  1 DESC
 
--SELECT  * FROM  EMPREGADO_FONE_COMERCIAL WHERE efc_emp_numero_matricula = 1339921
--UPDATE EMPREGADO_FONE_COMERCIAL SET EFC_UFF_NUMERO = 3651 WHERE EFC_UFF_TIPO = 4 AND  efc_emp_numero_matricula = 1585021
--INSERT INTO EMPREGADO_FONE_COMERCIAL VALUES(1462533,1,33123021,61)
--INSERT INTO EMPREGADO_FONE_COMERCIAL VALUES(1462533,2,3021,61)
--INSERT INTO EMPREGADO_FONE_COMERCIAL VALUES(1462533,1,33123309,61)
--INSERT INTO EMPREGADO_FONE_COMERCIAL VALUES(1462533,4,3021,61)

SELECT  'I' || LPAD(EFC_EMP_NUMERO_MATRICULA, 7, '0') AS MATRICULA
     ,  (SELECT EMP_NOME FROM CADASTROS WHERE EMP_NUMERO_MATRICULA = EFC_EMP_NUMERO_MATRICULA) AS NOME
     ,  EFC_UFF_VOIP_DDD AS DDD_RAMAL
     ,  EFC_UFF_NUMERO AS RAMAL
  FROM  EMPREGADO_FONE_COMERCIAL
 WHERE  EFC_UFF_TIPO = 4
   AND  EFC_EMP_NUMERO_MATRICULA IN (SELECT EMP_NUMERO_MATRICULA FROM CADASTROS WHERE EMP_STATUS != 2)
   AND  efc_emp_numero_matricula NOT IN
          (SELECT SUBSTR(LOGIN,2)
             FROM ORGANICOS_FULL
            WHERE RAMAL_IP IS NOT NULL)
 ORDER
    BY  1 
    
SELECT E.EMP_NUMERO_MATRICULA, E.EMP_NOME, '' AS RAMAL, E.EMP_DEP_FISICO_SIGLA, E.EMP_UOR_SIGLA
  FROM VIW_CADASTROS E
 WHERE E.EMP_STATUS <> 'DESLIGADO'
   AND E.EMP_NUMERO_MATRICULA NOT IN (
SELECT  EFC_EMP_NUMERO_MATRICULA
  FROM  EMPREGADO_FONE_COMERCIAL
)
ORDER
   BY  4,5,1;    
 

*/