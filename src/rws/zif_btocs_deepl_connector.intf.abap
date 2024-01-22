INTERFACE zif_btocs_deepl_connector
  PUBLIC .

  INTERFACES zif_btocs_rws_connector .
  INTERFACES zif_btocs_util_base .

  ALIASES destroy
    FOR zif_btocs_rws_connector~destroy .
  ALIASES execute
    FOR zif_btocs_rws_connector~execute .
  ALIASES get_client
    FOR zif_btocs_rws_connector~get_client .
  ALIASES get_logger
    FOR zif_btocs_rws_connector~get_logger .
  ALIASES is_initialized
    FOR zif_btocs_rws_connector~is_initialized .
  ALIASES is_logger_external
    FOR zif_btocs_rws_connector~is_logger_external .
  ALIASES new_request
    FOR zif_btocs_rws_connector~new_request .
  ALIASES new_response
    FOR zif_btocs_rws_connector~new_response .
  ALIASES set_endpoint
    FOR zif_btocs_rws_connector~set_endpoint .
  ALIASES set_logger
    FOR zif_btocs_rws_connector~set_logger .


  METHODS api_translate
    IMPORTING
      !is_params         TYPE zbtocs_deepl_s_translate_par
      !iv_parse          TYPE abap_bool
    EXPORTING
      !es_result         TYPE zbtocs_deepl_s_translate_par
    RETURNING
      VALUE(ro_response) TYPE REF TO zif_btocs_rws_response .

ENDINTERFACE.
