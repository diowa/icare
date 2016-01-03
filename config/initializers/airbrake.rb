if APP_CONFIG.airbrake.project_id && APP_CONFIG.airbrake.project_key && APP_CONFIG.airbrake.host
  Airbrake.configure do |c|
    c.project_id  = APP_CONFIG.airbrake.project_id
    c.project_key = APP_CONFIG.airbrake.project_key
    c.host        = APP_CONFIG.airbrake.host
  end
end
