# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

ruby '2.5.3'
gem 'rails', '5.2.1'

# Servers
gem 'puma', '~> 3.12'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Background jobs within the same process as web application
gem 'sucker_punch', '~> 2.1'

# Multi-environment configuration
gem 'simpleconfig', '~> 2.0'

# API
gem 'rabl', '~> 0.14.0'

# Forms
gem 'simple_form', '~> 4.0'

# ODM and related
gem 'client_side_validations', '~> 11.1'
gem 'client_side_validations-simple_form', '~> 6.7'
gem 'kaminari', '~> 1.1'
gem 'kaminari-mongoid', '~> 1.0'
gem 'mongoid', '~> 6.4'
gem 'mongoid-geospatial', '~> 5.0'
gem 'mongoid-slug', '~> 6.0'
gem 'mongoid_paranoia', '~> 0.3'
gem 'validates_timeliness', '~> 4.0'
gem 'validates_timeliness-mongoid', github: 'diowa/validates_timeliness-mongoid'

# Authentication framework
gem 'devise', '~> 4.5'

# Geospatial data library
# gem 'rgeo', '~> 0.6.0'

# Facebook integration
gem 'koala', '~> 3.0'
gem 'omniauth-facebook', '~> 5.0'

# Performance
gem 'newrelic_rpm', '~> 5.4'

# Security
gem 'secure_headers', '~> 6.0'

# Miscellanea
gem 'http_accept_language', '~> 2.1'
gem 'jquery-rails', '~> 4.3'
gem 'slim-rails', '~> 3.2'

# Assets
gem 'autoprefixer-rails', '~> 9.3'
gem 'coffee-rails', '~> 4.2'
gem 'handlebars_assets', '~> 0.23.2'
gem 'i18n-js', '~> 3.1'
gem 'sass-rails', '~> 5.0'
gem 'sprockets', '~> 3.7'
gem 'sprockets-rails', '~> 3.2'
gem 'turbolinks', '~> 5.2'
gem 'twbs_sass_rails', '~> 6.0'
gem 'uglifier', '~> 4.1'

group :development, :test do
  gem 'bullet', '~> 5.8'
  gem 'byebug', '~> 10.0'
  gem 'factory_bot_rails', '~> 4.11'
  gem 'faker', '~> 1.9'
  gem 'pry', '~> 0.12.0'
  gem 'pry-byebug', '~> 3.6'
  gem 'pry-rails', '~> 0.3.7'
  gem 'rspec-rails', '~> 3.8'
  gem 'rubocop', '~> 0.60.0', require: false
  gem 'rubocop-rspec', '~> 1.30', require: false
  gem 'scss_lint', '~> 0.57.1', require: false
  gem 'slim_lint', '~> 0.16.1', require: false
end

group :development do
  gem 'better_errors', '~> 2.5'
  gem 'binding_of_caller', '~> 0.8.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'meta_request', '~> 0.6.0'
  gem 'spring', '~> 2.0'
  gem 'spring-commands-rspec', '~> 1.0'
  gem 'spring-watcher-listen', '~> 2.0'
  gem 'web-console', '~> 3.7'
end

group :test do
  gem 'capybara', '~> 3.10'
  gem 'coveralls_reborn', '~> 0.12.0', require: false
  gem 'database_cleaner', '~> 1.7'
  gem 'email_spec', '~> 2.2'
  gem 'launchy', '~> 2.4'
  gem 'mongoid-rspec', '~> 4.0'
  gem 'poltergeist', '~> 1.18'
  gem 'selenium-webdriver', '~> 3.141'
  gem 'simplecov', '~> 0.16.1', require: false
  gem 'webmock', '~> 3.4', require: false
end

group :staging, :production do
  gem 'airbrake', '~> 7.4'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', '~> 1.2018', platforms: %i[mingw mswin x64_mingw jruby]
