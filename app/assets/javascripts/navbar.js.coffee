###global $:false, I18n:false, HandlebarsTemplates:false###

'use strict'

# Needed to follow links in popovers
$(document).on 'click', '.popover a', (e) ->
  e.stopPropagation()

$(document).on 'click', '.notifications', (e) ->
  e.preventDefault()
  $me = $(this)
  $('.notifications').not("##{$me.attr('id')}").removeClass('active').find('a').popover 'hide'
  $popoverElement = $me.toggleClass('active').find 'a'
  if $me.find('.popover')[0]?
    $popoverElement.popover 'hide'
  else
    $popoverElement.popover 'show'
  if $('.popover.in')[0]? and $popoverElement.data('load')?
    $.ajax
      url: $popoverElement.data 'load'
      success: (data) ->
        messages = ''
        for message in data
          messages += HandlebarsTemplates['messages/show_in_popup'](message)
        if data.length > 0
          $popoverElement.find('span.count').text data.length
          $('.popover-ajax-content').html """
            <ul class="unstyled popover-elements">
              #{messages}
            </ul>
          """
        else
          $popoverElement.find('span.count').remove()
          $('.popover-ajax-content').html I18n.t('shared.navbar.no_new_messages')
  false
