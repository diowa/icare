Airbrake.configure do |config|
  config.project_id  = APP_CONFIG.airbrake.project_id
  config.project_key = APP_CONFIG.airbrake.project_key
  config.host        = APP_CONFIG.airbrake.host
end
