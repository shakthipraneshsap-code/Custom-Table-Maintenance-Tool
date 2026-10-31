*&---------------------------------------------------------------------*
* MODULE           :
* PURPOSE          : To Generate a Report, which works dynamically based -
*                  : - on input Table names. - Phase 06
* REPORT NAME      : Z_DYNAMIC_TABLE_REPORT_06
* REQUEST NUMBER   : $TMP - Local Object
* TECHNICAL SPEC # :
* DATE CREATED     : 27-04-2026
* AUTHOR           : LISABAP - 3165
* REQUESTED BY     : Shakthi
* BUSINESS LOGIC   :
* CODING LOGIC     :
*----------------------------------------------------------------------*
* MODIFICATION LOG
*----------------------------------------------------------------------*
*                                                             Change/
*                                                  IMS #/     Support
* MODIFIED DATE  MODIFIED BY        REFERENCE      OSS NOTE   Request
*----------------------------------------------------------------------*
*<MM/DD/YYYY>    <> <AAMMDDYYYYX>  <XXXXXXX>  <XXXXXXX>
*
*----------------------------------------------------------------------*
REPORT z_dynamic_table_report_06 NO STANDARD PAGE HEADING.

*----------------------------------------------------------------------*

TYPES : BEGIN OF ty_field,
          fieldname   TYPE dfies-fieldname,
          field_label TYPE dfies-scrtext_l,
          datatype    TYPE dfies-datatype,
          sign        TYPE dfies-sign,
          length      TYPE dfies-leng,
          decimals    TYPE dfies-decimals,
          keyflag     TYPE dfies-keyflag,
          sel         TYPE abap_bool,
        END OF ty_field.

*----------------------------------------------------------------------*

" For Form - GET_DATA
DATA : lr_data TYPE REF TO data.

FIELD-SYMBOLS : <lt_data> TYPE STANDARD TABLE.

" For Form - READ_DDIC_DATA.

DATA : ls_ddic TYPE dfies,
       lt_ddic TYPE TABLE OF dfies.

DATA : lt_keys   TYPE TABLE OF dfies,
       lt_fields TYPE TABLE OF dfies.

" For Form - INIT_FREE_SELECTION

DATA : ls_fields_init TYPE rsdsfields,
       lt_fields_init TYPE rsdsfields_t.

DATA : gv_solid TYPE rsdynsel-selid.

DATA : gt_ranges TYPE rsds_trange,
       gt_where  TYPE rsds_twhere.
****DATA : gt_expre  TYPE rsds_texpr.

" For - Field Selection Screen

DATA : go_container TYPE REF TO cl_gui_custom_container,
       go_alv       TYPE REF TO cl_gui_alv_grid.

DATA : gs_sel_field TYPE ty_field,
       gt_sel_field TYPE TABLE OF ty_field.

DATA : ls_layout TYPE lvc_s_layo.

" For Form - BUILD_FIELDCAT

DATA : ls_fieldcat TYPE lvc_s_fcat,
       lt_fieldcat TYPE TABLE OF lvc_s_fcat.

" temporary fields for logical use

DATA : lv_temp_count   TYPE i,
       lv_check_fields TYPE c VALUE ' '.

DATA : lv_check_insert TYPE c VALUE ' '.

***DATA : lv_init_tmp TYPE c VALUE 'X'.

" For Form - EXCLUDE_STD_BUTTONS

DATA : lt_exclude TYPE ui_functions,
       ls_exclude TYPE ui_func.

" Input Fields

DATA : p_tab   TYPE tabname,
       max_sel LIKE rseumod-tbmaxsel VALUE '500'.

DATA : rb_display TYPE c,
       rb_insert  TYPE c,
       rb_update  TYPE c,
       rb_delete  TYPE c.

" Other PRG Fields

DATA : ok_code1000 LIKE sy-ucomm,
       ok_code0100 LIKE sy-ucomm,
       ok_code0200 LIKE sy-ucomm,
       ok_code0300 LIKE sy-ucomm,
       ok_code0400 LIKE sy-ucomm.

" For FORM - UPDATE_FIELDLABEL_SALV

DATA : lo_column  TYPE REF TO cl_salv_column,
       lo_columns TYPE REF TO cl_salv_columns_table.

" For FORM - DISPLAY_ALV

DATA : lo_alv TYPE REF TO cl_salv_table.

DATA : lo_functions TYPE REF TO cl_salv_functions_list.

DATA : lo_layout TYPE REF TO cl_salv_layout.

" For FORM - ALV_FOR_UPDATE - To Update DB

