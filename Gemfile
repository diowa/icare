# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

ruby '3.2.2'

gem 'rails', '7.0.8'

gem 'activerecord-postgis-adapter', '~> 8.0'
gem 'airbrake', '~> 13.0'
gem 'auth0', '~> 5.14'
gem 'bootsnap', '~> 1.16', require: false
gem 'client_side_validations', '~> 22.1'
gem 'client_side_validations-simple_form', '~> 16.0'
gem 'devise', '~> 4.9'
gem 'friendly_id', '~> 5.5'
gem 'http_accept_language', '~> 2.1'
gem 'i18n-js', '~> 4.2'
gem 'inline_svg', '~> 1.9'
gem 'jbuilder', '~> 2.11'
gem 'kaminari', '~> 1.2'
gem 'newrelic_rpm', '~> 9.5'
gem 'omniauth', '~> 2.1'
gem 'omniauth-auth0', '~> 3.1'
gem 'omniauth-rails_csrf_protection', '~> 1.0'
gem 'pg', '~> 1.5'
gem 'puma', '~> 6.4'
gem 'rgeo', '~> 3.0'
gem 'secure_headers', '~> 6.5'
gem 'shakapacker', '7.1.0'
gem 'simpleconfig', '~> 2.0'
gem 'simple_form', '~> 5.2'
gem 'slim-rails', '~> 3.6'
gem 'sucker_punch', '~> 3.1'
gem 'turbolinks', '~> 5.2'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
gem 'validates_timeliness', '~> 7.0.0.beta2'

group :development, :test do
  gem 'bullet'
  gem 'byebug'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
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
