# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < ::Devise::OmniauthCallbacksController
    def auth0
      @user = User.from_omniauth(auth_hash)

      if @user.persisted?
        @user.update_info_from_auth_hash! auth_hash
        sign_in_and_redirect @user, event: :authentication
      else
        redirect_to root_path, flash: { error: t('flash.sessions.error.create') }
      end
    end

    protected

    def after_omniauth_failure_path_for(_scope)
      root_path
    end

    def auth_hash
      request.env['omniauth.auth']
    end
  end
end
