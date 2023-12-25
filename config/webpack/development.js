const ESLintPlugin = require('eslint-webpack-plugin')
const StyleLintPlugin = require('stylelint-webpack-plugin')

module.exports = {
  envSpecificConfig: {
    plugins: [
      new ESLintPlugin({
        failOnError: false,
        files: 'app/javascript/**/*.js',
        exclude: 'app/javascript/**/vendor/*.js'
      }),
      new StyleLintPlugin({
        failOnError: false,
        files: 'app/javascript/**/*.(s(c|a)ss|css)'
      })
    ]
  }
}
