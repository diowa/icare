# DO NOT SET SENSITIVE DATA HERE!
# USE ENVIRONMENT VARIABLES OR 'local.rb' INSTEAD

# OVERRIDE THESE DEFAULTS IN A PROPER ENVIRONMENT CONFIGURATION FILE
# SET SENSITIVE DATA ONLY IN 'local.rb'

SimpleConfig.for :application do
  set :app_name, 'Blacoin'
  set :repository_url, 'http://www.blacoin.com'

  set :available_locales, Hash[{ :"en-US" => 'English (US)',
                                 :"it-IT" => 'Italiano' }.sort_by { |_, native_name| native_name }]

  set :demo_mode, false
  set :base_url, '127.0.0.1:5000'
  set :secret_token, '197241fc4c041de6402aa732e0004c5401536237a1c39178005ddf9994695cfc71fb32b543f8fb216f272b416974e3ea3cece241278a40a8516291aec598a948'
  set :single_process_mode, true

  set :costs_calculation_service_link, 'http://servizi.aci.it/CKInternet/'

  set :google_analytics_id, nil
  set :google_maps_api_key, nil

  group :devise do
    set :secret_key, 'eb72ea40d147d8cc0c87dda38b498f7650ccd9286d38dc220fb16d69d4a0623b12b6ca294e098420df506352470addf14aaf2dcff980aa49f1529578de500dda'
  end

  group :facebook do
    set :namespace, 'FACEBOOK_NAMESPACE'
    set :app_id, 'FACEBOOK_APP_ID'
    set :secret, 'FACEBOOK_SECRET'
    set :scope, 'email, publish_stream, user_birthday, user_about_me, user_education_history, user_interests, user_likes, user_religion_politics, user_work_history'
    set :cache_expiry_time, 7.days
    # If set, only users of the following facebook group id will be able to use the application
    # It will automatically add 'user_groups' permission to facebook scope
    # Example: set :restricted_group_id, '379766462096606'
    set :restricted_group_id, nil
  end

  group :airbrake do
    set :api_key, 'AIRBRAKE_API_KEY'
    set :host, 'AIRBRAKE_HOST'
    set :port, 80
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
    set :from, "\"Blacoin\" <no-reply@blacoin.com>"
    set :host, '127.0.0.1'

    group :smtp_settings do
      set :address, '127.0.0.1'
      set :port, 587
      set :authentication, :plain
      set :domain, '127.0.0.1'

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
