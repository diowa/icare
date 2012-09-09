"use strict"

$ ->
  setTimeout ->
    $("li.unread").removeClass "unread"
  , 5000

  if $("#fuel-cost-calculator")[0]?
    $("#save-fuel-cost").on "click", ->
      $("#user_vehicle_avg_consumption").val $("#fuel_price").val()

  $("select[id='user_nationality']").change (event) ->
    $this = $(this)
    code = $this.val()
    flag = if code != "" then "flag-#{code.toLowerCase()}" else ""
    $("#flag").attr "class", flag

if $("#profilenav")[0]?
  $win = $(window)
  $nav = $('#profilenav')
  navTop = $nav.length && $nav.offset().top - 40
  isFixed = 0

  processScroll = ->
    scrollTop = $win.scrollTop()
    if (scrollTop >= navTop && !isFixed)
      isFixed = 1
      $nav.addClass "profilenav-fixed"
    else if (scrollTop <= navTop && isFixed)
      isFixed = 0
      $nav.removeClass "profilenav-fixed"
    return

  processScroll()

  $nav.on "click", ->
    setTimeout -> $win.scrollTop($win.scrollTop() - 47),
    10 unless isFixed
    return

  $win.on "scroll", $.throttle(250, processScroll)
