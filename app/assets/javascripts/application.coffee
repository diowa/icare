#= require jquery3
#= require jquery_ujs
#= require turbolinks
#= require initialize_on_event

# VENDOR ASSETS
#= require jquery.ba-throttle-debounce

# CLIENT SIDE VALIDATIONS
#= require rails.validations
#= require rails.validations.simple_form.bootstrap4

# BOOTSTRAP
#= require bootstrap

# HANDLEBARS TEMPLATES
#= require handlebars.runtime

# I18n
#= require i18n
#= require i18n/translations

# ALL THE REST
#= require_tree .

window.icare = window.icare || {}
icare = window.icare

I18n.locale = $('html').attr 'lang'

String::capitalize = ->
  this.replace /(?:^|\s)\S/g, (c) ->
    c.toUpperCase()

String::lpad = (padString, length) ->
  str = this
  while str.length < length
    str = padString + str
  str
