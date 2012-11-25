RSpec.configure do |config|

  ActionMailer::Base.perform_deliveries = false
  ActionMailer::Base.raise_delivery_errors = false
  ActionMailer::Base.delivery_method = :test

  config.include Mongoid::Matchers

  config.before :suite do
    DatabaseCleaner[:mongoid].strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner[:mongoid].start
  end

  config.after(:each) do
    DatabaseCleaner[:mongoid].clean
  end

end
