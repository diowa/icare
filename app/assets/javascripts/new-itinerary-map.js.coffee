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

  data =
    start_location: null
    end_location: null
    via_waypoints: []
    overview_path: []
    overview_polyline: null

  rleg = route.legs[0];
  data.start_location =
    'lat': rleg.start_location.lat()
    'lng': rleg.start_location.lng()
  data.end_location =
    'lat': rleg.end_location.lat(),
    'lng': rleg.end_location.lng()

  for waypoint in rleg.via_waypoints
    data.via_waypoints.push [ waypoint.lat(), waypoint.lng() ]

  for point in route.overview_path
    data.overview_path.push [point.lat(), point.lng() ]

  data.overview_polyline = route.overview_polyline.points

  data

wizardPrevStep = ->
  step = (Number) $('#new_itinerary').data 'step'
  return if step <= 1

  lastStep = (Number) $('#new_itinerary').data 'lastStep'

  $("#wizard-step-#{step}-content").fadeOut ->
    $('#wizard-next-step-button').removeAttr('disabled').show()
    $('#new_itinerary_submit').attr('disabled', 'disabled').hide()

    $("#wizard-step-#{step}-title").addClass('hidden-phone').removeClass 'active'

    $("#new_itinerary").data 'step', --step
    $("#wizard-step-#{step}-title")
      .removeClass('done').removeClass('hidden-phone').addClass('active')
      .find('.icon-check').addClass('icon-check-empty').toggleClass('icon-check')

    $("#wizard-step-#{step}-content").fadeIn()
    if step is 1
      $("#wizard-prev-step-button").attr('disabled', 'disabled').hide()

wizardNextStep = ->
  # Run validations
  if $('#itinerary_route_json_object').val() is ''
    $('#error').text($('#new_itinerary_route').data 'getRouteBeforeText').show()
    return false

  valid = true
  $('#new_itinerary [data-validate]:input:visible').each ->
    settings = window.ClientSideValidations.forms[this.form.id]
    unless $(this).isValid(settings.validators)
      valid = false
    return
  return false unless valid

  step = (Number) $('#new_itinerary').data 'step'
  lastStep = (Number) $('#new_itinerary').data 'lastStep'

  if step is lastStep
    return false

  $("#wizard-step-#{step}-content").fadeOut ->
    $("#wizard-step-#{step}-title")
      .removeClass('active').addClass('done').addClass('hidden-phone')
      .find('.icon-check-empty').addClass('icon-check').toggleClass('icon-check-empty')
    $('#new_itinerary').data 'step', ++step
    if step is lastStep
      lastStepInit()
    $("#wizard-step-#{step}-title").removeClass('hidden-phone').addClass 'active'
    $("#wizard-step-#{step}-content").fadeIn ->
      $('#new_itinerary').enableClientSideValidations() # Enable validation for new fields
    if step > 1
      $("#wizard-prev-step-button").removeAttr('disabled').show()
      if step is lastStep
        $('#wizard-next-step-button').attr('disabled', 'disabled').hide()
        $('#new_itinerary_submit').removeAttr('disabled').show()

dateFieldToString = (field_id) ->
  values = $("select[id^=#{field_id}] option:selected")
  year = $("##{field_id}_1i").val()
  month = $("##{field_id}_2i").val()
  day = $("##{field_id}_3i").val()
  hour = $("##{field_id}_4i").val()
  minute = $("##{field_id}_5i").val()
  if I18n?
    I18n.l 'time.formats.long', "#{year}-#{month}-#{day}T#{hour}:#{minute}:00"
  else
    "#{year}-#{month}-#{day}T#{hour}:#{minute}:00"

