window.icare = window.icare || {}
icare = window.icare

routeColoursArray = ['#0000ff', '#ff0000', '#00ffff', '#ff00ff', '#ffff00']

hexToRgba = (color, alpha = 1) ->
  if color.charAt(0) is '#' then (h = color.substring(1,7)) else (h = color)
  "rgba(#{parseInt(h.substring(0,2),16)}, #{parseInt(h.substring(2,4),16)}, #{parseInt(h.substring(4,6),16)}, #{alpha})"

indexItinerariesMapInit = (id) ->
  icare.map = icare.initGoogleMaps id

  icare.infoWindow = new google.maps.InfoWindow
    maxWidth: 400
    pixelOffset:
      width: 0
      height: -35

drawPath = (itinerary, strokeColor = '#0000FF', strokeOpacity = 0.45) ->
  icare.latLngBounds.extend new google.maps.LatLng(itinerary.start_location.lat, itinerary.start_location.lng)
  icare.latLngBounds.extend new google.maps.LatLng(itinerary.end_location.lat, itinerary.end_location.lng)
  overview_path = google.maps.geometry.encoding.decodePath(itinerary.overview_polyline)
  return unless overview_path
  new_path = []
  customMarker = new icare.CustomMarker overview_path[0], icare.map,
    infoWindowContent: HandlebarsTemplates['gmaps_popup']
      user:
        image: itinerary.user.profile_picture
        name: itinerary.user.name
      url: itinerary.url
      content: itinerary.description
    type: 'user_profile_picture'
    image: itinerary.user.profile_picture
  google.maps.event.addListener customMarker, 'click', ->
    icare.infoWindow.setContent customMarker.options.infoWindowContent
    icare.infoWindow.setPosition customMarker.position
    icare.infoWindow.open icare.map
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
  directionsPath.setMap icare.map
  icare.customMarkers[itinerary.id] = customMarker
  icare.itineraries.push directionsPath

clearItineraries = ->
  if icare.itineraries?
    $(icare.itineraries).each ->
      this.setMap null

  if icare.customMarkers?
    for key of icare.customMarkers
      if icare.customMarkers.hasOwnProperty key
        icare.customMarkers[key].setMap null

  icare.itineraries = []
  icare.customMarkers = {}

initItineraryIndex = ->
  indexItinerariesMapInit('#index-itineraries-map')

  clearItineraries()

  # TODO: clean this mess... directions service again?
  $('#itineraries-search').on 'click', ->
    return false unless $("#new_itineraries_search").isValid(window.ClientSideValidations.forms["new_itineraries_search"].validators)
    $("#error").hide()
    geocoder = new google.maps.Geocoder()
    address = $("#itineraries_search_from").val()
    geocoder.geocode
      address: address
    , (results, status) ->
      if status is google.maps.GeocoderStatus.OK
        $("#itineraries_search_from").val results[0].formatted_address
        location = results[0].geometry.location
        icare.search_center = location
        $("#itineraries_search_start_location_lat").val results[0].geometry.location.lat()
        $("#itineraries_search_start_location_lng").val results[0].geometry.location.lng()
        geocoder = new google.maps.Geocoder()
        address = $("#itineraries_search_to").val()
        geocoder.geocode
          address: address
        , (results, status) ->
          if status is google.maps.GeocoderStatus.OK
            $("#itineraries_search_to").val results[0].formatted_address
            location = results[0].geometry.location
            $("#itineraries_search_end_location_lat").val results[0].geometry.location.lat()
            $("#itineraries_search_end_location_lng").val results[0].geometry.location.lng()
            $("#new_itineraries_search").submit()

  $('#new_itineraries_search').on 'keypress', (e) ->
    if e and e.keyCode is 13
      e.preventDefault()
      $('#itineraries-search').click()

  $('#new_itineraries_search')
    .on 'submit', (evt) ->
      clearItineraries()
    .on 'ajax:beforeSend', (evt, xhr, settings) ->
      $("#itineraries-spinner").show()
    .on 'ajax:complete', (evt, xhr, settings) ->
      $("#itineraries-spinner").hide()
    .on 'ajax:error', (evt, xhr, settings) ->
      $("#itineraries-thumbs").html """
        <div class="col-xs-12"><h3 class="error-text no-margin">#{I18n.t("javascript.an_error_occurred")}</h3></div>
        """
      false
    .on 'ajax:success', (evt, data, status, xhr) ->
      # FIXME: browser back calls ajax:success multiple times
      if data.length is 0
        $('#itineraries-thumbs').html """
          <div class="col-xs-12"><h3 class="no-margin">#{I18n.t("javascript.no_itineraries_found")}</h3></div>
          """
      else
        $('#itineraries-thumbs').html ''
        index = 0
        icare.latLngBounds = new google.maps.LatLngBounds()
        $(data).each ->
          color = routeColoursArray[index++ % routeColoursArray.length]
          drawPath this, color
          this.backgroundColor = hexToRgba(color, 0.45) # backgroundColor injection, waiting for proper @data support in handlebars
          $('#itineraries-thumbs').append HandlebarsTemplates['itineraries/thumbnail'](this)
        icare.map.fitBounds icare.latLngBounds
        $('.facebook-verified-tooltip').tooltip()

  $(document).on 'click', '.show-itinerary-on-map', (e) ->
    e.preventDefault()
    google.maps.event.trigger icare.customMarkers[$(this).closest('.itinerary-thumbnail').data('itineraryId')], 'click'
    $(window).scrollTop('#index-itineraries-map')
    false

$ ->
  if google? && $('#index-itineraries-map')[0]?
    initItineraryIndex()