DATA : lo_container TYPE REF TO cl_gui_custom_container,
       lo_gui_alv   TYPE REF TO cl_gui_alv_grid.

" For FORM - ALV_FOR_DELETE - To Delete records of a Table

DATA : ls_layout_02 TYPE lvc_s_layo.

" For Title Bar Screens

DATA : text1 TYPE c LENGTH 100, "VALUE 'Display Table:',
       text2 TYPE c LENGTH 100, "VALUE 'Insert Records into Table:',
       text3 TYPE c LENGTH 100, "VALUE 'Update Records of Table:',
       text4 TYPE c LENGTH 100. "VALUE 'Delete Records of Table'.

" For FORM - GET_SEL_RECORDS

DATA : ls_selected_rows TYPE lvc_s_row,
       lt_selected_rows TYPE lvc_t_row.

DATA : lr_data_del TYPE REF TO data.

FIELD-SYMBOLS : <lt_data_del> TYPE STANDARD TABLE.

" For FORM - GET_CONFIRMATION

DATA : lv_confirm_title TYPE c LENGTH 40,
       lv_confirmation  TYPE c LENGTH 400,
       lv_answer        TYPE c.

*&---------------------------------------------------------------------*
*&      Module  STATUS_1000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_1000 OUTPUT.
  SET PF-STATUS 'STATUS_1000'.
  SET TITLEBAR 'TB_1000'.

***  CLEAR : p_tab, ls_ddic, gs_sel_field, ls_fieldcat,
  CLEAR : ls_ddic, gs_sel_field, ls_fieldcat,
          ls_exclude, lv_temp_count, lv_check_fields,
          ls_fields_init, gv_solid, gt_where, gt_ranges.

  REFRESH : lt_ddic, gt_sel_field, lt_fieldcat, lt_exclude,
            lt_fields_init.

  CLEAR : ok_code1000, ok_code0100, ok_code0200, ok_code0300, ok_code0400.

  CLEAR : text1, text2, text3, text4.

ENDMODULE.


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1000 INPUT.

  IF ok_code1000 IS NOT INITIAL.

    CASE ok_code1000.
      WHEN '&F03' OR '&F15' OR '&F12'.
        LEAVE PROGRAM.

      WHEN 'ONLI'.

        IF rb_display = 'X'.

          text1 = |Display Table:| && |   | && p_tab.

          PERFORM read_ddic_data.

          PERFORM call_screen_0100.

        ELSEIF rb_insert = 'X'.

          text2 = |Insert Records into Table:| && |   | && p_tab.

          CALL SCREEN 0200.

        ELSEIF rb_update = 'X'.

          text1 = |Update Records of Table:| && |   | && p_tab.

          PERFORM read_ddic_data.

          PERFORM call_screen_0100.

        ELSEIF rb_delete = 'X'.

          text1 = |Delete Records of Table:| && |   | && p_tab.

          PERFORM read_ddic_data.

          PERFORM call_screen_0100.

        ENDIF.

      WHEN '&NTE'.

        CLEAR : p_tab, max_sel.

        max_sel = 500.

      WHEN OTHERS.
    ENDCASE.

  ENDIF.

ENDMODULE.


*&---------------------------------------------------------------------*
*&      Module  CHECK_INPUT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_input INPUT.

  IF ok_code1000 = 'ONLI'.

    IF p_tab CP 'Z*' OR p_tab CP 'z*' OR p_tab CP 'Y*' OR p_tab CP 'y*'.
      "Do Nothing
    ELSE.
      MESSAGE p_tab && | | && |is not a custom table.| TYPE 'E'.
    ENDIF.

  ENDIF.

ENDMODULE.


*&---------------------------------------------------------------------*
*&      Form  READ_DDIC_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_ddic_data .

  IF lt_ddic IS INITIAL.

    REFRESH : lt_ddic.

    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname        = p_tab
        langu          = sy-langu
        all_types      = 'X'
      TABLES
        dfies_tab      = lt_ddic
      EXCEPTIONS
        not_found      = 1
        internal_error = 2
        OTHERS         = 3.
    IF sy-subrc = 1.
* Implement suitable error handling here

      MESSAGE 'Table Not Found' TYPE 'E'.

    ELSEIF sy-subrc <> 0 AND sy-subrc <> 1.

      MESSAGE 'DDIC Read Failed' TYPE 'E'.

    ENDIF.

  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'STATUS_0100'.
  SET TITLEBAR 'TB_0100' WITH text1.


  IF go_container IS INITIAL AND ok_code0100 IS INITIAL.

    "the below commented lines needs a custom-container in the screen
    CREATE OBJECT go_container
      EXPORTING
        container_name = 'CC_ALV'.

    CREATE OBJECT go_alv
      EXPORTING
        i_parent = go_container.

