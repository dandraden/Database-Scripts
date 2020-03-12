-- Start of DDL Script for Procedure IFRSRH.PRC_ALTERA_PERFIL
-- Generated 30-jun-2010 15:12:25 from IFRSRH@DSV

CREATE OR REPLACE 
PROCEDURE          prc_altera_perfil (pPermissao number, pRole varchar, pMatriculaUsuario number, pMatriculaGestor number)
IS
   v_sql                    varchar2(100) := null;
   v_role                   varchar2(30)   := pRole;
   v_roleSistema            number(1)   := null;
   v_usuario                varchar2(8)   := 'I'||LPAD(to_char(pMatriculaUsuario),7,0);
   v_emp_numero_matricula   varchar2(7) := null;
   v_corpo_msg              varchar2(1500):= null;
   v_usr_solic              varchar2(100) := null;
   v_usr_maquina            varchar2(100) := null;
   v_EmailPara              varchar2(80) := null;

/*----------------------------------------------------------------------------------
-- PRC_ALTERA_PERFIL                                  --
--                                                                                --
-- Procedure utilizada para alterar perfil do usu�rio e enviar email ao gestor    --
-- do sistema                                                                     --
-- Autor: Ana Carina e Carlos Eduardo                                             --
-- Data: 04/07/2005                                                               --
-- Dependencias:  ifrsrh.envia_email     - PARA ENVIAR EMAIL PARA O GESTOR       --
--                ifrsrh.log_altera_perfil    - INSERE REGISTRO NA TABELA DE LOG  --
--                                                                                 --
-- Privil�gios que o owner deve ter: (grant any role, grant de select na dba_roles)--
-- Sin�nimo: create public synonym PRC_ALTERA_PERFIL for ifrsrh.PRC_ALTERA_PERFIL --
--                                                                                --
-- Usu�rio de conex�o: create user usr_altera_perfil identified by infraero;      --
--                     grant create session to  usr_altera_perfil;                --
--                     grant select on ifrsrh.cadastros to usr_altera_perfil;     --
--                     grant execute on prc_altera_perfil  to usr_altera_perfil;  --
----------------------------------------------------------------------------------*/
begin
    ----------------------------------------------------------------
    -- Verifica se a matricula do usu�rio existe na tabela Cadastros
    -- sen�o existir aborta a opera��o
    ----------------------------------------------------------------
    begin
        select  emp_numero_matricula
        into    v_emp_numero_matricula
        from    cadastros
        where   emp_numero_matricula = pMatriculaUsuario
        and     emp_status <> 2; -- ativo
    exception
        when no_data_found then
            raise_application_error(-20000,'N�o existe essa matr�cula na tabela Cadastros ou o Empregado n�o est� Ativo.');
    end;

    ----------------------------------------------------------------
    -- Recupera email do gestor
    ----------------------------------------------------------------
    begin
        select emp_endereco_eletronico_mail 
        into   v_EmailPara
        from   cadastros
        where emp_numero_matricula = pMatriculaGestor;
    exception
        when no_data_found then
            raise_application_error(-20000,'Matr�cula do gestor do sistema est� errada.');      
    end;
    ----------------------------------------------------------------------------------------
    -- Recupera o usu�rio do Sistema Operacional e a maquina de onde partiu a opera��o
    ----------------------------------------------------------------------------------------
    select sys_context('USERENV','OS_USER') into v_usr_solic from dual;
    select sys_context('USERENV','TERMINAL') into v_usr_maquina from dual;

    ------------------------------------------------------------------------------
    -- Verifica se nao esta sendo dado privilegio em role do SGBD
    ------------------------------------------------------------------------------  
   begin
        select count(role)
        into v_RoleSistema
        from dba_roles
        where role in ('AQ_ADMINISTRATOR_ROLE','AQ_USER_ROLE','CONNECT','CTXAPP','DBA','DELETE_CATALOG_ROLE','EJBCLIENT',
        'EXECUTE_CATALOG_ROLE','EXP_FULL_DATABASE','GATHER_SYSTEM_STATISTICS','GLOBAL_AQ_USER_ROLE','HS_ADMIN_ROLE',
        'IMP_FULL_DATABASE','JAVA_ADMIN','JAVADEBUGPRIV','JAVA_DEPLOY','JAVAIDPRIV','JAVASYSPRIV','JAVAUSERPRIV',
        'RECOVERY_CATALOG_OWNER','RESOURCE','SELECT_CATALOG_ROLE')
        and role = pRole;--verifica se a role passada como parametro � igual a uma das roles do SGBD
        
        if v_RoleSistema > 0 then
            v_corpo_msg := 'O usu�rio '||v_usr_solic||' no computador ' || v_usr_maquina||' no dia '||to_char(sysdate, 'DD/MM/YYYY')
            ||' as '||to_char(sysdate,'HH24:MI:SS')||','||chr(13)||'tentou atribuir o perfil '||v_role||' para o usu�rio '||v_usuario||'.';        
            
            envia_email('Banco_de_dados','banco_de_dados@infraero.gov.br','Tentativa indevida de alteracao de perfil',v_corpo_msg);
            
            raise_application_error(-20000,'Perfil n�o permitido. O Banco de dados ser� notificado quanto a esta tentativa indevida.');
        end if;    
    end;    
    ------------------------------------------------------------------------------
    -- Da / retira permiss�o do usu�rio e Monta corpo da mensagem do email
    ------------------------------------------------------------------------------
    BEGIN
       --se permiss�o = 0
       if pPermissao = 0 then
          v_sql := 'REVOKE  '||v_role||' FROM '||v_usuario;
          v_corpo_msg := 'Conforme solicitacao realizada por '||v_usr_solic||' no computador '||v_usr_maquina||' em '||
            to_char(sysdate, 'DD/MM/YYYY')||' as '||to_char(sysdate,'HH24:MI:SS')||','||
            chr(13)||'foi RETIRADO o perfil '||v_role||' do usu�rio '||v_usuario||'.';  
       elsif pPermissao = 1 then
       --se permiss�o = 1
           v_sql := 'GRANT '||v_role||' TO '||v_usuario;
           v_corpo_msg := 'Conforme solicitacao realizada por '||v_usr_solic||' no computador '||v_usr_maquina||' em '||
            to_char(sysdate, 'DD/MM/YYYY')||' as '||to_char(sysdate,'HH24:MI:SS')||','||
            chr(13)||'foi CONCEDIDO o perfil '||v_role||' para o usu�rio '||v_usuario||'.';
       end if;      

       EXECUTE IMMEDIATE v_sql;
    EXCEPTION
        WHEN OTHERS THEN
            raise_application_error(-20000, 'Erro ao conceder a role '||v_role||' ao usu�rio: '||v_usuario,true);
    END;

    ------------------------------------------------------------------------------
    -- Envia email para o gestor do sistema que teve o perfil delegado/retirado
    ------------------------------------------------------------------------------
    envia_email('Banco_de_dados',v_EmailPara,'Alteracao de Perfil',v_corpo_msg);

    ----------------------------------------------------------------
    -- grava Informa��es na tabela de LOG
    ----------------------------------------------------------------
    begin
        insert into log_altera_perfil
        (DSC_USUARIO_BD,DSC_PERMISSAO,DSC_ROLE,DSC_USUARIO_SO,DAT_ALTERACAO)
        values
        (v_usuario,pPermissao,v_role,v_usr_solic,sysdate);

        commit;
    exception
        when  others then
            raise_application_error(-20000, 'Erro ao inserir registro na tabela de LOG.',true);
    end;

end;
/

-- Grants for Procedure
GRANT EXECUTE ON prc_altera_perfil TO usr_altera_perfil
/


-- End of DDL Script for Procedure IFRSRH.PRC_ALTERA_PERFIL

