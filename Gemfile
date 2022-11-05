# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

ruby '3.1.2'
gem 'rails', '7.0.4'

# Use postgresql as the database for Active Record
gem 'activerecord-postgis-adapter', '~> 8.0'
gem 'pg', '~> 1.4'

# Servers
gem 'puma', '~> 5.6'

# Transpile app-like JavaScript. Read more: https://github.com/shakacode/shakapacker
gem 'shakapacker', '6.5.2'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '~> 1.13', require: false

# Background jobs within the same process as web application
gem 'sucker_punch', '~> 3.1'

# Multi-environment configuration
gem 'simpleconfig', '~> 2.0'

# API
gem 'jbuilder', '~> 2.11'

# Forms
gem 'simple_form', '~> 5.1'

# ODM and related
gem 'client_side_validations', '~> 21.0'
gem 'client_side_validations-simple_form', '~> 15.0'
gem 'friendly_id', '~> 5.4'
gem 'kaminari', '~> 1.2'
gem 'validates_timeliness', github: 'tagliala/validates_timeliness', branch: 'rails-70'

# Authentication framework
gem 'devise', '~> 4.8'
gem 'omniauth', '~> 2.1'
gem 'omniauth-rails_csrf_protection', '~> 1.0'

# OAuth Provider
gem 'auth0', '~> 5.10'
gem 'omniauth-auth0', '~> 3.0'

# Geospatial data library
gem 'rgeo', '~> 2.4'

# Performance
gem 'newrelic_rpm', '~> 8.12'

# Security
gem 'secure_headers', '~> 6.5'

# Miscellanea
gem 'addressable', '~> 2.8'
gem 'http_accept_language', '~> 2.1'
gem 'slim-rails', '~> 3.5'

# Assets
gem 'i18n-js', '~> 4.0'
gem 'inline_svg', '~> 1.8'
gem 'turbolinks', '~> 5.2'

# Errors reporting
gem 'airbrake', '~> 13.0'

group :development, :test do
  gem 'bullet', '~> 7.0'
  gem 'byebug', '~> 11.1'
  gem 'factory_bot_rails', '~> 6.2'
  gem 'faker', '~> 2.23'
  gem 'pry', '~> 0.14.1'
  gem 'pry-byebug', '~> 3.10'
  gem 'pry-rails', '~> 0.3.9'
  gem 'rspec-rails', '~> 6.0'
  gem 'rubocop', '~> 1.37', require: false
  gem 'rubocop-performance', '~> 1.15', require: false
  gem 'rubocop-rails', '~> 2.17', require: false
  gem 'rubocop-rspec', '~> 2.14', require: false
  gem 'slim_lint', '~> 0.22.1', require: false
end

group :development do
  gem 'web-console', '~> 4.2'
end

group :test do
  gem 'capybara', '~> 3.37'
  gem 'email_spec', '~> 2.2'
  gem 'selenium-webdriver', '~> 4.6'
  gem 'simplecov', '~> 0.21.2', require: false
  gem 'simplecov-lcov', '~> 0.8.0', require: false
  gem 'webmock', '~> 3.18', require: false
end
