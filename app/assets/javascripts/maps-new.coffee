###
Itineraries
  people in the car: bool
  visibility: friends, friends of friends, public
  daily: think about it
###

# From https://google-developers.appspot.com/maps/customize_ae458c7692ac994187feb6f58834b6af.frame

window.icare = window.icare || {}
icare = window.icare

setItinerary = (route) ->
  # NOTE server side is limited to 2.500 requests per day, so we create routes on client

  # Set visible fields at first
  $('#from-helper, #itinerary-preview-from').text route.legs[0].start_address
  $('#to-helper, #itinerary-preview-to').text route.legs[0].end_address
  $('#distance').text route.legs[0].distance.text
  $('#duration').text route.legs[0].duration.text
  $('#copyrights').text route.copyrights
  $('#result').show()
  route_km = (Number) route.legs[0].distance.value / 1000
  route_gasoline = route_km * (Number) $('#fuel-help').data('avg-consumption')
  $('#fuel-help-text').text I18n.t('javascript.fuel_help_text', { km: route_km.toFixed(2), est: Math.ceil(route_gasoline), avg_consumption: $('#fuel-help').data('avg-consumption'), fuel_currency: $('html').data('fuelCurrency'), currency: $('html').data('currency') })
  $('#fuel-help').show()
  $('#itinerary_fuel_cost').val Math.ceil(route_gasoline)

  rleg = route.legs[0]

  data =
    start_location: [rleg.start_location.lng(), rleg.start_location.lat()]
    end_location: [rleg.end_location.lng(), rleg.end_location.lat()]
    via_waypoints: []
    overview_path: []
    overview_polyline: route.overview_polyline

  for waypoint in rleg.via_waypoints
    data.via_waypoints.push [waypoint.lng(), waypoint.lat()]

  # Show a link to remove waypoints
  if rleg.via_waypoints.length > 0
    $('#remove-waypoints-link').show()
  else
    $('#remove-waypoints-link').hide()

  for point in route.overview_path
    data.overview_path.push [point.lng(), point.lat()]

  window.icare.route = data
  $('#itinerary_route').val JSON.stringify(data)

wizardPrevStep = ->
  step = (Number) $('div[data-step]:visible').data('step')
  return if step <= 1

  lastStep = (Number) $('div[data-step]').last().data('step')

  $("#wizard-step-#{step}-content").fadeOut ->
    $('#wizard-next-step-button').prop('disabled', false).show()
    $('#new_itinerary_submit').prop('disabled', true).hide()

    $("#wizard-step-#{step}-title").addClass('hidden-xs').removeClass 'active'

    $("#wizard-step-#{step}-title")
      .removeClass('hidden-xs').addClass('active')

    --step

    $("#wizard-step-#{step}-content").fadeIn()

    if step is 1
      $("#wizard-prev-step-button").prop('disabled', true).hide()

    $(window).scrollTop("#wizard-step-#{step}-title")

wizardNextStep = ->
  # Run validations
  if $('#itinerary_route').val() is ''
    $('#error').text(I18n.t 'javascript.setup_route_first').show()
    return false

  valid = true
  $('#new_itinerary [data-validate]:input:visible').each ->
    settings = window.ClientSideValidations.forms[this.form.id]
    unless $(this).isValid(settings.validators)
      valid = false
    return
  return false unless valid

  step = (Number) $('div[data-step]:visible').data('step')
  lastStep = (Number) $('div[data-step]').last().data('step')

  if step is lastStep
    return false

  $("#wizard-step-#{step}-content").fadeOut ->
    $("#wizard-step-#{step}-title")
      .removeClass('active').addClass('hidden-xs')

    ++step

    if step is lastStep
      lastStepInit()
    $("#wizard-step-#{step}-title").removeClass('hidden-xs').addClass 'active'

    $("#wizard-step-#{step}-content").fadeIn ->
      $('#new_itinerary').enableClientSideValidations() # Enable validation for new fields
      $(window).scrollTop("#wizard-step-#{step}-title")

    if step > 1
      $("#wizard-prev-step-button").prop('disabled', false).show()
      if step is lastStep
        $('#wizard-next-step-button').prop('disabled', true).hide()
        $('#new_itinerary_submit').prop('disabled', false).show()

