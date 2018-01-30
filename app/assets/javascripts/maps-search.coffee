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
        image: itinerary.user.image
        name: itinerary.user.name
      url: itinerary.url
      content: itinerary.description
    type: 'user_profile_picture'
    image: itinerary.user.image
  google.maps.event.addListener customMarker, 'click', ->
    icare.infoWindow.setContent customMarker.options.infoWindowContent
    icare.infoWindow.setPosition customMarker.position
    icare.infoWindow.open icare.map
  marker = new google.maps.Marker
    icon: 'https://mts.googleapis.com/maps/vt/icon/name=icons/spotlight/spotlight-waypoint-a.png&text=A&psize=16&font=fonts/Roboto-Regular.ttf&color=ff333333&ax=44&ay=48&scale=1'
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

lookupPosition = (search_field) ->
  deferred = $.Deferred()
  geocoder = new google.maps.Geocoder()

  geocoder.geocode
    address: $("#itineraries_search_#{search_field}").val()
  , (results, status) ->
    if status is google.maps.GeocoderStatus.OK
      first_result = results[0]
      deferred.resolve
        formatted_address: first_result.formatted_address
        lat: first_result.geometry.location.lat()
        lng: first_result.geometry.location.lng()
    else
      deferred.reject status

  deferred.promise()

initItineraryIndex = ->
  indexItinerariesMapInit('#index-itineraries-map')

  clearItineraries()

  $('#itineraries-search').on 'click', (e) ->
    e.preventDefault()
    validators = $("#new_itineraries_search")[0].ClientSideValidations.settings.validators
    return unless $("#new_itineraries_search").isValid(validators)

    $("#map-error-j").hide()

    $.when(
      lookupPosition('from'),
      lookupPosition('to')
    ).then((from_result, to_result) ->
      $("#itineraries_search_from").val from_result.formatted_address
      $("#itineraries_search_start_location_lat").val from_result.lat
      $("#itineraries_search_start_location_lng").val from_result.lng
      $("#itineraries_search_to").val to_result.formatted_address
      $("#itineraries_search_end_location_lat").val to_result.lat
      $("#itineraries_search_end_location_lng").val to_result.lng
      $("#new_itineraries_search").submit()
    )

  $('#new_itineraries_search').on 'keypress', (e) ->
    if e and e.keyCode is 13
      e.preventDefault()
      $('#itineraries-search').click()

  $('#new_itineraries_search')
    .on 'submit', (evt) ->
      clearItineraries()
    .on 'ajax:beforeSend', (evt, xhr, settings) ->
      $("#itineraries-spinner-j").show()
    .on 'ajax:complete', (evt, xhr, settings) ->
      $("#itineraries-spinner-j").hide()
    .on 'ajax:error', (evt, xhr, settings) ->
      $("#itineraries-thumbs").html """
        <div class="col-12"><h3 class="error-text no-margin">#{I18n.t("javascript.an_error_occurred")}</h3></div>
        """
      false
    .on 'ajax:success', (evt, data, status, xhr) ->
      # FIXME: browser back calls ajax:success multiple times
      if data.length is 0
        $('#itineraries-thumbs').html """
          <div class="col-12"><h3 class="no-margin">#{I18n.t("javascript.no_itineraries_found")}</h3></div>
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

$(document).on window.initializeOnEvent, ->
  if google? && $('#index-itineraries-map')[0]?
    initItineraryIndex()