***    " The below line doesn't need a custom-container, screen0 is a default dummy container
***    CREATE OBJECT go_alv
***      EXPORTING
***        i_parent = cl_gui_custom_container=>screen0.

    IF lt_fieldcat IS INITIAL.
      PERFORM build_fieldcat.
    ENDIF.

    PERFORM exclude_std_buttons.

    CALL METHOD go_alv->set_table_for_first_display(
      EXPORTING
        it_toolbar_excluding = lt_exclude
        i_save               = 'X'
        is_layout            = ls_layout
      CHANGING
        it_outtab            = gt_sel_field
        it_fieldcatalog      = lt_fieldcat ).

  ENDIF.


  CASE ok_code0100.
    WHEN 'ONLI'.

      IF lv_check_fields = 'X'.

        IF go_alv IS NOT INITIAL.
          go_alv->free( ).
        ENDIF.

        IF go_container IS NOT INITIAL.
          go_container->free( ).
        ENDIF.

        CLEAR : go_alv, go_container.

        PERFORM prep_dynamic_sel_screen.

        PERFORM init_free_selection.

        PERFORM call_free_selection_dialog.

        PERFORM get_data.

        IF <lt_data> IS NOT INITIAL.

          IF rb_display = 'X'.

            PERFORM display_alv.

          ELSEIF rb_update = 'X'.

            PERFORM build_dynamic_fieldcat.

            CALL SCREEN 0300.

          ELSEIF rb_delete = 'X'.

            PERFORM build_dynamic_fieldcat.

            CALL SCREEN 0400.

          ENDIF.

          LEAVE TO SCREEN 0.

        ELSE.

          MESSAGE 'No Data Found' TYPE 'E'.

        ENDIF.

      ENDIF.

    WHEN '&F03' OR '&F15' OR '&F12'.

      IF go_alv IS NOT INITIAL.
        go_alv->free( ).
      ENDIF.

      IF go_container IS NOT INITIAL.
        go_container->free( ).
      ENDIF.

      CLEAR : go_alv, go_container.

      LEAVE TO SCREEN 0.

    WHEN OTHERS.
  ENDCASE.

ENDMODULE.


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  IF ok_code0100 IS NOT INITIAL.

    CASE ok_code0100.
      WHEN '&F03'.
        LEAVE TO SCREEN 0.

      WHEN '&F15' OR '&F12'.
        LEAVE PROGRAM.

      WHEN 'ONLI'.

        go_alv->check_changed_data( ).

        IF gt_sel_field IS NOT INITIAL.

          CLEAR : lv_temp_count, lv_check_fields.

          LOOP AT gt_sel_field INTO gs_sel_field WHERE sel = 'X'.

            ADD 1 TO lv_temp_count.

            CLEAR : gs_sel_field.
          ENDLOOP.

        ENDIF.

        IF lv_temp_count > 20.
          MESSAGE 'Maximum only 20 fields can be selected, No. of fields selected :' && | | && lv_temp_count TYPE 'E'.

          CLEAR : lv_temp_count.
        ELSE.
          lv_check_fields = 'X'.
        ENDIF.

      WHEN '&NTE'.

      WHEN OTHERS.
    ENDCASE.

  ENDIF.

ENDMODULE.


