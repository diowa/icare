Airbrake.configure do |c|
  c.ignore_environments = %w(development test)

  c.project_id  = APP_CONFIG.airbrake.project_id
  c.project_key = APP_CONFIG.airbrake.project_key
  c.host        = APP_CONFIG.airbrake.host
end