lastStepInit = ->
  # TODO handlebars template
  $('#itinerary-preview-title').text $('#itinerary_title').val()
  $('#itinerary-preview-description').text $('#itinerary_description').val()
  $('#itinerary-preview-vehicle').text $('#itinerary_vehicle option:selected').text()
  $("#itinerary-preview-smoking_allowed").text if $("#itinerary_smoking_allowed").attr("checked")? then $("#itinerary-preview").data("true_text") else $("#itinerary-preview").data("false_text")
  $("#itinerary-preview-pets_allowed").text if $("#itinerary_pets_allowed").attr("checked")? then $("#itinerary-preview").data("true_text") else $("#itinerary-preview").data("false_text")
  $("#itinerary-preview-pink").text if $("#itinerary_pink").attr("checked")? then $("#itinerary-preview").data("true_text") else $("#itinerary-preview").data("false_text")
  $("#itinerary-preview-fuel_cost").text $("#itinerary_fuel_cost").val()
  $("#itinerary-preview-tolls").text $("#itinerary_tolls").val()

  round_trip = $("#itinerary_round_trip").attr("checked")?
  $("#itinerary-preview-round_trip").text if round_trip then $("#itinerary-preview").data("true_text") else $("#itinerary-preview").data("false_text")
  $("#itinerary-preview-leave_date").text dateFieldToString("itinerary_leave_date")

  if round_trip
    $("#itinerary-preview-return_date").text dateFieldToString("itinerary_return_date")
    $(".itinerary-preview-return").show()
  else
    $(".itinerary-preview-return").hide()

  route = window.icare.itinerary_route_json_object
  url_builder = $("#itinerary-preview-image")
    .data("staticMapUrlBuilder")
    .replace("%{end_location}", "#{route.end_location.lat},#{route.end_location.lng}")
    .replace("%{start_location}", "#{route.start_location.lat},#{route.start_location.lng}")
    .replace("%{overview_polyline}", "#{route.overview_polyline}")
  $("#itinerary-preview-image").attr "src", url_builder

