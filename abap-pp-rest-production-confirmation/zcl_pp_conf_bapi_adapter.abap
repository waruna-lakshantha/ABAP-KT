" Class: ZCL_PP_CONF_BAPI_ADAPTER
" -------------------------------
" Wraps BAPI calls for PP order confirmation

CLASS zcl_pp_conf_bapi_adapter DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_pp_conf_types.

    METHODS post_confirmations
      IMPORTING
        it_confirmations TYPE zif_pp_conf_types~tt_confirmation_list
      EXPORTING
        et_results       TYPE zif_pp_conf_types~tt_api_result_list
      RAISING
        zcx_pp_conf_error.

  PRIVATE SECTION.
    METHODS map_item_to_bapi
      IMPORTING
        is_item   TYPE zif_pp_conf_types~ts_confirmation_item
      EXPORTING
        es_header TYPE bapi_pp_conf_hdr
        es_goodsm TYPE bapi_pp_conf_goodsmov
        es_retlog TYPE bapi_pp_conf_log.

ENDCLASS.

CLASS zcl_pp_conf_bapi_adapter IMPLEMENTATION.

  METHOD post_confirmations.
    DATA: ls_header TYPE bapi_pp_conf_hdr,
          ls_goodsm TYPE bapi_pp_conf_goodsmov,
          ls_retlog TYPE bapi_pp_conf_log,
          lt_return TYPE TABLE OF bapiret2,
          ls_return TYPE bapiret2,
          lt_results TYPE zif_pp_conf_types~tt_api_result_list,
          ls_result  TYPE zif_pp_conf_types~ts_api_result_item.

    LOOP AT it_confirmations INTO DATA(ls_item).

      CLEAR: ls_header, ls_goodsm, ls_retlog, lt_return[], ls_result.

      " Map our DTO into BAPI structures
      me->map_item_to_bapi(
        EXPORTING
          is_item   = ls_item
        IMPORTING
          es_header = ls_header
          es_goodsm = ls_goodsm
          es_retlog = ls_retlog
      ).

      CALL FUNCTION 'BAPI_PRODORDCONF_CREATE_HDR'
        EXPORTING
          header  = ls_header
        IMPORTING
          log     = ls_retlog
        TABLES
          return  = lt_return
          goodsmovements = ls_goodsm.

      READ TABLE lt_return INTO ls_return WITH KEY type = 'E' TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        " Error
        ls_result-order_number     = ls_item-order_number.
        ls_result-operation_number = ls_item-operation_number.
        ls_result-status           = 'ERROR'.

        DATA(lv_msg) = ''.
        LOOP AT lt_return INTO ls_return.
          CONCATENATE lv_msg ls_return-message INTO lv_msg SEPARATED BY space.
        ENDLOOP.
        ls_result-message = lv_msg.
      ELSE.
        " No error -> commit
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.

        ls_result-order_number     = ls_item-order_number.
        ls_result-operation_number = ls_item-operation_number.
        ls_result-status           = 'SUCCESS'.
        ls_result-message          = 'Confirmation posted successfully'.
        ls_result-confirmation_id  = ls_retlog-conf_no.
      ENDIF.

      APPEND ls_result TO lt_results.

    ENDLOOP.

    et_results = lt_results.
  ENDMETHOD.

  METHOD map_item_to_bapi.
    CLEAR: es_header, es_goodsm, es_retlog.

    es_header-orderid  = is_item-order_number.
    es_header-conf_qty = is_item-yield_quantity.
    es_header-conf_scrap_qty = is_item-scrap_quantity.
    es_header-conf_unit = is_item-unit_of_measure.
    es_header-postg_date = is_item-posting_date.
    es_header-plant     = is_item-plant.
    es_header-work_cntr = is_item-work_center.
    es_header-conf_text = is_item-confirmation_text.
    es_header-username  = is_item-confirmed_by.

    " Example: if you need goods movement info
    es_goodsm-move_type = '101'.
    es_goodsm-entry_qnt = is_item-yield_quantity.
    es_goodsm-entry_uom = is_item-unit_of_measure.

    " es_retlog is returned by BAPI; you can leave it as initial here

  ENDMETHOD.

ENDCLASS.
