"use strict"

do_on_load = ->
  $("a[rel~=tooltip],i[rel~=tooltip]").tooltip()

# Turbolinks
$(document).ready do_on_load
$(window).bind 'page:change', do_on_load
