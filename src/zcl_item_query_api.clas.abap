CLASS zcl_item_query_api DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_item_query_api IMPLEMENTATION.

  METHOD if_rap_query_provider~select.
    DATA lt_items TYPE STANDARD TABLE OF zce_voos_items. " Sua Custom Entity de Item

    " 1. Capturar Filtros (O SAP vai mandar automaticamente os IDs do Pai aqui!)
    TRY.
        DATA(lv_sql_filter) = io_request->get_filter( )->get_as_sql_string( ).
      CATCH cx_rap_query_filter_no_range.
        lv_sql_filter = ''.
    ENDTRY.

    " 2. Ajustar nomes para o banco (Mapeando os campos do Item)
    REPLACE ALL OCCURRENCES OF 'CARRIERID'    IN lv_sql_filter WITH 'carrier_id'.
    REPLACE ALL OCCURRENCES OF 'CONNECTIONID' IN lv_sql_filter WITH 'connection_id'.
    REPLACE ALL OCCURRENCES OF 'FLIGHTDATE'   IN lv_sql_filter WITH 'flight_date'.

    " 3. Buscar os dados na tabela de Booking (Itens)
    IF io_request->is_data_requested( ) = abap_true.
      SELECT carrier_id    AS CarrierId,
             connection_id AS ConnectionId,
             flight_date   AS FlightDate,
             booking_id    AS PassengerId, " Usando ID da reserva como exemplo
             customer_id   AS CustomerId
        FROM /dmo/booking
        WHERE (lv_sql_filter) " Aqui o filtro garante que só venham itens desse voo específico
        INTO CORRESPONDING FIELDS OF TABLE @lt_items.

      " 4. O COMANDO OBRIGATÓRIO (O que evita o DUMP)
      io_response->set_data( lt_items ).
    ENDIF.

    " 5. Contagem (Também obrigatório se solicitado)
    IF io_request->is_total_numb_of_rec_requested( ) = abap_true.
      io_response->set_total_number_of_records( lines( lt_items ) ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
