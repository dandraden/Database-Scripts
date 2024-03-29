USE [GEACupax]
GO
/****** Object:  StoredProcedure [dbo].[usp_val_uqaa]    Script Date: 12/21/2010 09:24:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.usp_val_uqaa    Script Date: 19/09/2008 15:21:38 ******/

if exists(select * from sysobjects where name = 'usp_val_uqaa')
   drop procedure usp_val_uqaa
go


Create Procedure [dbo].[usp_val_uqaa]
    ( @p_cd_aerop           char(4), 
      @p_data_mov           datetime, 
      @p_cd_cia_aerea       char(3), 
      @p_nro_voo            char(5), 
      @p_fl_fiscalizado     char(1), 
      @p_user_ficalizador   char(30), 
      @p_fl_validado        char(1), 
      @p_user_validador     char(30), 
      @p_tipo_selecao       char(1),
      -- Especiais
      @p_activity_id        char(10),           -- Código da Atividade
      @p_output             char(1) ,           -- 1 faz select do codigo da mensagem-- 0 nao faz deve utilizar variavel output
      @p_campo              char(20),           -- Nome do campo a ser validado, ou 'todos' para validar tudo
      @p_acao               char(1),            -- I Inclusao  U Update  D Delete  C Consulta  X viene del itemghanged
      @p_error_message_id   char(10)  output,   -- Código da mensagem de erro ou 0000 se estiver tudo OK
      @p_error_complemento  char(100) output,   -- Complemento da mensagem
      @p_error_campo        char(20)  output)   --  Código do campo com erro
AS 
  
-- Iniciando Variaveis de Retorno
SELECT  @p_error_message_id = '0000', @p_error_complemento = ' ',  @p_error_campo = ' '
-- Outras Variaveis
DECLARE @result  			VARCHAR(255)
        ,@v_cd_cia_num		CHAR(2)
        ,@v_cd_cia_aerea	CHAR(3)
-- ------------------------------------------------------------------------
-- VALIDAR AEROPORTO
IF @p_campo = 'cd_aerop' OR @p_campo = 'todos'
BEGIN
    SELECT @result = no_aerop FROM GEACutcx..cor_aeroporto_u (NOLOCK INDEX = P_cor_aeroporto_u) WHERE cd_aerop = @p_cd_aerop
    IF  @result = '' OR @result IS NULL
    BEGIN
        SELECT @p_error_message_id   	= 'utc0026'
        SELECT @p_error_complemento   	= ''
        SELECT @p_error_campo     		= 'cd_aerop'
        GOTO  TERMINA 
    END 
    ELSE
    BEGIN
        SELECT @p_error_message_id   	= '0000'
        SELECT @p_error_complemento   	= @result
        SELECT @p_error_campo     		= 'cd_aerop'
        IF @p_acao = 'X' GOTO TERMINA
    END
END

-- ------------------------------------------------------------------------
-- VALIDAR @p_data_mov
IF @p_campo = 'data_mov' OR @p_campo = 'todos'
BEGIN
    IF @p_data_mov > GETDATE()
    BEGIN
        SELECT @p_error_message_id   	= 'upa9010'
        SELECT @p_error_complemento   	= ''
        SELECT @p_error_campo     		= 'data_mov'
        GOTO  TERMINA 
    END
END



-- ------------------------------------------------------------------------
-- VALIDAR CIA AEREA
IF @p_campo = 'cd_cia_aerea' OR @p_campo = 'todos'
BEGIN
    SELECT @result = rtrim(no_cia_aerea)
	FROM GEACutcx..cor_cia_aerea_u (NOLOCK INDEX = P_cor_cia_aerea_u) WHERE cd_cia_aerea = @p_cd_cia_aerea and inactive_ind = 0
    IF  @result = '' OR @result IS NULL
    BEGIN
        SELECT @p_error_message_id   	= 'utc0014'
        SELECT @p_error_complemento   	= ''
        SELECT @p_error_campo     		= 'cd_cia_aerea'
        GOTO  TERMINA 
    END 
    ELSE
    BEGIN
        SELECT @p_error_message_id   	= '0000'
        SELECT @p_error_complemento   	= @result
        SELECT @p_error_campo     		= 'cd_cia_aerea'
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
