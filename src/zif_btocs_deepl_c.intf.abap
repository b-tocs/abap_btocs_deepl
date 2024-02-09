interface ZIF_BTOCS_DEEPL_C
  public .


* ============== version information
  constants VERSION type STRING value 'V20240209' ##NO_TEXT.
  constants RELEASE type STRING value '0.2.0' ##NO_TEXT.
  constants HOMEPAGE type STRING value 'https://b-tocs.org' ##NO_TEXT.
  constants REPOSITORY type STRING value 'https://github.com/b-tocs/abap_btocs_deepl' ##NO_TEXT.
  constants AUTHOR type STRING value 'mdjoerg@b-tocs.org' ##NO_TEXT.
  constants DEPENDING type STRING value 'https://github.com/b-tocs/abap_btocs_core:0.3.1' ##NO_TEXT.
  constants:
* ============== api path
    BEGIN OF api_path,
      translate TYPE string VALUE '/v2/translate',
    END OF api_path .
  constants:
* ============== json keys
    BEGIN OF c_json_key,
      translations             TYPE string VALUE 'translations',
      detected_source_language TYPE string VALUE 'detected_source_language',
      text                     TYPE string VALUE 'text',
    END OF c_json_key .
endinterface.
