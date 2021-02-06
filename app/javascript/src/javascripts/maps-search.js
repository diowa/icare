window.icare = window.icare || {}
const {
  icare
} = window

const routeColoursArray = ['#0000ff', '#ff0000', '#00ffff', '#ff00ff', '#ffff00']

const hexToRgba = function (color, alpha) {
  let h
  if (alpha == null) { alpha = 1 }
  if (color.charAt(0) === '#') { h = color.substring(1, 7) } else { h = color }
  return `rgba(${parseInt(h.substring(0, 2), 16)}, ${parseInt(h.substring(2, 4), 16)}, ${parseInt(h.substring(4, 6), 16)}, ${alpha})`
}

const indexItinerariesMapInit = function (id) {
  icare.map = icare.initGoogleMaps(id)

  icare.infoWindow = new google.maps.InfoWindow({
    maxWidth: 400,
    pixelOffset: {
      width: 0,
      height: -35
    }
  })
}

const drawPath = function (itinerary, strokeColor, strokeOpacity) {
  if (strokeColor == null) { strokeColor = '#0000FF' }
  if (strokeOpacity == null) { strokeOpacity = 0.45 }
  icare.latLngBounds.extend(new google.maps.LatLng(itinerary.start_location.lat, itinerary.start_location.lng))
  icare.latLngBounds.extend(new google.maps.LatLng(itinerary.end_location.lat, itinerary.end_location.lng))
  const overviewPath = google.maps.geometry.encoding.decodePath(itinerary.overview_polyline)
  if (!overviewPath) { return }
  const customMarker = new icare.CustomMarker(overviewPath[0], icare.map, {
    infoWindowContent: HandlebarsTemplates.gmaps_popup({
      user: {
        image: itinerary.user.image,
        name: itinerary.user.name
      },
      url: itinerary.url,
      content: itinerary.description
    }),
    type: 'user_profile_picture',
    image: itinerary.user.image
  }
  )
  google.maps.event.addListener(customMarker, 'click', function () {
    icare.infoWindow.setContent(customMarker.options.infoWindowContent)
    icare.infoWindow.setPosition(customMarker.position)
    return icare.infoWindow.open(icare.map)
  })
  const directionsPath = new google.maps.Polyline({
    clickable: false,
    path: overviewPath,
    strokeColor,
    strokeOpacity,
    strokeWeight: 5,
    icons: [{
      icon: {
        path: google.maps.SymbolPath.CIRCLE
      },
      offset: '0%'
    },
    {
      icon: {
        path: google.maps.SymbolPath.CIRCLE
      },
      offet: '100%'
    }
    ]
  })
  directionsPath.setMap(icare.map)
  icare.customMarkers[itinerary.id] = customMarker
  icare.itineraries.push(directionsPath)
}

const clearItineraries = () => {
  if (icare.itineraries) {
    $(icare.itineraries).each(function () {
      this.setMap(null)
    })
  }

  if (icare.customMarkers) {
    for (const customMarker of Object.keys(icare.customMarkers)) {
      icare.customMarkers[customMarker].setMap(null)
    }
  }

  icare.itineraries = []
  icare.customMarkers = {}
}

const lookupPosition = function (searchField) {
  const deferred = $.Deferred()
  const geocoder = new google.maps.Geocoder()

  geocoder.geocode(
    { address: $(`#itineraries_search_${searchField}`).val() }
    , function (results, status) {
      if (status === google.maps.GeocoderStatus.OK) {
        const firstResult = results[0]
        return deferred.resolve({
          formatted_address: firstResult.formatted_address,
          lat: firstResult.geometry.location.lat(),
          lng: firstResult.geometry.location.lng()
        })
      } else {
        return deferred.reject(status)
      }
    })

  return deferred.promise()
}

const initItineraryIndex = function () {
  indexItinerariesMapInit('#index-itineraries-map')

  clearItineraries()

  $('#itineraries-search').on('click', function (e) {
    e.preventDefault()
    const validators = $('#new_itineraries_search')[0].ClientSideValidations.settings
    if (!$('#new_itineraries_search').isValid(validators)) { return }

    $('#map-error-j').hide()

    $.when(
      lookupPosition('from'),
      lookupPosition('to')
    ).then(function (fromResult, toResult) {
      $('#itineraries_search_from').val(fromResult.formatted_address)
      $('#itineraries_search_start_location_lat').val(fromResult.lat)
      $('#itineraries_search_start_location_lng').val(fromResult.lng)
      $('#itineraries_search_to').val(toResult.formatted_address)
      $('#itineraries_search_end_location_lat').val(toResult.lat)
      $('#itineraries_search_end_location_lng').val(toResult.lng)
      $('#new_itineraries_search').submit()
    })
  })

  $('#new_itineraries_search').on('keypress', function (e) {
    if (e && (e.keyCode === 13)) {
      e.preventDefault()
      $('#itineraries-search').click()
    }
  })

  $('#new_itineraries_search')
    .on('submit', evt => clearItineraries())
    .on('ajax:beforeSend', (evt, xhr, settings) => $('#itineraries-spinner-j').show())
    .on('ajax:complete', (evt, xhr, settings) => $('#itineraries-spinner-j').hide())
    .on('ajax:error', (evt, xhr, settings) => {
      $('#itineraries-thumbs').html(`<div class="col-12"><h3 class="error-text no-margin">${I18n.t('javascript.an_error_occurred')}</h3></div>`)
    })
    .on('ajax:success', function (evt, data, status, xhr) {
      // FIXME: browser back calls ajax:success multiple times
      if (data.length === 0) {
        $('#itineraries-thumbs').html(`<div class="col-12"><h3 class="no-margin">${I18n.t('javascript.no_itineraries_found')}</h3></div>`)
      } else {
        $('#itineraries-thumbs').html('')
        let index = 0
        icare.latLngBounds = new google.maps.LatLngBounds()
        $(data).each(function () {
          const color = routeColoursArray[index++ % routeColoursArray.length]
          drawPath(this, color)
          this.backgroundColor = hexToRgba(color, 0.45) // backgroundColor injection, waiting for proper @data support in handlebars
          $('#itineraries-thumbs').append(HandlebarsTemplates['itineraries/thumbnail'](this))
        })
        icare.map.fitBounds(icare.latLngBounds)
      }
    })

  $(document).on('click', '.show-itinerary-on-map', function (e) {
    e.preventDefault()
    google.maps.event.trigger(icare.customMarkers[$(this).closest('.itinerary-thumbnail').data('itineraryId')], 'click')
    $(window).scrollTop('#index-itineraries-map')
  })
}

$(document).on(window.initializeOnEvent, function () {
  if ((typeof google !== 'undefined' && google !== null) && ($('#index-itineraries-map')[0] != null) && !icare.map) {
    initItineraryIndex()
  }
})
