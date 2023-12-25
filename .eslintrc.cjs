module.exports = {
  root: true,
  extends: [
    'standard'
  ],
  globals: {
    '$': true,
    'ClientSideValidations': true,
    'google': true,
    'Handlebars': true,
    'HandlebarsTemplates': true,
    'I18n': true,
    'InfoBox': true,
    'initGoogleMaps': true
  },
  settings: {
    'import/resolver': {
      node: {
        paths: ['app/javascript']
      }
    }
  }
}
