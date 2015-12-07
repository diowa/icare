if ClientSideValidations?
  errorClass = 'has-error'
  errorBlockClass = 'error-block'

  getErrorFields = (element) ->
    if element.closest('.input-group')[0]?
      [element.closest('.input-group').parent(), element.closest('.input-group').parent()]
    else if element.closest('form').hasClass 'form-horizontal'
      [element.closest('.form-group'), element.parent()]
    else
      [element.parent(), element.parent()]

  ClientSideValidations.callbacks.element.fail = (element, message, callback, eventData) ->
    unless element.data('valid')
      [$errorClassTarget, $errorMessageContainer] = getErrorFields(element)
      $errorClassTarget.addClass errorClass
      $errorMessageContainer.find(".#{errorBlockClass}").remove()
      $errorMessageContainer.append "<p class='help-block #{errorBlockClass}'>#{message}</p>"
    callback

  ClientSideValidations.callbacks.element.pass = (element, callback, eventData) ->
    [$errorClassTarget, $errorMessageContainer] = getErrorFields(element)
    $errorClassTarget.removeClass errorClass
    $errorMessageContainer.find(".#{errorBlockClass}").remove()
    callback

$(document).on 'change', '#itinerary_round_trip', ->
  status = $(this).prop 'checked'
  $('select[id^="itinerary_return_date"]').prop 'disabled', !status
