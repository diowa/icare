"use strict"

$("a[id^=navbar-notifications-]").popover().click (e) ->
  e.preventDefault()
  $me = $(this)
  $("a[id^=navbar-notifications-]").each ->
    $this = $(this)
    if $me.attr("id") is $this.attr("id")
      $(this).popover('toggle')
    else
      $(this).popover('hide')
    return
