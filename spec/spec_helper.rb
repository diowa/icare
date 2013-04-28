require 'spork'

if ENV['CI']
  require 'coveralls'
  Coveralls.wear! 'rails'
end

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

  require 'webmock/rspec'
  require 'rspec/rails'
  require 'capybara/rspec'

  WebMock.disable_net_connect! allow: 'graph.facebook.com', allow_localhost: true

  #Capybara.ignore_hidden_elements = false # testing hidden fields

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

  RSpec.configure do |config|
    # == Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    # config.mock_with :rspec


    # Run specs in random order to surface order dependencies. If you find an
    # order dependency and want to debug it, you can fix the order by providing
    # the seed, which is printed after each run.
    #     --seed 1234
    config.order = 'random'

    config.include Delorean

    config.expect_with :rspec do |c|
      c.syntax = :expect
    end

    config.before(:each) do
      back_to_the_present
      reset_email
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
