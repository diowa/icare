###global $:false###

'use strict'

$ ->
  setTimeout ->
    $('.list-conversation > .unread').removeClass 'unread'
  , 5000
