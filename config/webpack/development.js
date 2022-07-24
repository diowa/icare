const StyleLintPlugin = require('stylelint-webpack-plugin')

module.exports = {
  envSpecificConfig: {
    module: {
      rules: [
        {
          test: /\.js$/,
          exclude: /vendor\/.+\.js$/,
          loader: 'standard-loader',
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
        }
      ]
    },
    plugins: [
      new StyleLintPlugin({
        failOnError: false,
        files: 'app/javascript/**/*.(s(c|a)ss|css)'
      })
    ]
  }
}
