# DO NOT SET SENSITIVE DATA HERE!
# USE ENVIRONMENT VARIABLES OR 'local.rb' INSTEAD

SimpleConfig.for :application do
  set :base_url, ENV["APP_BASE_URL"]
  set :secret_token, ENV["SECRET_TOKEN"]
  set :single_process_mode, false

  set :google_analytics_id, ENV["GOOGLE_ANALYTICS_ID"]

  group :facebook do
    # NOTE: If you don't want to use "FACEBOOK_APP_ID" as variable name,
    # edit 'assets/javascripts/fbjssdk.js.coffee' too
    set :namespace, ENV["FACEBOOK_NAMESPACE"]
    set :app_id, ENV["FACEBOOK_APP_ID"]
    set :secret, ENV["FACEBOOK_SECRET"]
  end

  group :redis do
    set :url, ENV["REDISTOGO_URL"]
  end

  group :resque do
    set :user_name, ENV["RESQUE_WEB_USER"]
    set :password, ENV["RESQUE_WEB_PASSWORD"]
  end
end
