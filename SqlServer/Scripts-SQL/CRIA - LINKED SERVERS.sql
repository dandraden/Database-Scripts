/****** Script for SelectTopNRows command from SSMS  ******/
SELECT 
 'EXEC master.dbo.sp_addlinkedserver @server = N''' + sig_aeroporto + ' - INTEGRACAO'', @srvproduct=N''SQLSERVER'', @provider=N''SQLNCLI'', @datasrc=N''' + upper([dsc_enderenco_ip]) + ''', @catalog=N''INTEGRACAO''', 
 'EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N''' + sig_aeroporto + ' - INTEGRACAO'',@useself=N''False'',@locallogin=NULL,@rmtuser=N''siso_carga'',@rmtpassword=''X275siso@Z'''
  FROM [BIOGER].[dbo].[BIOGER_SERVERS_SISO]
 WHERE sta_srv_primario = 1