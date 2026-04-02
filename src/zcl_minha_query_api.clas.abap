CLASS zcl_minha_query_api DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_minha_query_api IMPLEMENTATION.

  METHOD if_rap_query_provider~select.

    " 1. Identifica qual entidade está sendo chamada
    DATA(lv_entity_id) = io_request->get_entity_id( ).

    " 2. Recupera Filtros e Paginação (comuns a ambas)
    TRY.
        DATA(lv_sql_filter) = io_request->get_filter( )->get_as_sql_string( ).
      CATCH cx_rap_query_filter_no_range.
        lv_sql_filter = ''.
    ENDTRY.

    DATA(lv_top)  = io_request->get_paging( )->get_page_size( ).
    DATA(lv_skip) = io_request->get_paging( )->get_offset( ).

    IF lv_top = if_rap_query_paging=>page_size_unlimited.
      lv_top = 100.
    ENDIF.

    " 3. O "Dispatcher" (Direcionador)
    CASE lv_entity_id.

        " ==========================================================
        " CASO 1: CABEÇALHO (Pai)
        " ==========================================================
      WHEN 'ZCE_VOOS_API'.
        DATA lt_header TYPE STANDARD TABLE OF zce_voos_api.

        REPLACE ALL OCCURRENCES OF 'CURRENCY'  IN lv_sql_filter WITH 'currency_code'.
        REPLACE ALL OCCURRENCES OF 'PRICE'     IN lv_sql_filter WITH 'price'.
        REPLACE ALL OCCURRENCES OF 'CARRIERID' IN lv_sql_filter WITH 'carrier_id'.

        IF io_request->is_data_requested( ) = abap_true.
          SELECT carrier_id    AS CarrierId,
                 connection_id AS ConnectionId,
                 flight_date   AS FlightDate,
                 price         AS Price,
                 currency_code AS Currency
            FROM /dmo/flight
            WHERE (lv_sql_filter)
            ORDER BY carrier_id, connection_id
            INTO CORRESPONDING FIELDS OF TABLE @lt_header
            UP TO @lv_top ROWS OFFSET @lv_skip.

          io_response->set_data( lt_header ).
        ENDIF.

        IF io_request->is_total_numb_of_rec_requested( ) = abap_true.
          SELECT COUNT( * ) FROM /dmo/flight WHERE (lv_sql_filter) INTO @DATA(lv_count_h).
          io_response->set_total_number_of_records( lv_count_h ).
        ENDIF.

        " ==========================================================
        " CASO 2: ITENS (Filho)
        " ==========================================================
      WHEN 'ZCE_VOOS_ITEMS'.
        DATA lt_items TYPE STANDARD TABLE OF zce_voos_items.

        REPLACE ALL OCCURRENCES OF 'CARRIERID'    IN lv_sql_filter WITH 'carrier_id'.
        REPLACE ALL OCCURRENCES OF 'CONNECTIONID' IN lv_sql_filter WITH 'connection_id'.
        REPLACE ALL OCCURRENCES OF 'FLIGHTDATE'   IN lv_sql_filter WITH 'flight_date'.
        REPLACE ALL OCCURRENCES OF 'CUSTOMERID'   IN lv_sql_filter WITH 'customer_id'.

        IF io_request->is_data_requested( ) = abap_true.
          SELECT carrier_id    AS CarrierId,
                 connection_id AS ConnectionId,
                 flight_date   AS FlightDate,
                 booking_id    AS PassengerId,
                 customer_id   AS CustomerId
            FROM /dmo/booking
            WHERE (lv_sql_filter)
            INTO CORRESPONDING FIELDS OF TABLE @lt_items.

          io_response->set_data( lt_items ).
        ENDIF.

        IF io_request->is_total_numb_of_rec_requested( ) = abap_true.
          io_response->set_total_number_of_records( lines( lt_items ) ).
        ENDIF.

    ENDCASE.

  ENDMETHOD.

ENDCLASS.
