'use strict'

initUserEdit = ->
  ###
  if $('#fuel-cost-calculator')[0]?
    $('#save-fuel-cost').on 'click', ->
      $('#user_vehicle_avg_consumption').val $('#fuel_price').val()
  ###
  $('select[id=user_nationality]').change (event) ->
    $this = $(this)
    code = $this.val()
    flag = if code isnt '' then "flag-#{code.toLowerCase()}" else ''
    $('#flag').attr 'class', flag

do_on_load = ->
  setTimeout ->
    $('li.unread').removeClass 'unread'
  , 5000
  if $('form[id^=edit_user]')[0]?
    new initUserEdit()

# Turbolinks
$(document).ready do_on_load
$(window).bind 'page:change', do_on_load
