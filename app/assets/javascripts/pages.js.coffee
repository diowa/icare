###global clientSideValidations:false###
'use strict'

# Prevent disabled links from being clicked
$('a.disabled').on 'click', (e) ->
  e.preventDefault()

$ ->
  # Client Side Validations
  clientSideValidations.callbacks.element.fail = (element, message, callback) ->
    if (!element.data('valid'))
      element.closest('div.control-group').addClass 'error'

      if element.closest('form').hasClass 'form-inline'
        error_message = "<label for='#{element.attr("id")}' class='message'>#{message}</label>"
        $error_container = element.parent().find 'label.message'
      else
        error_message = "<span class='help-inline'>#{message}</span>"
        if element.parent().hasClass('input-prepend') or element.parent().hasClass('input-append')
          $error_container = element.parent().parent().find 'span.help-inline'
        else
          $error_container = element.parent().find 'span.help-inline'

      if $error_container[0]
        $error_container.text(message).show()
      else
        if element.parent().hasClass('input-prepend') or element.parent().hasClass('input-append')
          element.parent().after error_message
        else
          element.parent().find("#{element[0].tagName}:last").after error_message
    return

  clientSideValidations.callbacks.element.pass = (element, callback) ->
    element.closest('div.control-group').removeClass 'error'
    element.parent().find('label.message').hide()
    if element.parent().hasClass('input-prepend') or element.parent().hasClass('input-append')
      element.parent().parent().find('span.help-inline').hide()
    else
      element.parent().find('span.help-inline').hide()
    return
