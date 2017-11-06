# frozen_string_literal: true

RSpec.configure do |config|
  config.include Mongoid::Matchers, type: :model

  config.before(:suite) do
    DatabaseCleaner[:mongoid].strategy = :truncation
    DatabaseCleaner[:mongoid].clean_with :truncation
  end

  config.before do
    DatabaseCleaner[:mongoid].start
  end

  config.append_after do
    DatabaseCleaner[:mongoid].clean
  end
end
