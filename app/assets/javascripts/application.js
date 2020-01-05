// VENDOR ASSETS
//= require jquery.ba-throttle-debounce

// JS TEMPLATES
//= require handlebars.runtime

// I18n
//= require i18n
//= require i18n/translations

//= require_tree .

window.icare = window.icare || {}

I18n.defaultLocale = document.documentElement.getAttribute('data-default-lang')
I18n.locale = document.documentElement.lang
