$(document).on window.initializeOnEvent, ->
  setTimeout ->
    $('.list-conversation > .unread').removeClass 'unread'
  , 5000
