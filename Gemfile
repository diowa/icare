source 'https://rubygems.org'

ruby '1.9.3'
gem 'rails', '3.2.9'

# Servers
gem 'thin'
gem 'unicorn'

# Multi-environment configuration
gem 'simpleconfig'

# API
gem 'rabl'

# ODM and related
gem 'client_side_validations'
gem 'client_side_validations-turbolinks'
gem 'kaminari'
gem 'mongoid'
gem 'mongoid_geospatial'
gem 'mongoid_slug'
gem 'validates_timeliness'

# Geospatial data library
gem 'rgeo'

# Facebook integration
gem 'koala'
gem 'omniauth-facebook'

# Performance and Exception management
gem 'airbrake'
gem 'newrelic_rpm'
gem 'newrelic_moped'

# Miscellanea
gem 'google-analytics-rails'
gem 'haml'
gem 'http_accept_language'
gem 'jquery-rails'
gem 'nokogiri'
gem 'resque', require: 'resque/server' # Resque web interface
gem 'rest-client'
#gem 'wicked'


group :development, :test do
  gem 'bullet'
  gem 'debugger'
  gem 'delorean'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'pry'
  gem 'pry-rails'
end

group :test do
  gem 'action_mailer_cache_delivery'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'email_spec'
  gem 'launchy'
  gem 'mongoid-rspec'
  gem 'rspec-rails', '~> 2.6'
  gem 'simplecov', require: false
  gem 'spork', '~> 1.0rc'
  gem 'webmock', require: false
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails'
  gem 'compass-rails'
  gem 'haml_assets'
  gem 'handlebars_assets'
  gem 'i18n-js'
  gem 'jquery-turbolinks'
  gem 'less-rails'
  gem 'sass-rails'
  gem 'therubyracer', '0.10.2' # NOTE can't update due to libv8 version on heroku
  gem 'turbolinks'
  gem 'twitter-bootstrap-rails'
  gem 'uglifier'
end
