startSpinner = ->
  @spinner ||= setTimeout ->
    document.getElementById('turbolinks-spinner').style.display = 'block'
  , 250

stopSpinner = ->
  clearTimeout @spinner
  @spinner = null
  document.getElementById('turbolinks-spinner').style.display = 'none'

# Turbolinks Spinner
if document.addEventListener?
  document.addEventListener 'page:fetch', startSpinner
  document.addEventListener 'page:receive', stopSpinner
