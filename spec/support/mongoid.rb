# frozen_string_literal: true

RSpec.configure do |config|
  config.include Mongoid::Matchers, type: :model

  config.before(:suite) do
    DatabaseCleaner[:mongoid].strategy = :truncation
    DatabaseCleaner[:mongoid].clean_with :truncation
  end

  config.before(:each) do
    DatabaseCleaner[:mongoid].start
  end

  config.append_after(:each) do
    DatabaseCleaner[:mongoid].clean
  end
end
