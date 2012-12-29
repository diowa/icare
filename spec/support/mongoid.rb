RSpec.configure do |config|

  config.include Mongoid::Matchers

  config.before(:suite) do
    DatabaseCleaner[:mongoid].strategy = :truncation
    DatabaseCleaner[:mongoid].start
  end

  config.before(:each) { DatabaseCleaner[:mongoid].start }

  config.after(:each) { DatabaseCleaner[:mongoid].clean }
end
