class SessionsController < ApplicationController

  skip_before_filter :require_login, except: [:destroy]

  def create
    if (user = User.from_omniauth env['omniauth.auth'])
      session[:user_id] = user.id.to_s # NOTE .to_s keeps the session simple
      redirect_to session.delete(:redirect_to) || dashboard_path
    else
      redirect_to root_path, flash: { error: t(APP_CONFIG.facebook.restricted_group_id ? 'flash.sessions.error.restricted' : 'flash.sessions.error.create') }
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end
end
