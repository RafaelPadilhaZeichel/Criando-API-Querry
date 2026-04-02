@EndUserText.label: 'Query API - Tabela Standard de Voos'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_MINHA_QUERY_API'
define root custom entity ZCE_VOOS_API
{
  key CarrierId    : /dmo/carrier_id;
  key ConnectionId : /dmo/connection_id;
  key FlightDate   : /dmo/flight_date;
      @Semantics.amount.currencyCode: 'Currency'
      Price        : /dmo/flight_price;
      Currency     : /dmo/currency_code;
      
      ItemsOut : composition [0..*] of ZCE_VOOS_ITEMS;
}
