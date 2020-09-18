# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

ruby '2.7.1'
gem 'rails', '6.0.3.3'

# Use postgresql as the database for Active Record
gem 'activerecord-postgis-adapter', '~> 6.0'
gem 'pg', '~> 1.2'

# Servers
gem 'puma', '~> 5.0'

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 5.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '~> 1.4', require: false

# Background jobs within the same process as web application
gem 'sucker_punch', '~> 2.1'

# Multi-environment configuration
gem 'simpleconfig', '~> 2.0'

# API
gem 'jbuilder', '~> 2.10'

# Forms
gem 'simple_form', '~> 5.0'

# ODM and related
gem 'client_side_validations', '~> 17.0'
gem 'client_side_validations-simple_form', '~> 11.0'
gem 'friendly_id', '~> 5.4'
gem 'kaminari', '~> 1.2'
gem 'validates_timeliness', '~> 4.1'

# Authentication framework
gem 'devise', '~> 4.7'

# Geospatial data library
gem 'rgeo', '~> 2.0'

# Facebook integration
gem 'koala', '~> 3.0'
gem 'omniauth-facebook', '~> 7.0'

# Performance
gem 'newrelic_rpm', '~> 6.13'

# Security
gem 'secure_headers', '~> 6.3'

# Miscellanea
gem 'addressable', '~> 2.7'
gem 'http_accept_language', '~> 2.1'
gem 'slim-rails', '~> 3.2'

# Assets
gem 'i18n-js', '~> 3.7'
gem 'inline_svg', '~> 1.7'
gem 'turbolinks', '~> 5.2'

# Errors reporting
gem 'airbrake', '~> 11.0'

group :development, :test do
  gem 'bullet', '~> 6.1'
  gem 'byebug', '~> 11.1'
  gem 'factory_bot_rails', '~> 6.1'
  gem 'faker', '~> 2.14'
  gem 'pry', '~> 0.13.1'
  gem 'pry-byebug', '~> 3.9'
  gem 'pry-rails', '~> 0.3.9'
  gem 'rspec-rails', '~> 4.0'
  gem 'rubocop', '~> 0.91.0', require: false
  gem 'rubocop-performance', '~> 1.8', require: false
  gem 'rubocop-rails', '~> 2.8', require: false
  gem 'rubocop-rspec', '~> 1.43', require: false
  gem 'slim_lint', '~> 0.20.1', require: false
end

group :development do
  gem 'better_errors', '~> 2.8'
  gem 'binding_of_caller', '~> 0.8.0'
  gem 'listen', '~> 3.2'
  gem 'spring', '~> 2.1'
  gem 'spring-commands-rspec', '~> 1.0'
  gem 'spring-watcher-listen', '~> 2.0'
  gem 'web-console', '~> 4.0'
end

group :test do
  gem 'capybara', '~> 3.33'
  gem 'coveralls_reborn', '~> 0.18.0', require: false
  gem 'email_spec', '~> 2.2'
  gem 'launchy', '~> 2.5'
  gem 'selenium-webdriver', '~> 3.142'
  gem 'simplecov', '~> 0.19.0', require: false
  gem 'webmock', '~> 3.9', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', '~> 1.2018', platforms: %i[mingw mswin x64_mingw jruby]
