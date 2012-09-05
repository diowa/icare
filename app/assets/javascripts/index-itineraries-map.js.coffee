###global google:false###

"use strict"

window.icare = window.icare || {}
icare = window.icare

$("#search-form-advanced-link").on 'click', (e) ->
  e.preventDefault()
  me = this
  $("#search-form-advanced").slideToggle ->
    $icon = $(me).find("i")
    if $icon.hasClass "icon-chevron-up"
      $icon.removeClass("icon-chevron-up").addClass("icon-chevron-down")
    else
      $icon.removeClass("icon-chevron-down").addClass("icon-chevron-up")

routeColoursArray = [
  "#0000ff"
  "#ff0000"
  "#00ffff"
  "#ff00ff"
  "#ffff00"
  ]

Handlebars.registerHelper 'toLowerCase', (string) ->
  if string
    new Handlebars.SafeString string.toLowerCase()
  else
    ''

Handlebars.registerHelper 'translate', (key) ->
  if translation = $("#translations").data(key)
    new Handlebars.SafeString translation
  else
    ''

$ ->
  if $("#index-itineraries-map")[0]?
    indexItinerariesMapInit("#index-itineraries-map")
    window.customMarkers = []
    window.itineraries = []
    # TODO clean this mess... directions service again?
    $("#itineraries-search").on "click", ->
      return false unless $("#new_itinerary_search").isValid(window.new_itinerary_search.validators)
      $("#error").hide()
      geocoder = new google.maps.Geocoder()
      address = $("#itinerary_search_from").val()
      geocoder.geocode
        address: address
      , (results, status) ->
        if status is google.maps.GeocoderStatus.OK
          $("#itinerary_search_from").val results[0].formatted_address
          location = results[0].geometry.location
          window.icare.search_center = location
          $("#itinerary_search_start_location_lat").val results[0].geometry.location.lat()
          $("#itinerary_search_start_location_lng").val results[0].geometry.location.lng()
          geocoder = new google.maps.Geocoder()
          address = $("#itinerary_search_to").val()
          geocoder.geocode
            address: address
          , (results, status) ->
            if status is google.maps.GeocoderStatus.OK
              $("#itinerary_search_to").val results[0].formatted_address
              location = results[0].geometry.location
              $("#itinerary_search_end_location_lat").val results[0].geometry.location.lat()
              $("#itinerary_search_end_location_lng").val results[0].geometry.location.lng()
              $("#new_itinerary_search").submit()
    $("#new_itinerary_search").on "keypress", (e) ->
      if e and e.keyCode is 13
        e.preventDefault()
        $("#itineraries-search").click()
    $("#new_itinerary_search")
      .bind "submit", (evt) ->
        $(window.icare.itineraries).each ->
          this.setMap null
        window.icare.itineraries = []
        $(window.icare.customMarkers).each ->
          this.setMap null
        window.icare.customMarkers = []
      .bind "ajax:beforeSend", (evt, xhr, settings) ->
        $("#itineraries-spinner").show()
      .bind "ajax:complete", (evt, xhr, settings) ->
        $("#itineraries-spinner").hide()
      .bind "ajax:error", (evt, xhr, settings) ->
        $("#itineraries-thumbs").html """
          <h4 class="errorText">#{$("#translations").data("no_itineraries_found")}</h3>
          """
        false
      .bind "ajax:success", (evt, data, status, xhr) ->
        if data.length is 0
          $("#itineraries-thumbs").html """
            <h4>#{$("#translations").data("no_itineraries_found")}</h3>
            """
        else
          $("#itineraries-thumbs").html ""
          index = 0
          window.icare.latLngBounds = new google.maps.LatLngBounds()
          $(data).each ->
            color = routeColoursArray[index++ % routeColoursArray.length]
            drawPath this, color
            this.borderColor = hexToRgba(color, 0.45) # borderColor injection, waiting for proper @data support in handlebars
            $("#itineraries-thumbs").append HandlebarsTemplates["itinerary"](this)
          window.icare.map.fitBounds window.icare.latLngBounds

hexToRgba = (color, alpha = 1) ->
  if color.charAt(0) is "#" then (h = color.substring(1,7)) else (h = color)
  "rgba(#{parseInt(h.substring(0,2),16)}, #{parseInt(h.substring(2,4),16)}, #{parseInt(h.substring(4,6),16)}, #{alpha})"

indexItinerariesMapInit = (id) ->
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
  window.icare.map = new google.maps.Map $(id)[0],
    center: new google.maps.LatLng 41.87194, 12.567379999999957
    mapTypeId: google.maps.MapTypeId.ROADMAP
    scrollwheel: false
    styles: styleArray
    zoom: 8
  window.icare.map.fitBounds(country_bounds)

  window.icare.infoWindow = new google.maps.InfoWindow
    maxWidth: 400
    pixelOffset:
      width: 0
      height: -35

drawPath = (itinerary, strokeColor = "#0000FF", strokeOpacity = 0.45) ->
  window.icare.latLngBounds.extend new google.maps.LatLng(itinerary.start_location.lat, itinerary.start_location.lng)
  window.icare.latLngBounds.extend new google.maps.LatLng(itinerary.end_location.lat, itinerary.end_location.lng)
  overview_path = google.maps.geometry.encoding.decodePath(itinerary.overview_polyline)
  return unless overview_path
  new_path = []
  customMarker = new window.icare.CustomMarker overview_path[0], window.icare.map,
    infoWindowContent: HandlebarsTemplates["gmaps_popup"]
      title: itinerary.title
      user:
        image: itinerary.user.profile_picture
        name: itinerary.user.name
        nationality: itinerary.user.nationality
      url: itinerary.url
      content: itinerary.description
    type: "user_profile_picture"
    image: itinerary.user.profile_picture
  google.maps.event.addListener customMarker, 'click', ->
    window.icare.infoWindow.setContent customMarker.options.infoWindowContent
    window.icare.infoWindow.open window.icare.map, customMarker
  marker = new google.maps.Marker
    icon: 'http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=A|FF0000|000000'
  directionsPath = new google.maps.Polyline
    clickable: false
    path: overview_path
    strokeColor: strokeColor
    strokeOpacity: strokeOpacity
    strokeWeight: 5
    icons: [
      icon:
        path: google.maps.SymbolPath.CIRCLE
      offset: '0%'
     ,
      icon:
        path: google.maps.SymbolPath.CIRCLE
      offet: '100%'
    ]
  directionsPath.setMap window.icare.map
  window.icare.customMarkers.push customMarker
  window.icare.itineraries.push directionsPath
