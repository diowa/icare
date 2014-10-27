Handlebars.registerHelper 'toLowerCase', (string) ->
  return '' unless string
  new Handlebars.SafeString string.toLowerCase()

Handlebars.registerHelper 'translate', (key) ->
  new Handlebars.SafeString I18n.t(key)

Handlebars.registerHelper 'localize', (scope, key) ->
  new Handlebars.SafeString I18n.l(scope, key)

Handlebars.registerHelper 'currency', (key) ->
  new Handlebars.SafeString "#{key}#{$('html').data('currency')}"
