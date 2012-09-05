# Load the rails application
require File.expand_path('../application', __FILE__)

require File.join(Rails.root.to_s, "config", "configuration.rb")

# Initialize the rails application
Icare::Application.initialize!

# Enable the Haml ugly option
Haml::Template.options[:ugly] = true
