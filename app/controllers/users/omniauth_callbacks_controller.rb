class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    if @user = User.from_omniauth(request.env['omniauth.auth'])
      sign_in_and_redirect @user, event: :authentication # this will throw if @user is not activated
    else
      redirect_to root_path, flash: { error: t(APP_CONFIG.facebook.restricted_group_id ? 'flash.sessions.error.restricted' : 'flash.sessions.error.create') }
    end
  end

  protected
  def after_omniauth_failure_path_for(scope)
    root_path
  end
end
