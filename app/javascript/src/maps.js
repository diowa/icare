window.icare = window.icare || {}

window.initMap = function () {
  class CustomMarker extends google.maps.OverlayView {
    constructor (position, map, opts) {
      super()
      this.position = position
      this._div = null
      this.setMap(map)
      $.extend(true, (this.options = {
        infoWindowContent: null,
        image: 'https://fbstatic-a.akamaihd.net/rsrc.php/v2/yo/r/UlIqmHJn-SK.gif',
        cssClasses: '',
        type: 'sprite',
        imageOverlay: null
      })
      , opts)
    }

    onAdd () {
      const me = this
      const div = document.createElement('div')
      div.style.position = 'absolute'

      switch (this.options.type) {
        case 'user_profile_picture': {
          div.setAttribute('class', `${this.options.cssClasses} arrow-box`)
          div.style.width = '29px'
          div.style.height = '29px'
          const img = document.createElement('img')
          img.setAttribute('width', '25px')
          img.setAttribute('height', '25px')
          img.setAttribute('alt', '')
          img.src = this.options.image
          div.appendChild(img)
          break
        }
        case 'sprite':
          div.setAttribute('class', this.options.cssClasses)
          div.style.border = 'none'
          div.style.width = '32px'
          div.style.height = '37px'
          div.style.cursor = 'pointer'
          break
      }

      this._div = div

      this.getPanes().overlayMouseTarget.appendChild(div)

      return google.maps.event.addDomListener(div, 'click', () => google.maps.event.trigger(me, 'click'))
    }

    draw () {
      const point = this.getProjection().fromLatLngToDivPixel(this.position)
      const width = parseInt(this._div.style.width, 10)
      let height = parseInt(this._div.style.height, 10)
      if (this.type === 'user_profile_picture') { height += 5 }
      if (point) {
        this._div.style.left = `${point.x - (width / 2)}px`
        this._div.style.top = `${point.y - height}px`
      }
    }

    onRemove () {
      if (this._div) {
        this._div.parentNode.removeChild(this._div)
        this._div = null
      }
    }
  }

  const initGoogleMaps = function (id) {
    const lightStyle = [
      { featureType: 'all', stylers: [] },
      {
        featureType: 'road',
        elementType: 'geometry',
        stylers: []
      },
      {
        featureType: 'poi',
        elementType: 'labels',
        stylers: [{ visibility: 'off' }]
      }
    ]

    const nightStyle = [
      { featureType: 'all', stylers: [] },
      { elementType: 'geometry', stylers: [{ color: '#242f3e' }] },
      { elementType: 'labels.text.stroke', stylers: [{ color: '#242f3e' }] },
      { elementType: 'labels.text.fill', stylers: [{ color: '#746855' }] },
      {
        featureType: 'administrative.locality',
        elementType: 'labels.text.fill',
        stylers: [{ color: '#d59563' }]
      },
      {
        featureType: 'poi',
        elementType: 'labels',
        stylers: [{ visibility: 'off' }]
      },
      {
        featureType: 'poi.park',
        elementType: 'geometry',
        stylers: [{ color: '#263c3f' }]
      },
      {
        featureType: 'poi.park',
        elementType: 'labels.text.fill',
        stylers: [{ color: '#6b9a76' }]
      },
      {
        featureType: 'road',
        elementType: 'geometry.stroke',
        stylers: [{ color: '#212a37' }]
      },
      {
        featureType: 'road',
        elementType: 'labels.text.fill',
        stylers: [{ color: '#9ca5b3' }]
      },
      {
        featureType: 'road.highway',
        elementType: 'geometry',
        stylers: [{ color: '#746855' }]
      },
      {
        featureType: 'road.highway',
        elementType: 'geometry.stroke',
        stylers: [{ color: '#1f2835' }]
      },
      {
        featureType: 'road.highway',
        elementType: 'labels.text.fill',
        stylers: [{ color: '#f3d19c' }]
      },
      {
        featureType: 'transit',
        elementType: 'geometry',
        stylers: [{ color: '#2f3948' }]
      },
      {
        featureType: 'transit.station',
        elementType: 'labels.text.fill',
        stylers: [{ color: '#d59563' }]
      },
      {
        featureType: 'water',
        elementType: 'geometry',
        stylers: [{ color: '#17263c' }]
      },
      {
        featureType: 'water',
        elementType: 'labels.text.fill',
        stylers: [{ color: '#515c6d' }]
      },
      {
        featureType: 'water',
        elementType: 'labels.text.stroke',
        stylers: [{ color: '#17263c' }]
      }
    ]

    let styleArray = lightStyle

    if (document.documentElement.dataset.bsTheme === 'dark') {
      styleArray = nightStyle
    }

    // defaults to Italy
    const elementData = $(id).data()
    const mapConfig = {
      center: elementData.mapCenter || [41.87194, 12.567379999999957],
      zoom: elementData.mapZoom || 8
    }

    const map = new google.maps.Map($(id)[0], {
      center: new google.maps.LatLng(mapConfig.center[0], mapConfig.center[1]),
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      scrollwheel: false,
      styles: styleArray,
      zoom: mapConfig.zoom
    }
    )
    return map
  }

  window.icare.CustomMarker = CustomMarker
  window.icare.initGoogleMaps = initGoogleMaps
}
