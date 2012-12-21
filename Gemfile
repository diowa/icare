source 'https://rubygems.org'

ruby '1.9.3'
gem 'rails', '3.2.9'

gem 'unicorn'

gem 'mongoid'
gem 'mongoid_slug'
gem 'mongoid_geospatial'
gem 'thin'
gem 'haml'
gem 'omniauth-facebook'
gem 'koala'
gem 'validates_timeliness'
gem 'rest-client'
gem 'nokogiri'
gem 'http_accept_language'
gem 'jquery-rails'
gem 'client_side_validations'
gem 'client_side_validations-turbolinks'

#gem 'wicked'
gem 'resque', require: 'resque/server' # Resque web interface
gem 'kaminari'
gem 'rabl'
gem 'simpleconfig'
gem 'google-analytics-rails'
gem 'rgeo'

gem 'airbrake'


group :development, :test do
  gem 'bullet'
  gem 'debugger'
  gem 'pry'
  gem 'pry-rails'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'delorean'
end

group :test do
  gem 'rspec-rails', '~> 2.6'
  gem 'mongoid-rspec'
  gem 'cucumber-rails', require: false
  gem 'email_spec'
  gem 'action_mailer_cache_delivery'
  gem 'spork', '~> 1.0rc'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'simplecov', require: false
  gem 'webmock', require: false
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'less-rails'
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
  gem 'therubyracer', '0.10.2' # NOTE can't update due to libv8 version on heroku
  gem 'twitter-bootstrap-rails'
  gem 'compass-rails'
  gem 'haml_assets'
  gem 'handlebars_assets'
  gem 'i18n-js'
  gem 'turbolinks'
  gem 'jquery-turbolinks'
end
