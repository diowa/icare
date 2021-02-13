import Handlebars from 'handlebars/runtime'

window.HandlebarsTemplates = {}
window.HandlebarsTemplates.gmaps_popup = require('./templates/gmaps_popup.handlebars')
window.HandlebarsTemplates['itineraries/thumbnail'] = require('./templates/itineraries/thumbnail.handlebars')
window.HandlebarsTemplates['notifications/base'] = require('./templates/notifications/base.handlebars')
window.HandlebarsTemplates['notifications/messages'] = require('./templates/notifications/messages.handlebars')

Handlebars.registerHelper('toLowerCase', function (string) {
  if (!string) { return '' }
  return new Handlebars.SafeString(string.toLowerCase())
})

Handlebars.registerHelper('translate', key => new Handlebars.SafeString(I18n.t(key)))

Handlebars.registerHelper('localize', (scope, key) => new Handlebars.SafeString(I18n.l(scope, key)))

Handlebars.registerHelper('currency', key => new Handlebars.SafeString(`${key}${$('html').data('currency')}`))