createRouteMapInit = (id) ->
  recalcHeight = ->
    $("#map").height $(window).height() - $("form").height() - $("#elevation").height()
    map and google.maps.event.trigger map, "resize"
  $(window).resize recalcHeight
  recalcHeight()

  # for o of google.maps.DirectionsTravelMode
  #  $("#mode").append new Option(o)

  styleArray = [
      featureType: "all"
      stylers: [
      ]
    ,
      featureType: "road"
      elementType: "geometry"
      stylers: [
      ]
    ,
      featureType: "poi"
      elementType: "labels"
      stylers: [
        visibility: "off"
      ]
  ]

  country_bounds = new google.maps.LatLngBounds new google.maps.LatLng(35.49292010, 6.62672010), new google.maps.LatLng(47.0920, 18.52050150)
  map = new google.maps.Map $(id)[0],
    center: new google.maps.LatLng 41.87194, 12.567379999999957
    mapTypeId: google.maps.MapTypeId.ROADMAP
    scrollwheel: false
    styles: styleArray
    zoom: 8
  map.fitBounds(country_bounds)

  dr = new google.maps.DirectionsRenderer
    map: map
    draggable: true
    preserveViewport: true

  hoverMarker = new google.maps.Marker(map: map)

  $("#elevation").mouseleave ->
    hoverMarker.setVisible false
    $("#elevation-hover").hide()

  ds = new google.maps.DirectionsService()

  google.maps.event.addListener dr, "directions_changed", ->
    route = dr.getDirections().routes[0]
    route_json_object = getJSONRoute route
    $("#from-helper").text route.legs[0].start_address
    $("#to-helper").text route.legs[0].end_address
    $("#itinerary_route_json_object").val JSON.stringify(route_json_object)
    window.icare.itinerary_route_json_object = route_json_object
    $("#new_itinerary_submit").removeAttr "disabled"
    $("#distance").text route.legs[0].distance.text
    $("#duration").text route.legs[0].duration.text
    $("#route-helper").show()
    $("#result").show()
    $("#itinerary_title").val "#{$("#itinerary_route_from").val()} - #{$("#itinerary_route_to").val()}".substr(0, 40).capitalize()
    route_km = route.legs[0].distance.value / 1000
    route_gasoline = route_km * (Number) $("#fuel-help").data("avg_consumption")
    $("#fuel-help-text").text $("#fuel-help").data("text").replace("{km}", route_km.toFixed(2)).replace("{est}", parseInt(route_gasoline, 10))
    $("#fuel-help").show()
    path = route.overview_path
    map.fitBounds(dr.directions.routes[0].bounds)

  $("#new_itinerary_route").on "submit", ->
    $("#itineraries-spinner").show()
    $("#error").hide()
    $("#result").hide()
    $("#route-helper").hide()
    $("#distance").text("")
    $("#duration").text("")
    ds.route
      origin: $("#itinerary_route_from").val()
      destination: $("#itinerary_route_to").val()
      travelMode: "DRIVING" #$("#mode").val()
      avoidHighways: $("#itinerary_route_avoid_highways").attr("checked")?
      avoidTolls: $("#itinerary_route_avoid_tolls").attr("checked")?
    , (result, status) ->
      $("#itineraries-spinner").hide()
      if status is google.maps.DirectionsStatus.OK
        dr.setDirections result
        dr.setOptions
          polylineOptions:
            strokeColor:"#0000ff"
            strokeWeight:5
            strokeOpacity:0.45
        dr.map.fitBounds(dr.directions.routes[0].bounds)
        # dr.setOptions
        #  suppressMarkers: true
      else
        switch status
          when "NOT_FOUND"
            message = $("#new_itinerary_route").data "notFoundText"
          when "ZERO_RESULTS"
            message = $("#new_itinerary_route").data "zeroResultsText"
          else
            message = status
        $("#error").text(message).show()
      recalcHeight()
    false

  drawElevation = (r) ->
    max = writeStats(r)
    drawGraph r, max

  writeStats = (r) ->
    prevElevation = r[0].elevation
    climb = 0
    drop = 0
    max = 0
    i = 1

    while i < r.length
      diff = r[i].elevation - prevElevation
      prevElevation = r[i].elevation
      if diff > 0
        climb += diff
      else
        drop -= diff
      max = r[i].elevation  if r[i].elevation > max
      i++
    max = Math.ceil(max)
    $("#climb-drop").text "Climb: " + Math.round(climb) + "m Drop: " + Math.round(drop) + "m"
    max

  drawGraph = (r, max) ->
    ec = $("#elevation-chart").empty()
    width = Math.max(1, Math.floor(Math.min(11, ec.width() / r.length)) - 1)
    height = 100
    $.each r, (i, e) ->
      barHeight = Math.round(e.elevation / max * height)
      bar = $("<div style='width:" + width + "px'><div style='height:" + barHeight + "px;'></div></div>")
      ec.append bar
      bar.mouseenter(->
        offset = bar.find("div").offset()
        offset.top -= 25
        offset.left -= 3
        hoverMarker.setVisible true
        hoverMarker.setPosition e.location
        $("#elevation-hover").show().text(Math.round(e.elevation) + "m").offset offset
        map.panTo e.location  unless map.getBounds().contains(e.location)
      ).click ->
        map.panTo e.location

  $(".share").click ->
    $(this).find("input").focus().select()

initItineraryNew = ->
  createRouteMapInit("#new-itinerary-map")
  $("#wizard-next-step-button").on "click", wizardNextStep
  $("#wizard-prev-step-button").on "click", wizardPrevStep
  $('input[name="itinerary[daily]"]').change ->
    if (Boolean) $(this).val() is "true"
      $("#single").fadeOut ->
        $("#daily").fadeIn()
    else
      $("#daily").fadeOut ->
        $("#single").fadeIn()
  $('#itinerary_round_trip').change ->
    status = $(this).attr("checked")
    $('select[id^=itinerary_return_date]').each ->
      $(this).attr "disabled", (if status then null else "disabled")

# jQuery Turbolinks
$ ->
  if $("#new_itinerary")[0]?
    initItineraryNew()
