" Class: ZCL_PP_CONF_JSON_HELPER
" ------------------------------
" JSON <-> ABAP mapping for PP confirmation API

CLASS zcl_pp_conf_json_helper DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_pp_conf_types.

    CLASS-METHODS parse_request
      IMPORTING
        iv_json          TYPE string
      EXPORTING
        et_confirmations TYPE zif_pp_conf_types~tt_confirmation_list
      RAISING
        zcx_pp_conf_error.

    CLASS-METHODS build_response_json
      IMPORTING
        is_response TYPE zif_pp_conf_types~ts_api_response
      RETURNING
        VALUE(rv_json) TYPE string.

ENDCLASS.

CLASS zcl_pp_conf_json_helper IMPLEMENTATION.

  METHOD parse_request.
    DATA: ls_wrapper TYPE STRUCTURE (
             BEGIN OF s,
               confirmations TYPE zif_pp_conf_types~tt_confirmation_list,
             END OF s ).

    TRY.
        /ui2/cl_json=>deserialize(
          EXPORTING
            json             = iv_json
          CHANGING
            data             = ls_wrapper
        ).
      CATCH cx_root INTO DATA(lx_json).
        RAISE EXCEPTION TYPE zcx_pp_conf_error
          EXPORTING
            iv_message = |Invalid JSON payload: { lx_json->get_text( ) }|.
    ENDTRY.

    IF ls_wrapper-confirmations IS INITIAL.
      RAISE EXCEPTION TYPE zcx_pp_conf_error
        EXPORTING
          iv_message = 'No confirmations provided in JSON payload.'.
    ENDIF.

    et_confirmations = ls_wrapper-confirmations.
  ENDMETHOD.

  METHOD build_response_json.
    DATA ls_wrapper TYPE STRUCTURE (
                        BEGIN OF s,
                          response TYPE zif_pp_conf_types~ts_api_response,
                        END OF s ).

    ls_wrapper-response = is_response.

    rv_json = /ui2/cl_json=>serialize(
                data        = ls_wrapper
                pretty_name = /ui2/cl_json=>pretty_mode-camel_case
              ).
  ENDMETHOD.

ENDCLASS.