*&---------------------------------------------------------------------*
*&      Form  PREP_DYNAMIC_SEL_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM prep_dynamic_sel_screen .

  CLEAR : ls_fields_init.

  REFRESH : lt_fields_init.

  LOOP AT gt_sel_field INTO gs_sel_field WHERE sel = abap_true.

    ls_fields_init-tablename = p_tab.
    ls_fields_init-fieldname = gs_sel_field-fieldname.
    ls_fields_init-type      = gs_sel_field-datatype.
    ls_fields_init-sign      = gs_sel_field-sign.
    ls_fields_init-decimals  = gs_sel_field-decimals.
    APPEND ls_fields_init TO lt_fields_init.

    CLEAR : ls_fields_init.
  ENDLOOP.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_fieldcat .

  IF lt_fieldcat IS INITIAL.

    CLEAR ls_fieldcat.
    ls_fieldcat-col_pos   = '1'.
    ls_fieldcat-checkbox  = 'X'.
    ls_fieldcat-edit      = 'X'.
    ls_fieldcat-fieldname = 'SEL'.
    ls_fieldcat-coltext   = 'Select'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-col_pos   = '2'.
    ls_fieldcat-fieldname = 'FIELD_LABEL'.
    ls_fieldcat-coltext   = 'Field Label'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-col_pos   = '3'.
    ls_fieldcat-fieldname = 'FIELDNAME'.
    ls_fieldcat-coltext   = 'Field Name'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-col_pos   = '4'.
    ls_fieldcat-fieldname = 'DATATYPE'.
    ls_fieldcat-coltext   = 'Type'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-col_pos   = '5'.
    ls_fieldcat-fieldname = 'LENGTH'.
    ls_fieldcat-coltext   = 'Length'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-col_pos   = '6'.                                      "Populating FieldCatalog
    ls_fieldcat-fieldname = 'KEYFLAG'.
    ls_fieldcat-coltext   = 'Key'.
    APPEND ls_fieldcat TO lt_fieldcat.

  ENDIF.

  IF rb_display = 'X' OR rb_update = 'X' OR rb_delete = 'X'.

    CLEAR : ls_layout.
    ls_layout-grid_title = 'Table Fields for Selection'.
    ls_layout-cwidth_opt = 'X'.

  ENDIF.

  IF rb_delete = 'X'.

    CLEAR : ls_layout_02.
    ls_layout_02-grid_title = 'Select Records for Deletion'.

***    ls_layout_02-sel_mode = 'D'.     "Best for Multiple Selections, But One wrong click resets it
    ls_layout_02-sel_mode   = 'A'.
***    ls_layout_02-no_rowmark = ' '.
    ls_layout_02-cwidth_opt = 'X'.

  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  EXCLUDE_STD_BUTTONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM exclude_std_buttons .

  REFRESH : lt_exclude.

  CLEAR : ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_cut.
  APPEND ls_exclude TO lt_exclude.

  CLEAR : ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy.
  APPEND ls_exclude TO lt_exclude.

  CLEAR : ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row.
  APPEND ls_exclude TO lt_exclude.

  CLEAR : ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_move_row.
  APPEND ls_exclude TO lt_exclude.

  CLEAR : ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste.
  APPEND ls_exclude TO lt_exclude.

  CLEAR : ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_undo.
  APPEND ls_exclude TO lt_exclude.

  IF rb_insert <> 'X'.

    CLEAR : ls_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
    APPEND ls_exclude TO lt_exclude.

    CLEAR : ls_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row.
    APPEND ls_exclude TO lt_exclude.

    CLEAR : ls_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
    APPEND ls_exclude TO lt_exclude.

    CLEAR : ls_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
    APPEND ls_exclude TO lt_exclude.

  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  INIT_FREE_SELECTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_free_selection .

  CLEAR : gv_solid.

  CALL FUNCTION 'FREE_SELECTIONS_INIT'
    EXPORTING
      kind                     = 'F'
    IMPORTING
      selection_id             = gv_solid
    TABLES
      fields_tab               = lt_fields_init
    EXCEPTIONS
      fields_incomplete        = 1
      fields_no_join           = 2
      field_not_found          = 3
      no_tables                = 4
      table_not_found          = 5
      expression_not_supported = 6
      incorrect_expression     = 7
      illegal_kind             = 8
      area_not_found           = 9
      inconsistent_area        = 10
      kind_f_no_fields_left    = 11
      kind_f_no_fields         = 12
      too_many_fields          = 13
      dup_field                = 14
      field_no_type            = 15
      field_ill_type           = 16
      dup_event_field          = 17
      node_not_in_ldb          = 18
      area_no_field            = 19
      OTHERS                   = 20.
  IF sy-subrc <> 0.
* Implement suitable error handling here

    MESSAGE 'Initial Free Selection Failed - Try Again' TYPE 'E'.

  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  CALL_FREE_SELECTION_DIALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM call_free_selection_dialog .

  CLEAR : gt_where, gt_ranges.

  CALL FUNCTION 'FREE_SELECTIONS_DIALOG'
    EXPORTING
      selection_id    = gv_solid
      title           = 'Dynamic Selection Screen'
      tree_visible    = ' ' " No Tree Required
***      as_window       = 'X'
***      as_subscreen    = 'X'
      status          = 1
    IMPORTING
      where_clauses   = gt_where
      field_ranges    = gt_ranges
***      expressions     = gt_expre
    TABLES
      fields_tab      = lt_fields_init
    EXCEPTIONS
      internal_error  = 1
      no_action       = 2
      selid_not_found = 3
      illegal_status  = 4
      OTHERS          = 5.
  IF sy-subrc <> 0.
