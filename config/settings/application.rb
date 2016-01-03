# DO NOT SET SENSITIVE DATA HERE!
# USE ENVIRONMENT VARIABLES OR 'local.rb' INSTEAD

# OVERRIDE THESE DEFAULTS IN A PROPER ENVIRONMENT CONFIGURATION FILE
# SET SENSITIVE DATA ONLY IN 'local.rb'

SimpleConfig.for :application do
  set :app_name, 'icare'
  set :repository_url, 'http://github.com/diowa/icare'

  set :advertising, true
  set :demo_mode, true
  set :base_url, 'localhost:3000'
  set :single_process_mode, true

  set :currency, '.00 €'
  set :fuel_consumption, 0.12
  set :fuel_currency, '€'

  set :costs_calculation_service_link, 'http://servizi.aci.it/CKInternet/'

  set :google_analytics_id, nil
  set :google_maps_api_key, nil

  group :facebook do
    set :namespace, 'FACEBOOK_NAMESPACE'
    set :app_id, 'FACEBOOK_APP_ID'
    set :secret, 'FACEBOOK_SECRET'
    set :scope, 'email, publish_actions, user_birthday, user_about_me, user_education_history, user_interests, user_likes, user_religion_politics, user_work_history'
    set :cache_expiry_time, 7.days
    # If set, only users of the following facebook group id will be able to use the application
    # It will automatically add 'user_groups' permission to facebook scope
    # Example: set :restricted_group_id, '379766462096606'
    set :restricted_group_id, nil
  end

  group :airbrake do
    # Set to nil to disable airbrake
    set :project_id, nil
    set :project_key, nil
    set :host, nil
  end

  group :map do
    # defaults to Italy
    set :center, '41.87194, 12.567379999999957'
    set :zoom, 8
    group :bounds do
      set :sw, '35.49292010, 6.62672010'
      set :ne, '47.0920, 18.52050150'
    end
  end

  group :itineraries do
    # Enable this option if you want to restrict itineraries inside a geographic area
    set :geo_restricted, false
    group :bounds do
      # Island of Ischia
      set :sw, [40.69205729999999, 13.850980400000026]
      set :ne, [40.7615088, 13.966879699999936]
    end
  end

  group :mailer do
    set :from, "\"Icare\" <no-reply@i.care>"
    set :host, 'localhost'

    group :smtp_settings do
      set :address, 'localhost'
      set :port, 587
      set :authentication, :plain
      set :domain, 'localhost'

      set :user_name, 'test'
      set :password, 'test'
    end
  end

  group :redis do
    set :url, 'redis://127.0.0.1:6379'
  end

  group :resque do
    set :user_name, 'admin'
    set :password, 'admin'
  end
end
