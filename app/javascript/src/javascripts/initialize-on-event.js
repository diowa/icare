window.initializeOnEvent =
  (window.Turbolinks != null) && window.Turbolinks.supported
    ? 'turbolinks:load'
    : 'ready'
