" Interface: ZIF_PP_CONF_TYPES
" ----------------------------
" Shared type definitions for PP confirmation REST API

INTERFACE zif_pp_conf_types PUBLIC.

  TYPES: BEGIN OF ts_confirmation_item,
           order_number      TYPE aufnr,         " Production order
           operation_number  TYPE vornr,         " Operation
           suboperation      TYPE uvorn,         " Optional
           plant             TYPE werks_d,
           work_center       TYPE arbpl,
           posting_date      TYPE budat,
           yield_quantity    TYPE bdmng,
           scrap_quantity    TYPE bdmng,
           unit_of_measure   TYPE meins,
           confirmed_by      TYPE syuname,
           user_reference    TYPE char40,        " External ref / mobile id
           confirmation_text TYPE char80,
         END OF ts_confirmation_item.

  TYPES tt_confirmation_list TYPE STANDARD TABLE OF ts_confirmation_item
                              WITH DEFAULT KEY.

  TYPES: BEGIN OF ts_api_result_item,
           order_number      TYPE aufnr,
           operation_number  TYPE vornr,
           status            TYPE char10,       " e.g. 'SUCCESS' / 'ERROR'
           message           TYPE string,
           confirmation_id   TYPE char20,       " BAPI confirmation number
         END OF ts_api_result_item.

  TYPES tt_api_result_list TYPE STANDARD TABLE OF ts_api_result_item
                            WITH DEFAULT KEY.

  TYPES: BEGIN OF ts_api_response,
           overall_status TYPE char10,          " 'OK' / 'PARTIAL' / 'FAILED'
           results        TYPE tt_api_result_list,
         END OF ts_api_response.

ENDINTERFACE.
