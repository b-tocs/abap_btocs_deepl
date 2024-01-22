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

    IF ls_params-target IS INITIAL.
      ro_response->set_reason( |target language is missing| ).
      RETURN.
    ENDIF.

    IF ls_params-source IS INITIAL.
      ls_params-source = 'auto'.
      get_logger( )->warning( |source language is missing. try auto detect mode| ).
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

    lo_request->add_form_field(
      iv_name = 'text'
      iv_value = ls_params-text
    ).

* ============ execute via api path
    DATA(lo_response) = zif_btocs_deepl_connector~new_response( ).
    ro_response ?= zif_btocs_deepl_connector~execute(
     iv_api_path = zif_btocs_deepl_c=>api_path-translate
     io_response = lo_response
    ).

* ----- parse?
*    IF ro_response IS NOT INITIAL
*      AND ro_response->is_json_object( ) EQ abap_true
*      AND iv_parse EQ abap_true.
*      DATA(lo_parsed) = ro_response->get_values_from_parsed_json( ).
*      DATA(lo_answer)   = lo_parsed->get_structure_value( ).
*      IF lo_answer IS NOT INITIAL.
*        ev_translated_text = lo_answer->get_string( zif_btocs_c=>c_json_key-translated_text ).
*      ENDIF.
*    ENDIF.

  ENDMETHOD.
ENDCLASS.
