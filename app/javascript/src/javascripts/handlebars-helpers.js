/* eslint-disable no-new */
Handlebars.registerHelper('toLowerCase', function (string) {
  if (!string) { return '' }
  return new Handlebars.SafeString(string.toLowerCase())
})

Handlebars.registerHelper('translate', key => new Handlebars.SafeString(I18n.t(key)))

Handlebars.registerHelper('localize', (scope, key) => new Handlebars.SafeString(I18n.l(scope, key)))

Handlebars.registerHelper('currency', key => new Handlebars.SafeString(`${key}${$('html').data('currency')}`))
/* eslint-enable no-new */
