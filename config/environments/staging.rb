# frozen_string_literal: true

load Rails.root.join('config/environments/production.rb')

Rails.application.configure do
  config.log_level = :debug
end
