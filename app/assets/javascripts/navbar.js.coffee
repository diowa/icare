"use strict"

$ ->
  $('.notifications').on 'click', (e) ->
    e.preventDefault()
    $me = $(this)
    $(".notifications").not("##{$me.attr('id')}").removeClass('active').find('a').popover 'hide'
    $me.toggleClass('active').find('a').popover 'toggle'
    false