dateFieldToString = (field_id) ->
  values = $("select[id^=#{field_id}] option:selected")
  year = $("##{field_id}_1i").val()
  month = $("##{field_id}_2i").val().lpad 0, 2
  day = $("##{field_id}_3i").val().lpad 0, 2
  hour = $("##{field_id}_4i").val().lpad 0, 2
  minute = $("##{field_id}_5i").val().lpad 0, 2
  dateString = "#{year}-#{month}-#{day}T#{hour}:#{minute}:00"
  if I18n? then I18n.l('time.formats.long', dateString) else dateString

lastStepInit = ->
  route = window.icare.route
  $('#itinerary-preview-image').attr 'src', "http://maps.googleapis.com/maps/api/staticmap?size=640x360&scale=2&sensor=false&markers=color:green|label:B|#{route.end_location[1]},#{route.end_location[0]}&markers=color:green|label:A|#{route.start_location[1]},#{route.start_location[0]}&path=enc:#{route.overview_polyline}"

setRoute = (dr, result) ->
  dr.setDirections result
  dr.setOptions
    polylineOptions:
      strokeColor: '#0000ff'
      strokeWeight: 5
      strokeOpacity: 0.45
  dr.map.fitBounds dr.directions.routes[0].bounds
  # dr.setOptions
  #  suppressMarkers: true

getWaypoints = () ->
  try
    for point in JSON.parse($('#itinerary_via_waypoints').val())
      { location: new google.maps.LatLng(point[1], point[0]), stopover: false }
  catch e
    []

calculateRoute = (dr, ds) ->
  return if $('#itinerary_start_address').val() is '' || $('#itinerary_end_address').val() is ''
  $('#itineraries-spinner').show()
  $('#error').hide()
  $('#result').hide()
  $('#route-helper').hide()
  $('#copyrights').text ''
  $('#distance').text ''
  $('#duration').text ''
  ds.route
    origin: $('#itinerary_start_address').val()
    destination: $('#itinerary_end_address').val()
    travelMode: 'DRIVING' # $("#mode").val()
    avoidHighways: $('#itinerary_avoid_highways').prop 'checked'
    avoidTolls: $('#itinerary_avoid_tolls').prop 'checked'
    waypoints: getWaypoints()
  , (result, status) ->
    $('#itineraries-spinner').hide()
    if status is google.maps.DirectionsStatus.OK
      setRoute dr, result
    else
      switch status
        when 'NOT_FOUND'
          message = I18n.t 'javascript.not_found'
        when 'ZERO_RESULTS'
          message = I18n.t 'javascript.zero_results'
        else
          message = status
      $('#error').text(message).show()

createRouteMapInit = (id) ->
  map = icare.initGoogleMaps id

  dr = new google.maps.DirectionsRenderer
    map: map
    draggable: true
    preserveViewport: true

  ds = new google.maps.DirectionsService()

  google.maps.event.addListener dr, 'directions_changed', ->
    map.fitBounds dr.directions.routes[0].bounds
    setItinerary dr.getDirections().routes[0]
    $('#new_itinerary_submit').prop 'disabled', false

  $itinerary_address_inputs = $('#itinerary_start_address, #itinerary_end_address')
  $itinerary_route_checkboxes = $('#itinerary_avoid_highways, #itinerary_avoid_tolls')

  # Get Route acts as submit
  $itinerary_address_inputs.on 'keypress', (e) ->
    if e and e.keyCode is 13
      e.preventDefault()
      calculateRoute dr, ds

  $('#get-route').on 'click', ->
    valid = true
    $('[data-validate]:input:visible').each ->
      settings = window.ClientSideValidations.forms[this.form.id]
      valid = false unless $(this).isValid settings.validators
      return
    return unless valid
    calculateRoute dr, ds

  # Set route if it's already available
  calculateRoute dr, ds


initItineraryNew = ->
  createRouteMapInit('#new-itinerary-map')
  $('#wizard-next-step-button').on 'click', wizardNextStep
  $('#wizard-prev-step-button').on 'click', wizardPrevStep
  $('input[name="itinerary[daily]"]').change ->
    if (Boolean) $(this).val() is 'true'
      $('#single').fadeOut ->
        $('#daily').fadeIn()
    else
      $('#daily').fadeOut ->
        $('#single').fadeIn()

$ ->
  if google? && $('#new_itinerary')[0]?
    initItineraryNew()
