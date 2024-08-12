# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

ruby '3.3.4'

gem 'rails', '7.1.3.4'

gem 'activerecord-postgis-adapter', '~> 9.0'
gem 'airbrake', '~> 13.0'
gem 'auth0', '~> 5.17'
gem 'bootsnap', '~> 1.18', require: false
gem 'client_side_validations', '~> 22.2'
gem 'client_side_validations-simple_form', '~> 16.0'
gem 'devise', '~> 4.9'
gem 'friendly_id', '~> 5.5'
gem 'http_accept_language', '~> 2.1'
gem 'i18n-js', '~> 4.2'
gem 'inline_svg', '~> 1.9'
gem 'jbuilder', '~> 2.12'
gem 'kaminari', '~> 1.2'
gem 'newrelic_rpm', '~> 9.12'
gem 'omniauth', '~> 2.1'
gem 'omniauth-auth0', '~> 3.1'
gem 'omniauth-rails_csrf_protection', '~> 1.0'
gem 'pg', '~> 1.5'
gem 'puma', '~> 6.4'
gem 'rgeo', '~> 3.0'
gem 'secure_headers', '~> 6.7'
gem 'shakapacker', '8.0.1'
gem 'simpleconfig', '~> 2.0'
gem 'simple_form', '~> 5.3'
gem 'slim-rails', '~> 3.6'
gem 'sucker_punch', '~> 3.2'
gem 'turbolinks', '~> 5.2'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

group :development, :test do
  gem 'bullet'
  gem 'byebug'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-rails'
  gem 'rubocop-capybara', require: false
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-rspec_rails', require: false
  gem 'slim_lint', require: false
end

group :development do
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'email_spec'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  gem 'simplecov-lcov', require: false
  gem 'webmock', require: false
end