* Implement suitable error handling here

    MESSAGE 'Selection Dialog Cancelled' TYPE 'I'.

    LEAVE TO SCREEN 0.

  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data .

  CREATE DATA lr_data TYPE STANDARD TABLE OF (p_tab).
  ASSIGN lr_data->* TO <lt_data>.

  DATA : ls_where_sql TYPE string,
         lt_where_sql TYPE TABLE OF string.


  IF gt_where IS NOT INITIAL.

    REFRESH : lt_where_sql.

    LOOP AT gt_where[ 1 ]-where_tab INTO DATA(ls_where).

      CLEAR : ls_where_sql.

      ls_where_sql = ls_where-line.
      APPEND ls_where_sql TO lt_where_sql.

      CLEAR : ls_where.

    ENDLOOP.

  ENDIF.


  IF lt_where_sql IS NOT INITIAL.

    SELECT *
    FROM (p_tab)
    INTO TABLE <lt_data>
    UP TO max_sel ROWS
    WHERE (lt_where_sql).
    IF sy-subrc = 0.
      "Do Nothing
    ENDIF.

  ELSE.

    MESSAGE 'Where-Clause is Initial' TYPE 'E'.

  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_alv .

  TRY.

      cl_salv_table=>factory(
       IMPORTING
         r_salv_table = lo_alv
         CHANGING
           t_table = <lt_data> ).


      lo_functions = lo_alv->get_functions( ).

      lo_functions->set_all( abap_true ).

      lo_layout = lo_alv->get_layout( ).

      lo_layout->set_key( value = VALUE salv_s_layout_key( report = sy-repid ) ).

      lo_layout->set_save_restriction( if_salv_c_layout=>restrict_none ).

      PERFORM update_fieldlabel_salv.

      lo_alv->display( ).

    CATCH cx_salv_msg INTO DATA(lox_salv).

      DATA(lv_msg) = lox_salv->get_longtext( ).

      WRITE : / 'Exception Caught : ', lv_msg.

  ENDTRY.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  UPDATE_FIELDLABEL_SALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_fieldlabel_salv .

  DATA : lv_temp_fieldtext TYPE scrtext_l.

  TRY.

      lo_columns = lo_alv->get_columns( ).

      LOOP AT lt_ddic INTO ls_ddic.

        CLEAR : lv_temp_fieldtext.

        IF ls_ddic-scrtext_s = ' ' AND ls_ddic-scrtext_m = ' ' AND
           ls_ddic-scrtext_l = ' ' AND ls_ddic-fieldtext <> ' ' .

          lo_column = lo_columns->get_column( ls_ddic-fieldname ).

          lv_temp_fieldtext = ls_ddic-fieldtext.

          lo_column->set_long_text( lv_temp_fieldtext ).

        ENDIF.

        CLEAR : ls_ddic.
      ENDLOOP.

    CATCH cx_salv_not_found INTO DATA(lox_excep).

      DATA(lv_temp_error) = lox_excep->get_longtext( ).

      MESSAGE lv_temp_error TYPE 'I'.

  ENDTRY.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS 'STATUS_0200'.
  SET TITLEBAR 'TB_0200' WITH text2.

  IF go_container IS INITIAL AND ok_code0200 IS INITIAL.

    "the below commented lines needs a custom-container in the screen
    CREATE OBJECT go_container
      EXPORTING
        container_name = 'CC_ALV_0200'.

    CREATE OBJECT go_alv
      EXPORTING
        i_parent = go_container.

***    " The below line doesn't need a custom-container, screen0 is a default dummy container
***    CREATE OBJECT go_alv
***      EXPORTING
***        i_parent = cl_gui_custom_container=>screen0.

    PERFORM read_ddic_data.

    PERFORM build_dynamic_fieldcat.

    PERFORM exclude_std_buttons.

    IF lv_check_insert = ' '.

      CREATE DATA lr_data TYPE TABLE OF (p_tab).
      ASSIGN lr_data->* TO <lt_data>.

      "A checking condition is added, to prevent creating lr_data object over and over
      lv_check_insert = 'X'.
    ENDIF.

    IF lv_check_insert = 'X'.

      CALL METHOD go_alv->set_table_for_first_display(
        EXPORTING
          it_toolbar_excluding = lt_exclude
***        i_structure_name = p_tab
          i_save               = 'X'
        CHANGING
          it_outtab            = <lt_data>
          it_fieldcatalog      = lt_fieldcat ).

    ENDIF.

  ENDIF.

