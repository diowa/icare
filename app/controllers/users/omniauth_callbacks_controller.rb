module Users
  class OmniauthCallbacksController < ::Devise::OmniauthCallbacksController
    def facebook
      @user = User.from_omniauth(request.env['omniauth.auth'])
      if @user
        sign_in_and_redirect @user, event: :authentication
      else
        redirect_to root_path, flash: { error: t(APP_CONFIG.facebook.restricted_group_id ? 'flash.sessions.error.restricted' : 'flash.sessions.error.create') }
      end
    end

    protected

    def after_omniauth_failure_path_for(_scope)
      root_path
    end
  end
end
