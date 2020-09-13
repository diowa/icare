# frozen_string_literal: true

# DO NOT SET SENSITIVE DATA HERE!
# USE ENVIRONMENT VARIABLES OR 'local.rb' INSTEAD

SimpleConfig.for :application do
  set :base_url, ENV['APP_BASE_URL']
  set :single_process_mode, false

  set :google_analytics_id, ENV['GOOGLE_ANALYTICS_ID']
  set :google_maps_api_key, ENV['GOOGLE_MAPS_API_KEY']

  group :auth0 do
    set :domain, ENV['AUTH0_DOMAIN']
    set :client_id, ENV['AUTH0_CLIENT_ID']
    set :client_secret, ENV['AUTH0_CLIENT_SECRET']
  end

  group :airbrake do
    set :project_id, ENV['AIRBRAKE_PROJECT_ID']
    set :project_key, ENV['AIRBRAKE_PROJECT_KEY']
    set :host, ENV['AIRBRAKE_HOST']
  end

  group :mailer do
    set :from, '"Icare" <no-reply@i.care>'
    set :host, 'heroku.com'

    group :smtp_settings do
      set :address, 'smtp.sendgrid.net'
      set :port, 587
      set :authentication, :plain
      set :domain, 'heroku.com'

      set :user_name, ENV['SENDGRID_USERNAME']
      set :password, ENV['SENDGRID_PASSWORD']
    end
  end

  group :redis do
    set :url, ENV['REDISTOGO_URL']
  end
end
