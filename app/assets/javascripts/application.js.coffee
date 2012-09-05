#= require jquery
#= require jquery_ujs
#= require jquery.ba-throttle-debounce

#= require rails.validations

#= require twitter/bootstrap

#= require handlebars

#= require_tree .

"use strict"

String::capitalize = ->
  this.replace /(?:^|\s)\S/g, (c) ->
    c.toUpperCase()
