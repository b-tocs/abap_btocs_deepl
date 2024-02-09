CLASS zcl_btocs_deepl_connector DEFINITION
  PUBLIC
  INHERITING FROM zcl_btocs_rws_connector
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_btocs_deepl_c .
    INTERFACES zif_btocs_deepl_connector .

    CLASS-METHODS create
      RETURNING
        VALUE(ro_instance) TYPE REF TO zif_btocs_deepl_connector .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_BTOCS_DEEPL_CONNECTOR IMPLEMENTATION.


  METHOD create.
    ro_instance ?= zcl_btocs_factory=>create_instance( 'ZIF_BTOCS_DEEPL_CONNECTOR' ).
  ENDMETHOD.


  METHOD zif_btocs_deepl_connector~api_translate.

* ========== init
    DATA(ls_params) = is_params.
    ro_response     = zcl_btocs_factory=>create_web_service_response( ).
    ro_response->set_logger( get_logger( ) ).


* =========== checks and preparations
    IF zif_btocs_deepl_connector~is_initialized( ) EQ abap_false.
      ro_response->set_reason( |connector is not initialized| ).
      RETURN.
    ENDIF.

    IF ls_params-text IS INITIAL
      AND ls_params-text_tab[] IS INITIAL.
      ro_response->set_reason( |text to translate is missing| ).
      RETURN.
    ENDIF.

    IF ls_params-text IS NOT INITIAL
      AND ls_params-text_tab[] IS NOT INITIAL.
      ro_response->set_reason( |only one option is available text or text table| ).
      RETURN.
    ENDIF.

    IF ls_params-target IS INITIAL.
      ro_response->set_reason( |target language is missing| ).
      RETURN.
    ENDIF.

    IF ls_params-source IS INITIAL.
      ls_params-source = 'auto'.
      get_logger( )->warning( |source language is missing. try auto detect mode| ).
    ENDIF.

* =========== prepare text
    DATA(lv_sep) = ||.
    IF ls_params-text IS NOT INITIAL.
      DATA(lr_util_text) = zcl_btocs_factory=>create_text_util( ).
      lv_sep = lr_util_text->detect_line_separator( ls_params-text ).
      IF lv_sep IS INITIAL.
        APPEND ls_params-text TO ls_params-text_tab.
      ELSE.
        SPLIT ls_params-text AT lv_sep
          INTO TABLE ls_params-text_tab.
      ENDIF.
    ENDIF.


* =========== get client and prepare call
    DATA(lv_api_key) = COND #( WHEN ls_params-api_key IS NOT INITIAL
                               THEN ls_params-api_key
                               ELSE zif_btocs_deepl_connector~get_client( )->get_api_key( ) ).


* =========== fill form based params
    DATA(lo_request) = zif_btocs_deepl_connector~new_request( ). " from current client
    lo_request->set_form_type_urlencoded( ).

    IF lv_api_key IS NOT INITIAL.

      lo_request->add_form_field(
        iv_name = 'auth_key'
        iv_value = lv_api_key
      ).
    ENDIF.

    lo_request->add_form_field(
      iv_name = 'source_lang'
      iv_value = ls_params-source
    ).

    lo_request->add_form_field(
      iv_name = 'target_lang'
      iv_value = ls_params-target
    ).

    LOOP AT ls_params-text_tab ASSIGNING FIELD-SYMBOL(<lv_text>).
      lo_request->add_form_field(
        iv_name = 'text'
        iv_value = <lv_text>
      ).
    ENDLOOP.

* ============ execute via api path
    DATA(lo_response) = zif_btocs_deepl_connector~new_response( ).
    ro_response ?= zif_btocs_deepl_connector~execute(
     iv_api_path = zif_btocs_deepl_c=>api_path-translate
     io_response = lo_response
    ).

* ----- parse?
    IF ro_response IS NOT INITIAL
      AND ro_response->is_json_object( ) EQ abap_true
      AND iv_parse EQ abap_true.
      es_result = zif_btocs_deepl_connector~parse_translate(
        io_response  = ro_response
        iv_separator = lv_sep ).
    ENDIF.

  ENDMETHOD.


  METHOD zif_btocs_deepl_connector~parse_translate.
    TRY.
* --- get result and check for right format
        DATA(lo_parsed) = io_response->get_values_from_parsed_json( ).
        DATA(lo_answer)   = lo_parsed->get_structure_value( ).
        IF lo_answer IS NOT INITIAL.
          DATA(lo_translations) = lo_answer->get( zif_btocs_deepl_c=>c_json_key-translations ).
          IF lo_translations IS NOT INITIAL.
* --- get the array for translations
            DATA(lo_array) = lo_translations->get_array_value( ).
            DATA(lv_count) = lo_array->count( ).
* --- loop all array items and get details from structure object
            DO lv_count TIMES.
              DATA(lv_index) = sy-index.
              DATA(lo_entry)    = lo_array->get( lv_index ).
              DATA(lo_line)     = lo_entry->get_structure_value( ).
              DATA(lv_det_lang) = lo_line->get( zif_btocs_deepl_c=>c_json_key-detected_source_language )->get_string( ).
              DATA(lv_text)     = lo_line->get( zif_btocs_deepl_c=>c_json_key-text )->get_string( ).
* --- prepare answer
              APPEND lv_text TO rs_result-text_tab.
              IF rs_result-text IS INITIAL.
                rs_result-text = lv_text.
              ELSE.
                rs_result-text = |{ rs_result-text }{ iv_separator }{ lv_text }|.
              ENDIF.
              rs_result-detected_language = lv_det_lang.
            ENDDO.
          ENDIF.
        ENDIF.
      CATCH cx_root INTO DATA(lx_exc).
        DATA(lv_error) = lx_exc->get_text( ).
        get_logger( )->error( lv_error ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
