@ObjectModel.query.implementedBy: 'ABAP:ZCL_MINHA_QUERY_API'
define custom entity ZCE_VOOS_ITEMS
{
  key CarrierId    : /dmo/carrier_id;
  key ConnectionId : /dmo/connection_id;
  key FlightDate   : /dmo/flight_date;
  key PassengerId  : /dmo/customer_id;
      CustomerId   : /dmo/customer_id;

      _Parent      : association to parent ZCE_VOOS_API on  $projection.CarrierId    = _Parent.CarrierId
                                                        and $projection.ConnectionId = _Parent.ConnectionId
                                                        and $projection.FlightDate   = _Parent.FlightDate;
}
