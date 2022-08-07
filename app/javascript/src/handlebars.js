import Handlebars from 'handlebars/runtime'

import i18n from './i18n'

window.HandlebarsTemplates = {}
window.HandlebarsTemplates.gmaps_popup = require('./templates/gmaps_popup.handlebars')
window.HandlebarsTemplates['itineraries/thumbnail'] = require('./templates/itineraries/thumbnail.handlebars')
window.HandlebarsTemplates['notifications/base'] = require('./templates/notifications/base.handlebars')
window.HandlebarsTemplates['notifications/messages'] = require('./templates/notifications/messages.handlebars')

Handlebars.registerHelper('toLowerCase', function (string) {
  if (!string) { return '' }
  return new Handlebars.SafeString(string.toLowerCase())
})

Handlebars.registerHelper('translate', key => new Handlebars.SafeString(i18n.t(key)))

Handlebars.registerHelper('localize', (scope, key) => new Handlebars.SafeString(i18n.l(scope, key)))

Handlebars.registerHelper('currency', key => new Handlebars.SafeString(`${key}${$('html').data('currency')}`))
