OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  APP_CONFIG.facebook.scope.concat(', user_groups') if APP_CONFIG.facebook.restricted_group_id
  provider :facebook,
    APP_CONFIG.facebook.app_id,
    APP_CONFIG.facebook.secret,
    { scope: APP_CONFIG.facebook.scope }
end
