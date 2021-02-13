/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
$(document).on('show.bs.popover', '.notifications', function (e) {
  const $notifications = $(e.target).closest('.notifications').addClass('active')
  return $('.notifications').not($notifications).removeClass('active').find('a').popover('hide')
})

$(document).on('hide.bs.popover', '.notifications', e => $(e.target).closest('.notifications').removeClass('active'))

$(document).on('shown.bs.popover', '.notifications', function (e) {
  const $target = $(e.target)
  const $popover = $target.closest('.notifications').find('.popover')
  if ($target.data('remote')) {
    return $.ajax({
      url: $target.data('remote'),
      beforeSend () {
        return $('.popover-body').html($('.popover-body-loading').html())
      },
      success (messages) {
        $target.data('unread', messages.length).find('span.unread-count').text(messages.length > 0 ? messages.length : '')
        if (messages.length > 0) {
          return $('.popover-body').html(HandlebarsTemplates['notifications/messages']({ messages }))
        } else {
          return $popover.find('.popover-body').text(I18n.t(`javascript.notifications.${$target.data('notificationsType')}.no_new`))
        }
      }
    })
  }
})

$(document).on(window.initializeOnEvent, () => $('.notifications').each(function () {
  const $target = $(this).find('> a')
  const unread = $target.data('unread')
  if (unread > 0) { $target.find('.unread-count').text(unread).show() }

  const notificationsType = $target.data('notificationsType')
  const popoverData = {
    footer_url: $target.attr('href'),
    no_notifications_text: I18n.t(`javascript.notifications.${notificationsType}.no_new`),
    footer_link_text: I18n.t(`javascript.notifications.${notificationsType}.see_all`)
  }

  return $target.on('click', function (e) {
    e.preventDefault()
    return false
  }).popover({
    placement: 'bottom',
    html: true,
    container: $(this),
    template: HandlebarsTemplates['notifications/base'](popoverData),
    title: I18n.t(`javascript.notifications.${notificationsType}.title`)
  })
}))
