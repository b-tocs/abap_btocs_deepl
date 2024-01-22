INTERFACE zif_btocs_deepl_c
  PUBLIC .

* ============== version information
  CONSTANTS version TYPE string VALUE 'V20240122' ##NO_TEXT.
  CONSTANTS release TYPE string VALUE '0.1.0' ##NO_TEXT.
  CONSTANTS homepage TYPE string VALUE 'https://b-tocs.org' ##NO_TEXT.
  CONSTANTS repository TYPE string VALUE 'https://github.com/b-tocs/abap_btocs_deepl' ##NO_TEXT.
  CONSTANTS author TYPE string VALUE 'mdjoerg@b-tocs.org' ##NO_TEXT.
  CONSTANTS depending TYPE string VALUE 'https://github.com/b-tocs/abap_btocs_core:0.3.1' ##NO_TEXT.

* ============== api path
  CONSTANTS:
    BEGIN OF api_path,
      translate TYPE string VALUE '/v2/translate',
    END OF api_path .

ENDINTERFACE.
