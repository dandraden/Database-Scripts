USE [GEACupax]
GO
/****** Object:  StoredProcedure [dbo].[usp_val_up3a]    Script Date: 12/15/2010 12:29:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.usp_val_up3a    Script Date: 19/09/2008 15:21:23 ******/



if exists(select * from sysobjects where name = 'usp_val_up3a')
   drop procedure usp_val_up3a
go


Create  PROCEDURE [dbo].[usp_val_up3a] 
               ( @p_serial              char(9), 
                 @p_dependencia         char(3), 
                 @p_sigla               char(4),
                 @p_date_created        datetime, 
                 @p_user_id_created     char(30), 
                 @p_date_changed        datetime, 
                 @p_user_id_changed     char(30), 
                 @p_inactive_ind        char(1), 
                 @p_active_date         datetime,
                 -- Especiais
                 @p_activity_id         char(10),           	-- Código da Atividade
                 @p_output              char(1) ,            	-- 1 faz select do codigo da mensagem-- 0 não faz deve utilizar variavel output
                 @p_campo               char(20),            	-- Nome do campo a ser validado, ou 'todos' para validar tudo
                 @p_acao                char(1),             	-- I Inclusão 	U Update 	D Delete 	C Consulta 	X viene del itemghanged
                 @p_error_message_id    char(10) output,     	-- Código da mensagem de erro ou 0000 se estiver tudo OK
                 @p_error_complemento   char(100) output,     	-- Complemento da mensagem
                 @p_error_campo         char(20) output   )  	--  Código do campo com erro
                
AS 

-- Iniciando Variaveis de Retorno
SELECT  @p_error_message_id = '0000', @p_error_complemento = ' ',  @p_error_campo = ' '

-- Outras Variaveis
DECLARE	@result		VARCHAR(255)

-- ------------------------------------------------------------------------
-- VALIDAR SIGLA
IF @p_campo = 'sigla' OR @p_campo = 'todos'
BEGIN
    SELECT @result = no_aerop FROM GEACutcx..cor_aeroporto_u  (NOLOCK INDEX = P_cor_aeroporto_u) WHERE cd_aerop = @p_sigla
    IF  @result = '' OR @result IS NULL
    BEGIN
        SELECT @p_error_message_id 		= 'upa9929'
        SELECT @p_error_complemento 	= ''
        SELECT @p_error_campo  			= 'sigla'
        GOTO  TERMINA 
    END 
    ELSE
    BEGIN
        SELECT @p_error_message_id 		= '0000'
        SELECT @p_error_complemento 	= @result
        SELECT @p_error_campo  			= 'sigla'
        IF @p_acao = 'X' GOTO TERMINA
    END
END

-- ------------------------------------------------------------------------
-- VALIDAR DEPENDENCIA
IF @p_campo = 'dependencia' OR @p_campo = 'todos'
BEGIN
	
    SELECT @result = dependencia_descp FROM GEACrpt..infra_dependencias (nolock) WHERE dependencia = @p_dependencia
    IF  @result = '' OR @result IS NULL
    BEGIN
        SELECT @p_error_message_id 		= 'upa9929'
        SELECT @p_error_complemento 	= ''
        SELECT @p_error_campo  			= 'dependencia'
        GOTO  TERMINA 
    END 
    ELSE
    BEGIN
        SELECT @p_error_message_id 		= '0000'
        SELECT @p_error_complemento 	= @result
        SELECT @p_error_campo  			= 'dependencia'
        IF @p_acao = 'X' GOTO TERMINA
    END
END


TERMINA:
IF @p_output = '1'
BEGIN
    SELECT @p_error_message_id,  @p_error_complemento ,  @p_error_campo         
END

IF  @p_error_message_id = '0000'
    RETURN 0
ELSE
    RETURN 1
