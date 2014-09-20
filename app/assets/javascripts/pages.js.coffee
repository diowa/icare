# Prevent disabled links from being clicked
# Bind to document, so this is compatible with turbolinks
$(document).on 'click', 'a.disabled', (e) ->
  e.preventDefault()

$(document).on 'click', '.btn-learn-more', (e) ->
  e.preventDefault()
  $('html, body').animate
    scrollTop: $('#learn-more').offset().top
  , 'slow'