ENDMODULE.


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  IF ok_code0200 IS NOT INITIAL.

    CASE ok_code0200.
      WHEN '&F03'.

        IF go_alv IS NOT INITIAL.
          go_alv->free( ).
        ENDIF.

        IF go_container IS NOT INITIAL.
          go_container->free( ).
        ENDIF.

        CLEAR : go_alv, go_container, lv_check_insert.

        LEAVE TO SCREEN 0.

      WHEN '&F15' OR '&F12'.

        IF go_alv IS NOT INITIAL.
          go_alv->free( ).
        ENDIF.

        IF go_container IS NOT INITIAL.
          go_container->free( ).
        ENDIF.

        CLEAR : go_alv, go_container, lv_check_insert.

        LEAVE PROGRAM.

      WHEN 'ONLI' OR 'SAVE'.

        go_alv->check_changed_data( ).
        IF sy-subrc = 0.

          PERFORM get_confirmation.

          " On Confirmation, insert new records into the DB table
          IF lv_answer = '1'.
            PERFORM insert_records_table.
          ENDIF.

        ENDIF.

        REFRESH : gt_sel_field.

    ENDCASE.

  ENDIF.

ENDMODULE.


*&---------------------------------------------------------------------*
*&      Form  BUILD_DYNAMIC_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_dynamic_fieldcat .

  REFRESH : lt_fieldcat.

  " To Make all the fields in the ALV as Editable - For Insert
  IF lt_fieldcat IS INITIAL.

    LOOP AT lt_ddic INTO ls_ddic.

      CLEAR ls_fieldcat.
      ls_fieldcat-col_pos   = sy-tabix.
      ls_fieldcat-edit      = 'X'.
      ls_fieldcat-fieldname = ls_ddic-fieldname.

      IF ls_ddic-scrtext_l <> ' '.
        ls_fieldcat-coltext   = ls_ddic-scrtext_l.
      ELSEIF ls_ddic-scrtext_m <> ' '.
        ls_fieldcat-coltext   = ls_ddic-scrtext_m.
      ELSEIF ls_ddic-scrtext_s <> ' '.
        ls_fieldcat-coltext = ls_ddic-scrtext_s.
      ELSEIF ls_ddic-fieldtext <> ' '.
        ls_fieldcat-coltext = ls_ddic-fieldtext.
      ELSE.
        ls_fieldcat-coltext = 'Undefined'.
      ENDIF.

      APPEND ls_fieldcat TO lt_fieldcat.

      CLEAR : ls_ddic.
    ENDLOOP.

    DELETE lt_fieldcat WHERE fieldname = 'MANDT'.

  ENDIF.

  " To make the key fields as non-editable - For Update
  IF rb_update = 'X' AND lt_fieldcat IS NOT INITIAL.

    LOOP AT lt_ddic INTO ls_ddic WHERE keyflag = 'X'.

      READ TABLE lt_fieldcat ASSIGNING FIELD-SYMBOL(<fs_fieldcat>)
      WITH KEY fieldname = ls_ddic-fieldname.
      IF sy-subrc = 0.
        <fs_fieldcat>-edit = ' '.
      ENDIF.

      CLEAR : ls_ddic.

    ENDLOOP.

  ENDIF.

  IF rb_delete = 'X' AND lt_fieldcat IS NOT INITIAL.

    LOOP AT lt_fieldcat ASSIGNING FIELD-SYMBOL(<fs_fieldcat_02>).

      <fs_fieldcat_02>-edit = ' '.

      CLEAR : ls_ddic.

    ENDLOOP.

  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  CALL_SCREEN_0100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM call_screen_0100 .

  IF lt_ddic IS NOT INITIAL.

    REFRESH : gt_sel_field.

    " MANDT field raise "field_not_found" exception in FM : FREE_SELECTIONS_INIT, -
    " -so the field excluded from the Dynamic Sekection Screen
    DELETE lt_ddic WHERE fieldname = 'MANDT'.

    LOOP AT lt_ddic INTO ls_ddic.

      CLEAR : gs_sel_field.

      IF ls_ddic-keyflag = 'X'.
        gs_sel_field-sel       = abap_true.
      ELSE.
        gs_sel_field-sel       = abap_false.
      ENDIF.

      gs_sel_field-fieldname   = ls_ddic-fieldname.
      gs_sel_field-field_label = ls_ddic-scrtext_l.
      gs_sel_field-datatype    = ls_ddic-datatype.
      gs_sel_field-sign        = ls_ddic-sign.
      gs_sel_field-length      = ls_ddic-leng.
      gs_sel_field-decimals    = ls_ddic-decimals.
      gs_sel_field-keyflag     = ls_ddic-keyflag.
      APPEND gs_sel_field TO gt_sel_field.

      CLEAR : ls_ddic.

    ENDLOOP.

    CALL SCREEN 0100.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0300 OUTPUT.
  SET PF-STATUS 'STATUS_0300'.
  SET TITLEBAR 'TB_0300' WITH text3.

  PERFORM alv_for_update.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0300 INPUT.

  IF ok_code0300 IS NOT INITIAL.

    CASE ok_code0300.
      WHEN '&F03'.
        LEAVE TO SCREEN 0.

      WHEN '&F15' OR '&F12'.
        LEAVE PROGRAM.

      WHEN 'ONLI' OR 'SAVE'..

        IF <lt_data> IS NOT INITIAL.

          lo_gui_alv->check_changed_data( ).
          IF sy-subrc = 0.

            PERFORM get_confirmation.

            " On Confirmation, update records from IT to DB table
            IF lv_answer = '1'.
              PERFORM update_records_table.
            ENDIF.

          ENDIF.

        ENDIF.

        REFRESH : gt_sel_field.

    ENDCASE.

  ENDIF.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Form  ALV_FOR_UPDATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM alv_for_update .

  TRY.

      IF lo_container IS INITIAL.

        CREATE OBJECT lo_container
          EXPORTING
            container_name = 'CC_ALV_0300'.

        CREATE OBJECT lo_gui_alv
          EXPORTING
            i_parent = lo_container.

        CALL METHOD lo_gui_alv->set_table_for_first_display(
          EXPORTING
            it_toolbar_excluding = lt_exclude
            i_save               = 'X'
          CHANGING
            it_outtab            = <lt_data>
            it_fieldcatalog      = lt_fieldcat ).

      ENDIF.

    CATCH cx_salv_msg INTO DATA(lox_salv).

      DATA(lv_msg) = lox_salv->get_longtext( ).

      WRITE : / 'Exception Caught : ', lv_msg.

  ENDTRY.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Module  STATUS_0400  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0400 OUTPUT.
  SET PF-STATUS 'STATUS_0400'.
  SET TITLEBAR 'TB_0200'.

  PERFORM alv_for_delete.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0400 INPUT.

  IF ok_code0400 IS NOT INITIAL.

    CASE ok_code0400.
      WHEN '&F03'.
        LEAVE TO SCREEN 0.

      WHEN '&F15' OR '&F12'.
        LEAVE PROGRAM.

      WHEN 'ONLI' OR 'SAVE'..

        PERFORM get_sel_records.

        IF <lt_data_del> IS NOT INITIAL.

          PERFORM get_confirmation.

          " On Confirmation, delete selected records from DB table
          IF lv_answer = '1'.
            PERFORM del_records_table.
          ENDIF.

        ELSE.

          MESSAGE |No Records Selected.| TYPE 'E'.

        ENDIF.

    ENDCASE.

  ENDIF.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Form  ALV_FOR_DELETE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM alv_for_delete .

  TRY.

      IF lo_container IS INITIAL.

        CREATE OBJECT lo_container
          EXPORTING
            container_name = 'CC_ALV_0400'. "Only Difference from FORM - ALV_FOR_UPDATE is the Custom Container called.

        CREATE OBJECT lo_gui_alv
          EXPORTING
            i_parent = lo_container.

        CALL METHOD lo_gui_alv->set_table_for_first_display(
          EXPORTING
            it_toolbar_excluding = lt_exclude
            i_save               = 'X'
            is_layout            = ls_layout_02
          CHANGING
            it_outtab            = <lt_data>
            it_fieldcatalog      = lt_fieldcat ).

      ENDIF.

    CATCH cx_salv_msg INTO DATA(lox_salv).

      DATA(lv_msg) = lox_salv->get_longtext( ).

      WRITE : / 'Exception Caught : ', lv_msg.

  ENDTRY.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_SEL_RECORDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_sel_records .

  IF <lt_data_del> IS NOT ASSIGNED.

    CREATE DATA lr_data_del TYPE TABLE OF (p_tab).
    ASSIGN lr_data_del->* TO <lt_data_del>.

  ENDIF.

  CALL METHOD lo_gui_alv->get_selected_rows
    IMPORTING
      et_index_rows = lt_selected_rows.


  IF lt_selected_rows IS NOT INITIAL.

    REFRESH : <lt_data_del>.

    LOOP AT lt_selected_rows INTO ls_selected_rows.

      ASSIGN <lt_data>[ ls_selected_rows-index ] TO FIELD-SYMBOL(<fs_data_temp>).
      IF sy-subrc = 0.

        APPEND <fs_data_temp> TO <lt_data_del>.

      ENDIF.

      CLEAR : ls_selected_rows.
    ENDLOOP.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  DEL_RECORDS_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM del_records_table.

  DELETE (p_tab) FROM TABLE @<lt_data_del>.
  IF sy-subrc = 0.
    COMMIT WORK.
    MESSAGE |Selected Records Deleted, No. of Records:| && | | && sy-dbcnt TYPE 'S'.

    PERFORM refresh_alv_grid_for_del.
  ELSE.
    ROLLBACK WORK.
    MESSAGE |Delete Operation Failed, No Records Deleted.| TYPE 'E'.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_CONFIRMATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_confirmation.

  CLEAR : lv_confirm_title, lv_confirmation, lv_answer.

  lv_confirm_title = |Table:| && |   | && p_tab.

  IF rb_insert = 'X'.

