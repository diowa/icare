$(document).on 'change', '#itinerary_round_trip', ->
  status = $(this).prop 'checked'
  $('select[id^="itinerary_return_date"]').prop 'disabled', !status
