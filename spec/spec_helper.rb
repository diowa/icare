require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do
  ENV['RAILS_ENV'] ||= 'test'

  unless ENV['DRB']
    require 'simplecov'
    SimpleCov.start 'rails'
  end

  require 'rails/application'

  # Use of https://github.com/sporkrb/spork/wiki/Spork.trap_method-Jujutsu
  Spork.trap_method Rails::Application, :reload_routes!
  Spork.trap_method Rails::Application::RoutesReloader, :reload!

  require 'rails/mongoid'
  Spork.trap_class_method Rails::Mongoid, :load_models

  # Prevent main application to eager_load in the prefork block (do not load files in autoload_paths)
  Spork.trap_method Rails::Application, :eager_load!

  # Below this line it is too late...
  require File.expand_path '../../config/environment', __FILE__

  # Load all railties files
  Rails.application.railties.all { |r| r.eager_load! }

  RSpec.configure do |config|
    # == Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    # config.mock_with :rspec
    config.include Delorean
    ActionMailer::Base.perform_deliveries = false
    ActionMailer::Base.raise_delivery_errors = false
    ActionMailer::Base.delivery_method = :test

    config.expect_with :rspec do |c|
      c.syntax = :expect
    end

    config.before(:each) do
      back_to_the_present
      #load "#{Rails.root}/db/seeds.rb"
    end
  end
end

Spork.each_run do
  # This code will be run each time you run your specs.
  if ENV['DRB']
    require 'simplecov'
    SimpleCov.start 'rails'
  end
end
