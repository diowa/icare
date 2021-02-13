// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import {} from 'jquery-ujs'

require.context('../images', true)

require('turbolinks').start()

require('src/initialize-on-event')

require('src/bootstrap')
require('src/fontawesome')

require('src/vendor/i18n-translations')

require('src/handlebars')
require('src/conversations')
require('src/forms')
require('src/maps')
require('src/maps-new')
require('src/maps-search')
require('src/navbar')
require('src/pages')

// Expose jQuery to window
window.$ = window.jQuery = $
