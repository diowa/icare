#= require jquery
#= require jquery_ujs

# VENDOR ASSETS
#= require jquery.ba-throttle-debounce
#= require waypoints

# GEMS
#= require rails.validations
#= require twitter/bootstrap
#= require handlebars

# ALL THE REST
#= require_tree .

'use strict'

String::capitalize = ->
  this.replace /(?:^|\s)\S/g, (c) ->
    c.toUpperCase()