***    lv_confirm_title = 'Insert Records into Table:' && |   | && p_tab.

    lv_confirmation = 'Please Confirm, To Insert New Records.'.

  ELSEIF rb_update = 'X'.

***    lv_confirm_title = 'Update Records of Table:' && |   | && p_tab.

    lv_confirmation = 'Please Confirm, To Update Existing Records.'.

  ELSEIF rb_delete = 'X'.

***    lv_confirm_title = 'Delete Records of Table:' && |   | && p_tab.

    lv_confirmation = 'Please Confirm, To Delete Selected Records.'.

  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar       = lv_confirm_title
*     DIAGNOSE_OBJECT             = ' '
      text_question  = lv_confirmation
      text_button_1  = 'Yes'(y01)
*     ICON_BUTTON_1  = ' '
      text_button_2  = 'No'(y02)
*     ICON_BUTTON_2  = ' '
*     DEFAULT_BUTTON = '1'
*     DISPLAY_CANCEL_BUTTON       = 'X'
*     USERDEFINED_F1_HELP         = ' '
*     START_COLUMN   = 25
*     START_ROW      = 6
*     POPUP_TYPE     =
*     IV_QUICKINFO_BUTTON_1       = ' '
*     IV_QUICKINFO_BUTTON_2       = ' '
    IMPORTING
      answer         = lv_answer
