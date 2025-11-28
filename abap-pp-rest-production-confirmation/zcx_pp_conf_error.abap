" Exception Class: ZCX_PP_CONF_ERROR
" ----------------------------------
" Use for JSON errors, validation errors, BAPI failures, etc.

CLASS zcx_pp_conf_error DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        !iv_message TYPE string.

ENDCLASS.

CLASS zcx_pp_conf_error IMPLEMENTATION.

  METHOD constructor.
    CALL METHOD super->constructor
      EXPORTING
        textid = super->textid
        previous = previous.

    me->set_text( iv_message ).
  ENDMETHOD.

ENDCLASS.
