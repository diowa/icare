RSpec.configure do |config|

  ActionMailer::Base.perform_deliveries = false
  ActionMailer::Base.raise_delivery_errors = false
  ActionMailer::Base.delivery_method = :test

  config.include Mongoid::Matchers

  config.before(:suite) { DatabaseCleaner[:mongoid].strategy = :truncation }

  config.before(:each) { DatabaseCleaner[:mongoid].start }

  config.after(:each) { DatabaseCleaner[:mongoid].clean }
end
