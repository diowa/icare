###global $:false, I18n:false, HandlebarsTemplates:false###

'use strict'

# Needed to follow links in popovers
$(document).on 'click', '.popover a', (e) ->
  e.stopPropagation()

$(document).on 'show.bs.popover', '.notifications', (e) ->
  $notifications = $(e.target).closest('.notifications').addClass 'active'
  $('.notifications').not($notifications).removeClass('active').find('a').popover 'hide'

$(document).on 'hide.bs.popover', '.notifications', (e) ->
  $(e.target).closest('.notifications').removeClass 'active'

$(document).on 'shown.bs.popover', '.notifications', (e) ->
  $target = $(e.target)
  $popover = $target.closest('.notifications').find('.popover')
  if remote = $target.data('remote')
    $.ajax
      url: remote
      beforeSend: ->
        $('.popover-content').html $('.popover-ajax-spinner').html()
      success: (messages) ->
        if messages.length > 0
          $target.find('span.count').text messages.length
          $('.popover-content').html HandlebarsTemplates['notifications/messages']
            messages: messages
        else
          $target.find('span.count').remove()
          $popover.find('.popover-content').text I18n.t("javascript.notifications.#{$target.data('notificationsType')}.no_new")

$ ->
  $('.notifications').each ->
    $target = $(this).find('> a')
    unread = $target.data('unread')
    $target.find('.unread-count').text(unread).show() if unread > 0

    notificationsType = $target.data('notificationsType')
    popoverData =
      footer_url: $target.attr('href')
      no_notifications_text: I18n.t("javascript.notifications.#{notificationsType}.no_new")
      footer_link_text: I18n.t("javascript.notifications.#{notificationsType}.see_all")

    $target.on('click', (e) ->
      e.preventDefault()
    ).popover
      placement: 'bottom'
      title: I18n.t("javascript.notifications.#{notificationsType}.title")
      template: HandlebarsTemplates['notifications/base'](popoverData)
