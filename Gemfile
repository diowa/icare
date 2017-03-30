# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

ruby '2.4.1'
gem 'rails', '5.0.2'

# Servers
gem 'thin'

# Multi-environment configuration
gem 'simpleconfig'

# API
gem 'rabl'

# ODM and related
gem 'client_side_validations'
gem 'client_side_validations-simple_form'
gem 'kaminari'
gem 'kaminari-mongoid'
gem 'mongoid'
gem 'mongoid-slug'
gem 'mongoid_geospatial'
gem 'mongoid_paranoia'
gem 'validates_timeliness'
gem 'validates_timeliness-mongoid', github: 'johnnyshields/validates_timeliness-mongoid'

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

# Security
gem 'secure_headers'

# Miscellanea
gem 'google-analytics-rails'
gem 'http_accept_language'
gem 'jquery-rails'
gem 'resque', require: 'resque/server' # Resque web interface
gem 'sinatra', '~> 2.0.0.rc2' # Needed by resque/server
gem 'slim-rails'

# Assets
gem 'autoprefixer-rails'
gem 'coffee-rails', '~> 4.2'
gem 'handlebars_assets'
gem 'i18n-js'
gem 'sass-rails', '~> 5.0'
gem 'sprockets'
gem 'sprockets-rails'
gem 'turbolinks'
gem 'twbs_sass_rails'
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
  gem 'rubocop', require: false
  gem 'scss_lint', require: false
  gem 'slim_lint', require: false
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'coveralls', require: false
  gem 'database_cleaner'
  gem 'email_spec'
  gem 'launchy'
  gem 'mongoid-rspec'
  gem 'poltergeist'
  gem 'rspec'
  gem 'simplecov', require: false
  gem 'webmock', require: false
end

group :staging, :production do
  gem 'unicorn'
end
