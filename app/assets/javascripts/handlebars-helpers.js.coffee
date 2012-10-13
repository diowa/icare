Handlebars.registerHelper 'toLowerCase', (string) ->
  if string
    new Handlebars.SafeString string.toLowerCase()
  else
    ''

Handlebars.registerHelper 'translate', (key) ->
  new Handlebars.SafeString I18n.t(key)

Handlebars.registerHelper 'localize', (scope, key) ->
  new Handlebars.SafeString I18n.l(scope, key)
