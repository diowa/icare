const { environment } = require('@rails/webpacker')

const webpack = require('webpack')

// resolve-url-loader must be used before sass-loader
environment.loaders.get('sass').use.splice(-1, 0, {
  loader: 'resolve-url-loader'
});

environment.loaders.append('handlebars-loader', {
  test: /\.handlebars$/,
  use: 'handlebars-loader'
})

// Add an additional plugin of your choosing : ProvidePlugin
environment.plugins.prepend(
  'Provide',
  new webpack.ProvidePlugin({
    // jQuery
    $: 'jquery',
    jQuery: 'jquery',
    jquery: 'jquery',

    // Window
    'window.jQuery': 'jquery',

    // I18n
    'I18n': 'i18n-js'
  })
)

environment.loaders.prepend('expose', {
  test: require.resolve('jquery'),
  use: {
    loader: 'expose-loader',
    options: {
      exposes: ['$', 'jQuery']
    }
  }
})

// export the updated config
module.exports = environment
