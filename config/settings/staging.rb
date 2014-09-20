# DO NOT SET SENSITIVE DATA HERE!
# USE ENVIRONMENT VARIABLES OR 'local.rb' INSTEAD

SimpleConfig.for :application do
  set :base_url, ENV['APP_BASE_URL']
  set :secret_token, ENV['SECRET_TOKEN']
  set :single_process_mode, false

  set :google_analytics_id, ENV['GOOGLE_ANALYTICS_ID']
  set :google_maps_api_key, ENV['GOOGLE_MAPS_API_KEY']

  group :devise do
    set :secret_key, ENV['DEVISE_SECRET_KEY']
  end

  group :facebook do
    # NOTE: If you don't want to use 'FACEBOOK_APP_ID' as variable name,
    # edit 'assets/javascripts/fbjssdk.js.coffee' too
    set :namespace, ENV['FACEBOOK_NAMESPACE']
    set :app_id, ENV['FACEBOOK_APP_ID']
    set :secret, ENV['FACEBOOK_SECRET']
  end

  group :airbrake do
    set :api_key, ENV['AIRBRAKE_API_KEY']
    set :host, ENV['AIRBRAKE_HOST']
  end

  group :mailer do
    set :from, "\"Icare\" <no-reply@i.care>"
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

  group :resque do
    set :user_name, ENV['RESQUE_WEB_USER']
    set :password, ENV['RESQUE_WEB_PASSWORD']
  end
end
