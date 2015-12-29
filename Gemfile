source 'https://rubygems.org'

ruby '2.3.0'
gem 'rails', '4.2.5'

# Servers
gem 'thin'

# Multi-environment configuration
gem 'simpleconfig'

# API
gem 'rabl'

# ODM and related
gem 'client_side_validations', github: 'DavyJonesLocker/client_side_validations'
gem 'client_side_validations-simple_form', github: 'DavyJonesLocker/client_side_validations-simple_form'
gem 'kaminari'
gem 'mongoid'
gem 'mongoid_geospatial'
gem 'mongoid_paranoia'
gem 'mongoid-slug'
gem 'jc-validates_timeliness'

# Authentication framework
gem 'devise'

# Geospatial data library
gem 'rgeo'

# Facebook integration
gem 'koala'
gem 'omniauth-facebook'

# Performance and Exception management
gem 'airbrake'
gem 'newrelic_rpm'
gem 'newrelic_moped'

# Security
gem 'secure_headers'

# Miscellanea
gem 'google-analytics-rails'
gem 'slim-rails'
gem 'http_accept_language'
gem 'jquery-rails'
gem 'resque', require: 'resque/server' # Resque web interface

# Assets
gem 'autoprefixer-rails'
gem 'coffee-rails', '~> 4.1.1'
gem 'slim_assets'
gem 'handlebars_assets'
gem 'i18n-js'
gem 'jquery-turbolinks'
gem 'sass-rails', '~> 5.0'
gem 'sprockets'
gem 'sprockets-rails', '~> 2.3' # TODO: https://github.com/leshill/handlebars_assets/issues/145
gem 'twbs_sass_rails'
gem 'turbolinks'
gem 'uglifier', '>= 1.3.0'

group :development, :test do
  gem 'bullet'
  gem 'byebug'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-rails'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
  gem 'quiet_assets'
  gem 'rubocop'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'coveralls', require: false
  gem 'database_cleaner'
  gem 'email_spec'
  gem 'launchy'
  gem 'mongoid-rspec'
  gem 'selenium-webdriver'
  gem 'rspec'
  gem 'simplecov', require: false
  gem 'webmock', require: false
end

group :staging, :production do
  gem 'rails_12factor' # Only for heroku
  gem 'unicorn'
end
