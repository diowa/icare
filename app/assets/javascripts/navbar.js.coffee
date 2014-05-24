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
  if $target.data('remote')
    $.ajax
      url: $target.data('remote')
      beforeSend: ->
        $('.popover-content').html $('.popover-ajax-spinner').html()
      success: (messages) ->
        $target.data('unread', messages.length).find('span.unread-count').text(if messages.length > 0 then messages.length else '')
        if messages.length > 0
          $('.popover-content').html HandlebarsTemplates['notifications/messages']({ messages: messages })
        else
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
      false
    ).popover
      placement: 'bottom'
      template: HandlebarsTemplates['notifications/base'](popoverData)
      title: I18n.t("javascript.notifications.#{notificationsType}.title")
