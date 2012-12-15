###global $:false###

'use strict'

initUserEdit = ->
  $('select[id="user_nationality"]').change (event) ->
    code = $(this).val()
    flag = if code isnt '' then "flag-#{code.toLowerCase()}" else ''
    $('#flag').attr 'class', flag

# jQuery Turbolinks
$ ->
  setTimeout ->
    $('li.unread').removeClass 'unread'
  , 5000
  if $('form[id^="edit_user"]')[0]?
    initUserEdit()
