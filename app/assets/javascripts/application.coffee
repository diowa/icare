#= require jquery
#= require jquery_ujs
#= require jquery.turbolinks
#= require turbolinks

# VENDOR ASSETS
#= require jquery.ba-throttle-debounce

# CLIENT SIDE VALIDATIONS
#= require rails.validations
#= require rails.validations.simple_form

# BOOTSTRAP
#= require twbs/bootstrap/transition
#= require twbs/bootstrap/alert
#= require twbs/bootstrap/button
# require twbs/bootstrap/carousel
#= require twbs/bootstrap/collapse
#= require twbs/bootstrap/dropdown
#= require twbs/bootstrap/modal
#= require twbs/bootstrap/tooltip
#= require twbs/bootstrap/popover
# require twbs/bootstrap/scrollspy
# require twbs/bootstrap/tab
# require twbs/bootstrap/affix

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
