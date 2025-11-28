" Class: ZCL_PP_CONF_HTTP_HANDLER
" -------------------------------
" HTTP entry point for PP confirmation REST API

CLASS zcl_pp_conf_http_handler DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_http_extension.

  PRIVATE SECTION.
    METHODS handle_post
      IMPORTING
        io_request  TYPE REF TO if_http_request
        io_response TYPE REF TO if_http_response.

    METHODS set_json_response
      IMPORTING
        io_response TYPE REF TO if_http_response
        iv_body     TYPE string
        iv_status   TYPE i.

ENDCLASS.

CLASS zcl_pp_conf_http_handler IMPLEMENTATION.

  METHOD if_http_extension~handle_request.
    DATA lo_request  TYPE REF TO if_http_request.
    DATA lo_response TYPE REF TO if_http_response.

    lo_request  = server->request.
    lo_response = server->response.

    CASE lo_request->get_header_field( '~request_method' ).
      WHEN 'POST'.
        handle_post( lo_request  = lo_request
                     io_response = lo_response ).
      WHEN OTHERS.
        set_json_response(
          io_response = lo_response
          iv_body     = '{"error":"Only POST is supported"}'
          iv_status   = 405
        ).
    ENDCASE.
  ENDMETHOD.

  METHOD handle_post.
    DATA(lv_body) = io_request->get_cdata( ).

    TRY.
        DATA(lo_app) = NEW zcl_pp_conf_application( ).

        DATA(ls_response) = lo_app->process_request(
                              iv_json = lv_body ).

        DATA(lv_json_response) = zcl_pp_conf_json_helper=>build_response_json(
                                   is_response = ls_response ).

        set_json_response(
          io_response = io_response
          iv_body     = lv_json_response
          iv_status   = 200
        ).

      CATCH zcx_pp_conf_error INTO DATA(lx_api).
        DATA(lv_error_json) =
          /ui2/cl_json=>serialize(
            data = VALUE #( error = lx_api->get_text( ) )
            pretty_name = /ui2/cl_json=>pretty_mode-camel_case
          ).

        set_json_response(
          io_response = io_response
          iv_body     = lv_error_json
          iv_status   = 400
        ).

      CATCH cx_root INTO DATA(lx_unexp).
        DATA(lv_unexp_json) =
          /ui2/cl_json=>serialize(
            data = VALUE #( error = lx_unexp->get_text( ) )
            pretty_name = /ui2/cl_json=>pretty_mode-camel_case
          ).

        set_json_response(
          io_response = io_response
          iv_body     = lv_unexp_json
          iv_status   = 500
        ).
    ENDTRY.
  ENDMETHOD.

  METHOD set_json_response.
    io_response->set_header_field(
      name  = '~status_code'
      value = iv_status
    ).
    io_response->set_header_field(
      name  = 'Content-Type'
      value = 'application/json; charset=utf-8'
    ).
    io_response->set_cdata( iv_body ).
  ENDMETHOD.

ENDCLASS.
