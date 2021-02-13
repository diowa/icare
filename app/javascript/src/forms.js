require('@client-side-validations/client-side-validations')
require('@client-side-validations/simple-form/dist/simple-form.bootstrap4')

ClientSideValidations.callbacks.form.fail = ($form, eventData) => {
  const settings = $form[0].ClientSideValidations.settings

  $('html, body').animate(
    { scrollTop: $form.find(`.${settings.html_settings.wrapper_error_class}`).offset().top - $('.main-navbar').outerHeight() - 10 }
    , 250)
}

$(document).on('change', '#itinerary_round_trip', function () {
  const status = $(this).prop('checked')
  $('select[id^="itinerary_return_date"]').prop('disabled', !status)
})
