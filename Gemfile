# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

ruby '3.2.2'
gem 'rails', '7.0.5'

# Use postgresql as the database for Active Record
gem 'activerecord-postgis-adapter', '~> 8.0'
gem 'pg', '~> 1.5'

# Servers
gem 'puma', '~> 6.3'

# Transpile app-like JavaScript. Read more: https://github.com/shakacode/shakapacker
gem 'shakapacker', '7.0.0'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '~> 1.16', require: false

# Background jobs within the same process as web application
gem 'sucker_punch', '~> 3.1'

# Multi-environment configuration
gem 'simpleconfig', '~> 2.0'

# API
gem 'jbuilder', '~> 2.11'

# Forms
gem 'simple_form', '~> 5.2'

# ODM and related
gem 'client_side_validations', '~> 21.0'
gem 'client_side_validations-simple_form', '~> 15.0'
gem 'friendly_id', '~> 5.5'
gem 'kaminari', '~> 1.2'
gem 'validates_timeliness', '~> 7.0.0.beta2'

# Authentication framework
gem 'devise', '~> 4.9'
gem 'omniauth', '~> 2.1'
gem 'omniauth-rails_csrf_protection', '~> 1.0'

# OAuth Provider
gem 'auth0', '~> 5.13'
gem 'omniauth-auth0', '~> 3.1'

# Geospatial data library
gem 'rgeo', '~> 3.0'

# Performance
gem 'newrelic_rpm', '~> 9.2'

# Security
gem 'secure_headers', '~> 6.5'

# Miscellanea
gem 'http_accept_language', '~> 2.1'
gem 'slim-rails', '~> 3.6'

# Assets
gem 'i18n-js', '~> 4.2'
gem 'inline_svg', '~> 1.9'
gem 'turbolinks', '~> 5.2'

# Errors reporting
gem 'airbrake', '~> 13.0'

group :development, :test do
  gem 'bullet', '~> 7.0'
  gem 'byebug', '~> 11.1'
  gem 'factory_bot_rails', '~> 6.2'
  gem 'faker', '~> 3.2'
  gem 'pry', '~> 0.14.2'
  gem 'pry-byebug', '~> 3.10'
  gem 'pry-rails', '~> 0.3.9'
  gem 'rspec-rails', '~> 6.0'
  gem 'rubocop', '~> 1.52', require: false
  gem 'rubocop-performance', '~> 1.18', require: false
  gem 'rubocop-rails', '~> 2.19', require: false
  gem 'rubocop-rspec', '~> 2.22', require: false
  gem 'slim_lint', '~> 0.24.0', require: false
end

group :development do
  gem 'web-console', '~> 4.2'
end

group :test do
  gem 'capybara', '~> 3.39'
  gem 'email_spec', '~> 2.2'
  gem 'selenium-webdriver', '~> 4.10'
  gem 'simplecov', '~> 0.22.0', require: false
  gem 'simplecov-lcov', '~> 0.8.0', require: false
  gem 'webmock', '~> 3.18', require: false
end
