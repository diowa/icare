const ESLintPlugin = require('eslint-webpack-plugin')
const StyleLintPlugin = require('stylelint-webpack-plugin')
const { resolve } = require('path')

module.exports = {
  envSpecificConfig: {
    plugins: [
      new ESLintPlugin({
        overrideConfigFile: resolve(__dirname, '../../eslint.config.mjs'),
        configType: 'flat',
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
