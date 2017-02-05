window.initializeOnEvent =
  if window.Turbolinks? and window.Turbolinks.supported
    'turbolinks:load'
  else
    'ready'
