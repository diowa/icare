###global $:false, I18n:false, HandlebarsTemplates:false###

'use strict'

# Needed to follow links in popovers
$(document).on 'click', '.popover a', (e) ->
  e.stopPropagation()

$(document).on 'click', '.notifications', (e) ->
  e.preventDefault()
  $this = $(this)
  $('.notifications').not("##{$this.attr('id')}").removeClass('active').find('a').popover 'hide'
  $this.toggleClass 'active'
  false

$(document).on 'shown.bs.popover', (e) ->
  $target = $(e.target)
  $popover = $target.closest('.notifications').find('.popover')
  if remote = $target.data('remote')
    $.ajax
      url: remote
      success: (data) ->
        messages = ''
        for message in data
          messages += HandlebarsTemplates['messages/show_in_popup'](message)
        if data.length > 0
          $target.find('span.count').text data.length
          $('.popover-content').html """
            <ul class="unstyled popover-elements">
              #{messages}
            </ul>
          """
        else
          $target.find('span.count').remove()
          $popover.find('.popover-content').text I18n.t('shared.navbar.no_new_messages')
