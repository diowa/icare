/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
/*
Itineraries
  people in the car: bool
  visibility: friends, friends of friends, public
  daily: think about it
*/

// From https://google-developers.appspot.com/maps/customize_ae458c7692ac994187feb6f58834b6af.frame

window.icare = window.icare || {}
const {
  icare
} = window

const setItinerary = function (route) {
  // NOTE server side is limited to 2.500 requests per day, so we create routes on client

  // Set visible fields at first
  $('#from-helper, #itinerary-preview-from').text(route.legs[0].start_address)
  $('#to-helper, #itinerary-preview-to').text(route.legs[0].end_address)
  $('#distance').text(route.legs[0].distance.text)
  $('#duration').text(route.legs[0].duration.text)
  $('#copyrights').text(route.copyrights)
  $('#map-result-j').show()
  const routeKm = (Number)(route.legs[0].distance.value / 1000)
  const routeGasoline = routeKm * (Number)($('#fuel-help').data('avg-consumption'))
  $('#fuel-help-text').text(I18n.t('javascript.fuel_help_text', { km: routeKm.toFixed(2), est: Math.ceil(routeGasoline), avg_consumption: $('#fuel-help').data('avg-consumption'), fuel_currency: $('html').data('fuelCurrency'), currency: $('html').data('currency') }))
  $('#fuel-help').show()
  $('#itinerary_fuel_cost').val(Math.ceil(routeGasoline))

  const rleg = route.legs[0]

  const data = {
    start_location: [rleg.start_location.lng(), rleg.start_location.lat()],
    end_location: [rleg.end_location.lng(), rleg.end_location.lat()],
    via_waypoints: [],
    overview_path: [],
    overview_polyline: route.overview_polyline
  }

  for (const waypoint of Array.from(rleg.via_waypoints)) {
    data.via_waypoints.push([waypoint.lng(), waypoint.lat()])
  }

  // Show a link to remove waypoints
  if (rleg.via_waypoints.length > 0) {
    $('#remove-waypoints-link').show()
  } else {
    $('#remove-waypoints-link').hide()
  }

  for (const point of Array.from(route.overview_path)) {
    data.overview_path.push([point.lng(), point.lat()])
  }

  window.icare.route = data
  return $('#itinerary_route').val(JSON.stringify(data))
}

const wizardPrevStep = function () {
  let step = (Number)($('div[data-step]:visible').data('step'))
  if (step <= 1) { return }

  return $(`#wizard-step-${step}-content`).fadeOut(function () {
    $('#wizard-next-step-button').prop('disabled', false).show()
    $('#new_itinerary_submit-j').prop('disabled', true).hide()

    $(`#wizard-step-${step}-title`).addClass('hidden-xs').removeClass('active')

    $(`#wizard-step-${step}-title`)
      .removeClass('hidden-xs').addClass('active')

    --step

    $(`#wizard-step-${step}-content`).fadeIn()

    if (step === 1) {
      $('#wizard-prev-step-button-j').prop('disabled', true).hide()
    }

    return $(window).scrollTop(`#wizard-step-${step}-title`)
  })
}

const wizardNextStep = function () {
  // Run validations
  if ($('#itinerary_route').val() === '') {
    $('#map-error-j').text(I18n.t('javascript.setup_route_first')).show()
    return false
  }

  let valid = true
  $('#new_itinerary [data-validate]:input:visible').each(function () {
    const {
      validators
    } = this.form.ClientSideValidations.settings
    if (!$(this).isValid(validators)) { valid = false }
  })
  if (!valid) { return false }

  let step = (Number)($('div[data-step]:visible').data('step'))
  const lastStep = (Number)($('div[data-step]').last().data('step'))

  if (step === lastStep) {
    return false
  }

  return $(`#wizard-step-${step}-content`).fadeOut(function () {
    $(`#wizard-step-${step}-title`)
      .removeClass('active').addClass('hidden-xs')

    ++step

    if (step === lastStep) {
      lastStepInit()
    }
    $(`#wizard-step-${step}-title`).removeClass('hidden-xs').addClass('active')

    $(`#wizard-step-${step}-content`).fadeIn(function () {
      $('#new_itinerary').enableClientSideValidations() // Enable validation for new fields
      return $(window).scrollTop(`#wizard-step-${step}-title`)
    })

    if (step > 1) {
      $('#wizard-prev-step-button-j').prop('disabled', false).show()
      if (step === lastStep) {
        $('#wizard-next-step-button').prop('disabled', true).hide()
        return $('#new_itinerary_submit-j').prop('disabled', false).show()
      }
    }
  })
}

