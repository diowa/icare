OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, APP_CONFIG.facebook.app_id, APP_CONFIG.facebook.secret, { scope: APP_CONFIG.facebook.scope }
end
