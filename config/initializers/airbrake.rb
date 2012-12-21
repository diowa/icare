Airbrake.configure do |config|
  config.api_key = APP_CONFIG.airbrake.api_key
  config.host    = APP_CONFIG.airbrake.host
  config.port    = APP_CONFIG.airbrake.port
  config.secure  = config.port == 443
end
