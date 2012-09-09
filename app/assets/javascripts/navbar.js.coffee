'use strict'

$ ->
  $('.notifications').on 'click', (e) ->
    e.preventDefault()
    $me = $(this)
    $(".notifications").not("##{$me.attr('id')}").removeClass('active').find('a').popover 'hide'
    $popoverElement = $me.toggleClass('active').find('a')
    $popoverElement.popover 'toggle'
    if $('.popover.in')[0]? and $popoverElement.data("load")?
      $.ajax
        url: $popoverElement.data('load')
        success: (data) ->
          messages = ''
          for message in data
            messages += HandlebarsTemplates['message'](message)
          if data.length > 0
            $popoverElement.find('span.count').text data.length
            $('.popover-ajax-content').html """
              <ul class="unstyled popover-elements">
                #{messages}
              </ul>
            """
          else
            $popoverElement.find('span.count').remove()
            $('.popover-ajax-content').html """
              #{$('#navbar-translations').data('no_new_messages')}
            """
    false
