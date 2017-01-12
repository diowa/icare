# frozen_string_literal: true
RSpec.configure do |config|
  config.include Mongoid::Matchers, type: :model

  config.before(:suite) do
    DatabaseCleaner[:mongoid].strategy = :truncation
    DatabaseCleaner[:mongoid].start
  end

  config.before(:each) { DatabaseCleaner[:mongoid].start }

  config.after(:each) { DatabaseCleaner[:mongoid].clean }
end
