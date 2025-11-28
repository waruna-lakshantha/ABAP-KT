" Class: ZCL_PP_CONF_APPLICATION
" ------------------------------
" High-level application service used by HTTP handler

CLASS zcl_pp_conf_application DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_pp_conf_types.

    METHODS process_request
      IMPORTING
        iv_json      TYPE string
      RETURNING
        VALUE(rs_response) TYPE zif_pp_conf_types~ts_api_response
      RAISING
        zcx_pp_conf_error.

  PRIVATE SECTION.
    METHODS validate_items
      IMPORTING
        it_confirmations TYPE zif_pp_conf_types~tt_confirmation_list
      RAISING
        zcx_pp_conf_error.

ENDCLASS.

CLASS zcl_pp_conf_application IMPLEMENTATION.

  METHOD process_request.
    DATA lt_items   TYPE zif_pp_conf_types~tt_confirmation_list.
    DATA lt_results TYPE zif_pp_conf_types~tt_api_result_list.

    " 1) JSON -> ABAP
    zcl_pp_conf_json_helper=>parse_request(
      EXPORTING
        iv_json          = iv_json
      IMPORTING
        et_confirmations = lt_items
    ).

    " 2) Basic validation
    validate_items( lt_items ).

    " 3) Call BAPI adapter
    DATA(lo_bapi) = NEW zcl_pp_conf_bapi_adapter( ).

    lo_bapi->post_confirmations(
      EXPORTING
        it_confirmations = lt_items
      IMPORTING
        et_results       = lt_results
    ).

    " 4) Build overall status
    rs_response-results = lt_results.

    DATA(lv_error_found) TYPE abap_bool VALUE abap_false.
    DATA(lv_success_found) TYPE abap_bool VALUE abap_false.

    LOOP AT lt_results INTO DATA(ls_result).
      IF ls_result-status = 'ERROR'.
        lv_error_found = abap_true.
      ELSEIF ls_result-status = 'SUCCESS'.
        lv_success_found = abap_true.
      ENDIF.
    ENDLOOP.

    IF lv_error_found = abap_true AND lv_success_found = abap_true.
      rs_response-overall_status = 'PARTIAL'.
    ELSEIF lv_error_found = abap_true.
      rs_response-overall_status = 'FAILED'.
    ELSE.
      rs_response-overall_status = 'OK'.
    ENDIF.

  ENDMETHOD.

  METHOD validate_items.
    LOOP AT it_confirmations INTO DATA(ls_item).

      IF ls_item-order_number IS INITIAL
         OR ls_item-operation_number IS INITIAL
         OR ls_item-plant IS INITIAL.
        RAISE EXCEPTION TYPE zcx_pp_conf_error
          EXPORTING
            iv_message = |Mandatory fields missing for order { ls_item-order_number } operation { ls_item-operation_number }|.
      ENDIF.

      IF ls_item-yield_quantity IS INITIAL AND ls_item-scrap_quantity IS INITIAL.
        RAISE EXCEPTION TYPE zcx_pp_conf_error
          EXPORTING
            iv_message = |At least yield or scrap quantity must be provided for order { ls_item-order_number }|.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
