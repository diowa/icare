source 'https://rubygems.org'

ruby '2.2.0'
gem 'rails', '4.2.0'

# Servers
gem 'thin'
gem 'unicorn'

# Multi-environment configuration
gem 'simpleconfig'

# API
gem 'rabl'

# ODM and related
gem 'client_side_validations', github: 'DavyJonesLocker/client_side_validations'
gem 'client_side_validations-turbolinks', github: 'DavyJonesLocker/client_side_validations-turbolinks'
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
gem 'coffee-rails', '~> 4.1.0'
gem 'slim_assets'
gem 'handlebars_assets'
gem 'i18n-js'
gem 'jquery-turbolinks'
gem 'sass-rails', '~> 5.0'
gem 'twbs_sass_rails'
gem 'turbolinks'
gem 'uglifier', '>= 1.3.0'

gem 'icare-engine', github: 'ismaild/icare-engine'

group :development, :test do
  gem 'bullet'
  gem 'byebug'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-rails'
  gem 'web-console', '~> 2.0'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
  gem 'quiet_assets'
  gem 'spring'
  gem 'spring-commands-rspec'
end

group :test do
  gem 'capybara'
  gem 'coveralls', require: false
  gem 'mongoid-tree' # NOTE: DatabaseCleaner/database_cleaner issue #299
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
end
