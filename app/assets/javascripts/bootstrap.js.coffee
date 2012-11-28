'use strict'

# jQuery Turbolinks
$ ->
  $('a[rel~="tooltip"],i[rel~="tooltip"]').tooltip()

# 2.2.1 Mobile dropdown fix
$(document).on 'touchstart.dropdown.data-api', 'a.dropdown-toggle, .dropdown-menu, .dropdown-menu a, .dropdown-menu .dropdown-submenu a', (e) ->
  e.stopPropagation()
