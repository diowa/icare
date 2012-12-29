###global $:false###

'use strict'

# jQuery Turbolinks
$ ->
  setTimeout ->
    $('li.unread').removeClass 'unread'
  , 5000
