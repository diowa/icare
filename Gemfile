# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

ruby '2.5.0'
gem 'rails', '5.1.5'

# Servers
gem 'puma', '~> 3.11'

# Background jobs within the same process as web application
gem 'sucker_punch', '~> 2.0'

# Multi-environment configuration
gem 'simpleconfig', '~> 2.0'

# API
gem 'rabl', '~> 0.13.1'

# Forms
gem 'simple_form', '~> 3.5'

# ODM and related
gem 'client_side_validations', '~> 11.1'
gem 'client_side_validations-simple_form', '~> 6.5'
gem 'kaminari', '~> 1.1'
gem 'kaminari-mongoid', '~> 1.0'
gem 'mongoid', '~> 6.3'
gem 'mongoid-geospatial', '~> 5.0'
gem 'mongoid-slug', '~> 5.3'
gem 'mongoid_paranoia', '~> 0.3'
gem 'validates_timeliness', '~> 4.0'
gem 'validates_timeliness-mongoid', github: 'diowa/validates_timeliness-mongoid'

# Authentication framework
gem 'devise', '~> 4.4'

# Geospatial data library
# gem 'rgeo', '~> 0.6.0'

# Facebook integration
gem 'koala', '~> 3.0'
gem 'omniauth-facebook', '~> 4.0'

# Performance
gem 'newrelic_rpm', '~> 4.8'

# Security
gem 'secure_headers', '~> 5.0'

# Miscellanea
gem 'google-analytics-rails', '~> 1.1'
gem 'http_accept_language', '~> 2.1'
gem 'jquery-rails', '~> 4.3'
gem 'slim-rails', '~> 3.1'

# Assets
gem 'autoprefixer-rails', '~> 8.1'
gem 'coffee-rails', '~> 4.2'
gem 'handlebars_assets', '~> 0.23.2'
gem 'i18n-js', '~> 3.0'
gem 'sass-rails', '~> 5.0'
gem 'sprockets', '~> 3.7'
gem 'sprockets-rails', '~> 3.2'
gem 'turbolinks', '~> 5.1'
gem 'twbs_sass_rails', '~> 5.0'
gem 'uglifier', '~> 4.1'

group :development, :test do
  gem 'bullet', '~> 5.7'
  gem 'byebug', '~> 10.0'
  gem 'factory_bot_rails', '~> 4.8'
  gem 'faker', '~> 1.8'
  gem 'pry', '~> 0.11.3'
  gem 'pry-byebug', '~> 3.6'
  gem 'pry-rails', '~> 0.3.6'
  gem 'rspec-rails', '~> 3.7'
  gem 'rubocop', '~> 0.53.0', require: false
  gem 'rubocop-rspec', '~> 1.24', require: false
  gem 'scss_lint', '~> 0.57.0', require: false
  gem 'slim_lint', '~> 0.15.1', require: false
end

group :development do
  gem 'better_errors', '~> 2.4'
  gem 'binding_of_caller', '~> 0.8.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'meta_request', '~> 0.5.0'
  gem 'spring', '~> 2.0'
  gem 'spring-commands-rspec', '~> 1.0'
  gem 'spring-watcher-listen', '~> 2.0'
  gem 'web-console', '~> 3.5'
end

group :test do
  gem 'capybara', '~> 2.18'
  gem 'capybara-screenshot', '~> 1.0'
  gem 'coveralls_reborn', '~> 0.10.0', require: false
  gem 'database_cleaner', '~> 1.6'
  gem 'email_spec', '~> 2.1'
  gem 'launchy', '~> 2.4'
  gem 'mongoid-rspec', '~> 4.0'
  gem 'poltergeist', '~> 1.17'
  gem 'simplecov', '~> 0.15.1', require: false
  gem 'webmock', '~> 3.3', require: false
end

group :staging, :production do
  gem 'airbrake', '~> 7.2'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', '~> 1.2017', platforms: %i[mingw mswin x64_mingw jruby]
