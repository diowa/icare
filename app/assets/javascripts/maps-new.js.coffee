###
Itineraries
  people in the car: bool
  visibility: friends, friends of friends, public
  daily: think about it
###

# From https://google-developers.appspot.com/maps/customize_ae458c7692ac994187feb6f58834b6af.frame

###global $:false, google:false, I18n:false###

'use strict'

window.icare = window.icare || {}
icare = window.icare

getJSONRoute = (route) ->
  # TODO server side, basing on start location, end location and via waypoints
  # NOTE server side is limited to 2.500 requests per day. Are we sure?

  data =
    start_location: null
    end_location: null
    via_waypoints: []
    overview_path: []
    overview_polyline: null

  rleg = route.legs[0]
  data.start_location =
    'lat': rleg.start_location.lat()
    'lng': rleg.start_location.lng()
  data.end_location =
    'lat': rleg.end_location.lat()
    'lng': rleg.end_location.lng()

  for waypoint in rleg.via_waypoints
    data.via_waypoints.push [waypoint.lat(), waypoint.lng()]

  for point in route.overview_path
    data.overview_path.push [point.lat(), point.lng()]

  data.overview_polyline = route.overview_polyline.points

  data

wizardPrevStep = ->
  step = (Number) $('div[data-step]:visible').data('step')
  return if step <= 1

  lastStep = (Number) $('div[data-step]').last().data('step')

  $("#wizard-step-#{step}-content").fadeOut ->
    $('#wizard-next-step-button').prop('disabled', false).show()
    $('#new_itinerary_submit').prop('disabled', true).hide()

    $("#wizard-step-#{step}-title").addClass('hidden-phone').removeClass 'active'

    $("#wizard-step-#{step}-title")
      .removeClass('hidden-phone').addClass('active')

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
      .removeClass('active').addClass('hidden-phone')

    ++step

    if step is lastStep
      lastStepInit()
    $("#wizard-step-#{step}-title").removeClass('hidden-phone').addClass 'active'

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

window.test = dateFieldToString

lastStepInit = ->
  route = window.icare.route
  $('#itinerary-preview-image').attr 'src', "http://maps.googleapis.com/maps/api/staticmap?size=640x360&scale=2&sensor=false&markers=color:green|label:B|#{route.end_location.lat},#{route.end_location.lng}&markers=color:green|label:A|#{route.start_location.lat},#{route.start_location.lng}&path=enc:#{route.overview_polyline}"

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

createRouteMapInit = (id) ->
  map = icare.initGoogleMaps id

  dr = new google.maps.DirectionsRenderer
    map: map
    draggable: true
    preserveViewport: true

  ds = new google.maps.DirectionsService()

  google.maps.event.addListener dr, 'directions_changed', ->
    route = dr.getDirections().routes[0]
    json_route = getJSONRoute route
    $('#from-helper, #itinerary-preview-from').text route.legs[0].start_address
    $('#to-helper, #itinerary-preview-to').text route.legs[0].end_address
    $('#itinerary_start_address').val route.legs[0].start_address
    $('#itinerary_end_address').val route.legs[0].end_address
    $('#itinerary_route').val JSON.stringify(json_route)
    $('#itinerary_itineraries_route_waypoints').val JSON.stringify(route.legs[0].via_waypoints)
    window.icare.itinerary = route
    window.icare.route = json_route
    $('#new_itinerary_submit').prop 'disabled', false
    $('#distance').text route.legs[0].distance.text
    $('#duration').text route.legs[0].duration.text
    $('#copyrights').text route.copyrights
    $('#route-helper').show()
    $('#result').show()
    route_km = (Number) route.legs[0].distance.value / 1000
    route_gasoline = route_km * (Number) $('#fuel-help').data('avg-consumption')
    $('#fuel-help-text').text $('#fuel-help').data('text').replace("{km}", route_km.toFixed(2)).replace("{est}", parseInt(route_gasoline, 10))
    $('#fuel-help').show()
    path = route.overview_path
    map.fitBounds(dr.directions.routes[0].bounds)

  # Get Route acts as submit
  $('input[type=text][id^=itinerary_itineraries_route]').on 'keypress', (e) ->
    if e and e.keyCode is 13
      e.preventDefault()
      $('#get-route').click()

  $('#get-route').on 'click', ->
    valid = true
    $('[data-validate][id^=itinerary_itineraries_route]:input:visible').each ->
      settings = window.ClientSideValidations.forms[this.form.id]
      valid = false unless $(this).isValid settings.validators
      return
    return unless valid
    $('#itineraries-spinner').show()
    $('#error').hide()
    $('#result').hide()
    $('#route-helper').hide()
    $('#copyrights').text ''
    $('#distance').text ''
    $('#duration').text ''
    ds.route
      origin: $('#itinerary_itineraries_route_from').val()
      destination: $('#itinerary_itineraries_route_to').val()
      travelMode: 'DRIVING' # $("#mode").val()
      avoidHighways: $('#itinerary_itineraries_route_avoid_highways').prop 'checked'
      avoidTolls: $('#itinerary_itineraries_route_avoid_tolls').prop 'checked'
      waypoints:
        try
          JSON.parse($('#itinerary_route').val()).via_waypoints.map (point) ->
            { location: new google.maps.LatLng(point[0], point[1]) }
        catch error
          []
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

  $('.share').click ->
    $(this).find('input').focus().select()

  # Set route if it's already available
  if $('#itinerary_itineraries_route_from').val() isnt '' && $('#itinerary_itineraries_route_to').val() isnt ''
    # TODO cache this object
    $('#get-route').click()


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
  $('#itinerary_round_trip').change ->
    status = $(this).prop 'checked'
    $('select[id^="itinerary_return_date"]').prop 'disabled', !status

# jQuery Turbolinks
$ ->
  if $('#new_itinerary')[0]?
    initItineraryNew()
