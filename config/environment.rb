# Load the Rails application.
require File.expand_path('../application', __FILE__)

# TODO: Replace with figaro
require Rails.root.join('config', 'configuration.rb').to_s

# Initialize the Rails application.
Rails.application.initialize!