var lastStepInit = function () {
  const {
    route
  } = window.icare
  const $itineraryPreviewImage = $('#itinerary-preview-image')
  const googleMapsApiKey = $itineraryPreviewImage.data('googleMapsApiKey')
  return $itineraryPreviewImage.attr('src', `https://maps.googleapis.com/maps/api/staticmap?size=640x360&scale=2&markers=color:green|label:B|${route.end_location[1]},${route.end_location[0]}&markers=color:green|label:A|${route.start_location[1]},${route.start_location[0]}&path=enc:${route.overview_polyline}&key=${googleMapsApiKey}`)
}

const setRoute = function (dr, result) {
  dr.setDirections(result)
  dr.setOptions({
    polylineOptions: {
      strokeColor: '#0000ff',
      strokeWeight: 5,
      strokeOpacity: 0.45
    }
  })
  return dr.map.fitBounds(dr.directions.routes[0].bounds)
}
// dr.setOptions
//  suppressMarkers: true

const getWaypoints = function () {
  try {
    return Array.from(JSON.parse($('#itinerary_via_waypoints').val())).map((point) => (
      { location: new google.maps.LatLng(point[1], point[0]), stopover: false }))
  } catch (e) {
    return []
  }
}

const calculateRoute = function (dr, ds) {
  if (($('#itinerary_start_address').val() === '') || ($('#itinerary_end_address').val() === '')) { return }
  $('#itineraries-spinner-j').show()
  $('#map-error-j').hide()
  $('#map-result-j').hide()
  $('#route-helper').hide()
  $('#copyrights').text('')
  $('#distance').text('')
  $('#duration').text('')
  return ds.route({
    origin: $('#itinerary_start_address').val(),
    destination: $('#itinerary_end_address').val(),
    travelMode: 'DRIVING', // $("#mode").val()
    avoidHighways: $('#itinerary_avoid_highways').prop('checked'),
    avoidTolls: $('#itinerary_avoid_tolls').prop('checked'),
    waypoints: getWaypoints()
  }
  , function (result, status) {
    $('#itineraries-spinner-j').hide()
    if (status === google.maps.DirectionsStatus.OK) {
      return setRoute(dr, result)
    } else {
      let message
      switch (status) {
        case 'NOT_FOUND':
          message = I18n.t('javascript.not_found')
          break
        case 'ZERO_RESULTS':
          message = I18n.t('javascript.zero_results')
          break
        default:
          message = status
      }
      return $('#map-error-j').text(message).show()
    }
  })
}

const createRouteMapInit = function (id) {
  const map = icare.initGoogleMaps(id)

  const dr = new google.maps.DirectionsRenderer({
    map,
    draggable: true,
    preserveViewport: true
  })

  const ds = new google.maps.DirectionsService()

  google.maps.event.addListener(dr, 'directions_changed', function () {
    map.fitBounds(dr.directions.routes[0].bounds)
    setItinerary(dr.getDirections().routes[0])
    return $('#new_itinerary_submit-j').prop('disabled', false)
  })

  const $itineraryAddressInputs = $('#itinerary_start_address, #itinerary_end_address')

  // Get Route acts as submit
  $itineraryAddressInputs.on('keypress', function (e) {
    if (e && (e.keyCode === 13)) {
      e.preventDefault()
      return calculateRoute(dr, ds)
    }
  })

  $('#get-route').on('click', function () {
    let valid = true
    $('[data-validate]:input:visible').each(function () {
      const {
        validators
      } = this.form.ClientSideValidations.settings
      if (!$(this).isValid(validators)) { valid = false }
    })
    if (!valid) { return }
    return calculateRoute(dr, ds)
  })

  // Set route if it's already available
  return calculateRoute(dr, ds)
}

const initItineraryNew = function () {
  createRouteMapInit('#new-itinerary-map')
  $('#wizard-next-step-button').on('click', wizardNextStep)
  $('#wizard-prev-step-button-j').on('click', wizardPrevStep)
  return $('input[name="itinerary[daily]"]').change(function () {
    if (($(this).val() === 'true')) {
      return $('#single').fadeOut(() => $('#daily').fadeIn())
    } else {
      return $('#daily').fadeOut(() => $('#single').fadeIn())
    }
  })
}

$(document).on(window.initializeOnEvent, function () {
  if ((typeof google !== 'undefined' && google !== null) && ($('#new_itinerary')[0] != null)) {
    return initItineraryNew()
  }
})
