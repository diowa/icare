RSpec.configure do |config|

  config.include Mongoid::Matchers

  config.before(:suite) { DatabaseCleaner[:mongoid].strategy = :truncation }

  config.before(:each) { DatabaseCleaner[:mongoid].start }

  config.after(:each) { DatabaseCleaner[:mongoid].clean }
end