* TABLES
*     PARAMETER      =
    EXCEPTIONS
      text_not_found = 1
      OTHERS         = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.
  ENDIF.

  CASE lv_answer.
    WHEN '1'.
      "Continue
    WHEN '2'.
      MESSAGE 'Action Cancelled By User' TYPE 'E'.
    WHEN 'A'.
      MESSAGE 'Action Cancelled By User' TYPE 'E'.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  REFRESH_ALV_GRID_FOR_DEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM refresh_alv_grid_for_del.

  IF lt_selected_rows IS NOT INITIAL.

    SORT lt_selected_rows BY index DESCENDING.

    LOOP AT lt_selected_rows INTO ls_selected_rows.

      DELETE <lt_data> INDEX ls_selected_rows-index.

      CLEAR : ls_selected_rows.
    ENDLOOP.

    CALL METHOD lo_gui_alv->refresh_table_display
      EXCEPTIONS
        finished = 1
        OTHERS   = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.
    ENDIF.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  INSERT_RECORDS_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_records_table .

  INSERT (p_tab) FROM TABLE @<lt_data> ACCEPTING DUPLICATE KEYS.
  IF sy-subrc = 0.
    COMMIT WORK.
    MESSAGE 'New Records Inserted, No. of Records:' && | | && sy-dbcnt TYPE 'S'.
  ELSEIF sy-subrc = 4.
    COMMIT WORK.
    MESSAGE 'New Records Inserted, No. of Records:' && | | && sy-dbcnt && ', Existing Records Skipped.' TYPE 'S'.
  ELSE.
    ROLLBACK WORK.
    MESSAGE |Insert Operation Failed, No Records Inserted.| TYPE 'E'.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UPDATE_RECORDS_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_records_table .

  MODIFY (p_tab) FROM TABLE @<lt_data>.
  IF sy-subrc = 0.

    COMMIT WORK.
    MESSAGE |All the changes Updated, No. of Records:| && | | && sy-dbcnt TYPE 'S'.

  ELSEIF sy-subrc = 4.

    COMMIT WORK.
    MESSAGE |Not All the changes Updated, No. of Records:| && | | && sy-dbcnt TYPE 'S'.

  ELSE.

    ROLLBACK WORK.
    MESSAGE |Update Operation Failed, No Records Updated.| TYPE 'E'.

  ENDIF.

ENDFORM.
