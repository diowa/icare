class SessionsController < ApplicationController

  skip_before_filter :require_login, except: [:destroy]

  def create
    user = User.from_omniauth(env["omniauth.auth"])
    session[:user_id] = user.id.to_s # keep the session simple
    redirect_to root_url
  end

  def destroy
    if session[:user_id]
      session[:user_id] = nil
    end
    redirect_to root_url
  end
end
