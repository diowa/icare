process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const environment = require('./environment')
const StyleLintPlugin = require('stylelint-webpack-plugin')

environment.plugins.append(
  'StyleLintPlugin',
  new StyleLintPlugin({
    emitWarning: true,
    files: '/app/**/*.(s(c|a)ss|css)'
  })
)

environment.loaders.insert('standard-loader', {
  loader: 'standard-loader',
  test: /\.js$/,
  exclude: /vendor\/.+\.js$/,
  options: {
    globals: [
      '$',
      'ClientSideValidations',
      'google',
      'Handlebars',
      'HandlebarsTemplates',
      'I18n',
      'InfoBox',
      'initGoogleMaps'
    ]
  }
}, { after: 'babel'} )

module.exports = environment.toWebpackConfig()
