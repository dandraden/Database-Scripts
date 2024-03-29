USE [GEACupax]
GO
/****** Object:  Trigger [dbo].[utrg_ins_pax_selos_bd_u]    Script Date: 12/13/2010 08:05:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

if exists(select * from sysobjects where name = 'utrg_ins_upd_pax_selo_electronico_u')
   drop Trigger utrg_ins_upd_pax_selo_electronico_u
go


Create Trigger [dbo].[utrg_ins_upd_pax_selo_electronico_u] On [dbo].[pax_selo_electronico_u]
For Insert, Update
As 
    Declare @p_cd_aerop                                 char(4), 
			@p_cd_terminal                              char(10), 
			@p_dt_mov                                   datetime, 
			@p_nro_selo_electronico                     char(14), 
			@p_tp_natureza                              char(1), 
			@p_selo_status                              char(1), 
			@p_cd_motivo                                char(2), 
			@p_tp_fat                                   char(1), 
			@p_cd_cia_aerea                             char(3), 
			@p_tp_unid                                  char(1), 
			@p_dt_confirma                              datetime, 
			@p_cd_aerop_utilizacao                      char(4), 
			@p_cd_terminal_utilizacao                   char(10), 
			@p_tp_coletor                               char(16), 
			@p_item_fat                                 char(26), 
			@p_billing_line_id                          int, 
			@p_billing_int_date                         datetime, 
			@p_billing_int_type                         char(1), 
			@p_billing_user_1                           char(10), 
			@p_voo_rea                                  char(4), 					
			@p_dt_voo_rea                               datetime,
			@p_hh_voo_rea                               char(6), 
			@p_hh_mov                                   char(6), 
			@p_date_created                             datetime, 
			@p_user_id_created                          char(30), 
			@p_date_changed                             datetime, 
			@p_user_id_changed                          char(30), 
			@p_inactive_ind                             char(1), 
			@p_active_date                              datetime,
            @p_chgstamp                                 smallint 

    Declare @w_arquivo                                  char(40),
            @w_nro_linha                                int,
            @w_linha                                    char(30),
            @w_cd_aerop_num                             char(3),
            @w_tp_selo                                  char(1),
            @w_nro_selo                                 char(14),
            @w_format_code                              char(1),
            @w_num_legs_encode                          char(1),
            @w_passenger_name                           varchar(20),
            @w_eletronic_ticket_ind                     char(1),
            @w_oper_carrier_pnr_code                    varchar(7),
            @w_source_code                              char(3),
            @w_target_code                              char(3),
            @w_oper_carrier_designator                  char(3),
            @w_flight_number                            varchar(5),
            @w_flight_date                              char(3),
            @w_compartiment_code                        char(1),
            @w_seat_number                              char(4),
            @w_checkin_seq_number                       varchar(5),
            @w_passenger_status                         char(1),
            @w_field_size_follow_var                    char(2),
            @w_beginning_version_number                 char(1),
            @w_version_number                           char(1),
            @w_field_size_follow_struc_unique           char(2),
            @w_passenger_desc                           char(1),
            @w_checkin_source                           char(1),
            @w_boarding_pass_source                     char(1),
            @w_boarding_pass_date                       varchar(4),
            @w_document_type                            char(1),
            @w_airline_desig_boarding_pass              varchar(3),
            @w_field_size_follow_struc_repeat           varchar(2),
            @w_airline_numeric_code                     char(3),
            @w_document_form_serial_num                 varchar(10),
            @w_selectee_indicator                       char(1),
            @w_international_doc_verification           char(1),
            @w_marketing_carrier_designator             varchar(3),
            @w_frequent_flyer_airline_desig             varchar(3),
            @w_frequent_flyer_num                       varchar(16),
            @w_id_ad_indicator                          char(1),
            @w_free_baggage_allowance                   varchar(3),
            @w_generic_individual_airline_use           char(1),
            @w_tp_baixa                                 char(1),
            @w_dt_leitura                               datetime,
            @w_serie_coletor                            char(9),
            @w_tp_coletor                               char(16),
            @w_cd_terminal                              char(10),
            @w_user_id                                  char(30),
            @w_cpf_agente                               char(11),
            @w_login                                    char(60),
            @w_versao_coletor                           char(3),
            @w_status_linha                             char(1),
            @w_user_id_created                          char(30),
            @w_date_created                             datetime,
            @fetch_status                               int

    Declare ins_cur_selos Cursor For
        Select cd_aerop, 
               cd_terminal, 
               dt_mov, 
               nro_selo_electronico, 
               tp_natureza, 
               selo_status, 
               cd_motivo, 
               tp_fat, 
               cd_cia_aerea, 
               tp_unid, 
               dt_confirma, 
               cd_aerop_utilizacao, 
               cd_terminal_utilizacao, 
               tp_coletor, 
               item_fat, 
               billing_line_id, 
               billing_int_date, 
               billing_int_type, 
               billing_user_1, 
               voo_rea, 					
               dt_voo_rea,
               hh_voo_rea, 
               hh_mov, 
               date_created, 
               user_id_created, 
               date_changed, 
               user_id_changed, 
               inactive_ind, 
               active_date,
               chgstamp
          From inserted

        Open ins_cur_selos

        Fetch ins_cur_selos
         Into @p_cd_aerop, 
              @p_cd_terminal, 
              @p_dt_mov, 
              @p_nro_selo_electronico, 
              @p_tp_natureza, 
              @p_selo_status, 
              @p_cd_motivo, 
              @p_tp_fat, 
              @p_cd_cia_aerea, 
              @p_tp_unid, 
              @p_dt_confirma, 
              @p_cd_aerop_utilizacao, 
              @p_cd_terminal_utilizacao, 
              @p_tp_coletor, 
              @p_item_fat, 
              @p_billing_line_id, 
              @p_billing_int_date, 
              @p_billing_int_type, 
              @p_billing_user_1, 
              @p_voo_rea, 					
              @p_dt_voo_rea,
              @p_hh_voo_rea, 
              @p_hh_mov, 
              @p_date_created, 
              @p_user_id_created, 
              @p_date_changed, 
              @p_user_id_changed, 
              @p_inactive_ind, 
              @p_active_date,
              @p_chgstamp

        While @@fetch_status = 0
        Begin

            Select Top 1
                   @w_arquivo               = c.arquivo,
                   @w_nro_linha             = c.nro_linha
              From GEACupax..pax_selos_coletados_u  c (nolock)
             Where substring(c.linha, 7, 6) = @p_hh_mov
               And c.nro_selo               = @p_nro_selo_electronico

            Select @w_linha                                    = linha,
                   @w_cd_aerop_num                             = cd_aerop_num,
                   @w_tp_selo                                  = tp_selo,
                   @w_nro_selo                                 = nro_selo,
                   @w_format_code                              = format_code,
                   @w_num_legs_encode                          = num_legs_encode,
                   @w_passenger_name                           = passenger_name,
                   @w_eletronic_ticket_ind                     = eletronic_ticket_ind,
                   @w_oper_carrier_pnr_code                    = oper_carrier_pnr_code,
                   @w_source_code                              = source_code,
                   @w_target_code                              = target_code,
                   @w_oper_carrier_designator                  = oper_carrier_designator,
                   @w_flight_number                            = flight_number,
                   @w_flight_date                              = flight_date,
                   @w_compartiment_code                        = compartiment_code,
                   @w_seat_number                              = seat_number,
                   @w_checkin_seq_number                       = checkin_seq_number,
                   @w_passenger_status                         = passenger_status,
                   @w_field_size_follow_var                    = field_size_follow_var,
                   @w_beginning_version_number                 = beginning_version_number,
                   @w_version_number                           = version_number,
                   @w_field_size_follow_struc_unique           = field_size_follow_struc_unique,
                   @w_passenger_desc                           = passenger_desc,
                   @w_checkin_source                           = checkin_source,
                   @w_boarding_pass_source                     = boarding_pass_source,
                   @w_boarding_pass_date                       = boarding_pass_date,
                   @w_document_type                            = document_type,
                   @w_airline_desig_boarding_pass              = airline_desig_boarding_pass,
                   @w_field_size_follow_struc_repeat           = field_size_follow_struc_repeat,
                   @w_airline_numeric_code                     = airline_numeric_code,
                   @w_document_form_serial_num                 = document_form_serial_num,
                   @w_selectee_indicator                       = selectee_indicator,
                   @w_international_doc_verification           = international_doc_verification,
                   @w_marketing_carrier_designator             = marketing_carrier_designator,
                   @w_frequent_flyer_airline_desig             = frequent_flyer_airline_desig,
                   @w_frequent_flyer_num                       = frequent_flyer_num,
                   @w_id_ad_indicator                          = id_ad_indicator,
                   @w_free_baggage_allowance                   = free_baggage_allowance,
                   @w_generic_individual_airline_use           = generic_individual_airline_use,
                   @w_tp_baixa                                 = tp_baixa,
                   @w_dt_leitura                               = dt_leitura,
                   @w_serie_coletor                            = serie_coletor,
                   @w_tp_coletor                               = tp_coletor,
                   @w_cd_terminal                              = cd_terminal,
                   @w_user_id                                  = user_id,
                   @w_cpf_agente                               = cpf_agente,
                   @w_login                                    = login,
                   @w_versao_coletor                           = versao_coletor,
                   @w_status_linha                             = status_linha,
                   @w_user_id_created                          = user_id_created,
                   @w_date_created                             = date_created
              From GEACupax..pax_selos_coletados_bd_u (nolock)
             Where arquivo                                     = @w_arquivo
               And nro_linha                                   = @w_nro_linha

            If @@Rowcount > 0
            Begin
                Delete from GEACupax..pax_selos_bd_u
                 Where cd_aerop                 = @p_cd_aerop
                   And cd_terminal              = @p_cd_terminal
                   And dt_mov                   = @p_dt_mov
                   And nro_selo_electronico     = @p_nro_selo_electronico
                   And hh_mov                   = @p_hh_mov

                Insert Into GEACupax..pax_selos_bd_u
                     ( cd_aerop
                      ,cd_terminal
                      ,dt_mov
                      ,nro_selo_electronico
                      ,hh_mov
                      ,format_code
                      ,num_legs_encode
                      ,passenger_name
                      ,eletronic_ticket_ind
                      ,oper_carrier_pnr_code
                      ,source_code
                      ,target_code
                      ,oper_carrier_designator
                      ,flight_number
                      ,flight_date
                      ,compartiment_code
                      ,seat_number
                      ,checkin_seq_number
                      ,passenger_status
                      ,field_size_follow_var
                      ,beginning_version_number
                      ,version_number
                      ,field_size_follow_struc_unique
                      ,passenger_desc
                      ,checkin_source
                      ,boarding_pass_source
                      ,boarding_pass_date
                      ,document_type
                      ,airline_desig_boarding_pass
                      ,field_size_follow_struc_repeat
                      ,airline_numeric_code
                      ,document_form_serial_num
                      ,selectee_indicator
                      ,international_doc_verification
                      ,marketing_carrier_designator
                      ,frequent_flyer_airline_desig
                      ,frequent_flyer_num
                      ,id_ad_indicator
                      ,free_baggage_allowance
                      ,generic_individual_airline_use
                      ,date_created
                      ,user_id_created
                      ,date_changed
                      ,user_id_changed
                      ,inactive_ind
                      ,active_date
                      ,chgstamp )
                Values
                     ( @p_cd_aerop
                      ,@p_cd_terminal
                      ,@p_dt_mov
                      ,@p_nro_selo_electronico
                      ,@p_hh_mov
                      ,@w_format_code
                      ,@w_num_legs_encode
                      ,@w_passenger_name
                      ,@w_eletronic_ticket_ind
                      ,@w_oper_carrier_pnr_code
                      ,@w_source_code
                      ,@w_target_code
                      ,@w_oper_carrier_designator
                      ,@w_flight_number
                      ,@w_flight_date
                      ,@w_compartiment_code
                      ,@w_seat_number
                      ,@w_checkin_seq_number
                      ,@w_passenger_status
                      ,@w_field_size_follow_var
                      ,@w_beginning_version_number
                      ,@w_version_number
                      ,@w_field_size_follow_struc_unique
                      ,@w_passenger_desc
                      ,@w_checkin_source
                      ,@w_boarding_pass_source
                      ,@w_boarding_pass_date
                      ,@w_document_type
                      ,@w_airline_desig_boarding_pass
                      ,@w_field_size_follow_struc_repeat
                      ,@w_airline_numeric_code
                      ,@w_document_form_serial_num
                      ,@w_selectee_indicator
                      ,@w_international_doc_verification
                      ,@w_marketing_carrier_designator
                      ,@w_frequent_flyer_airline_desig
                      ,@w_frequent_flyer_num
                      ,@w_id_ad_indicator
                      ,@w_free_baggage_allowance
                      ,@w_generic_individual_airline_use
                      ,@p_date_created
                      ,@p_user_id_created
                      ,@p_date_changed
                      ,@p_user_id_changed
                      ,@p_inactive_ind
                      ,@p_active_date
                      ,@p_chgstamp )
            End

            Fetch ins_cur_selos
             Into @p_cd_aerop, 
                  @p_cd_terminal, 
                  @p_dt_mov, 
                  @p_nro_selo_electronico, 
                  @p_tp_natureza, 
                  @p_selo_status, 
                  @p_cd_motivo, 
                  @p_tp_fat, 
                  @p_cd_cia_aerea, 
                  @p_tp_unid, 
                  @p_dt_confirma, 
                  @p_cd_aerop_utilizacao, 
                  @p_cd_terminal_utilizacao, 
                  @p_tp_coletor, 
                  @p_item_fat, 
                  @p_billing_line_id, 
                  @p_billing_int_date, 
                  @p_billing_int_type, 
                  @p_billing_user_1, 
                  @p_voo_rea, 					
                  @p_dt_voo_rea,
                  @p_hh_voo_rea, 
                  @p_hh_mov, 
                  @p_date_created, 
                  @p_user_id_created, 
                  @p_date_changed, 
                  @p_user_id_changed, 
                  @p_inactive_ind, 
                  @p_active_date,
                  @p_chgstamp

        End

        Close ins_cur_selos
        Deallocate ins_cur_selos

go