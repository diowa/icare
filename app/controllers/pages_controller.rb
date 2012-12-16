class PagesController < ApplicationController

  skip_before_filter :require_login

  def home
    if logged_in?
      redirect_to :dashboard
    end
  end

  def fbjssdk_channel
    response.headers['Pragma'] = 'public'
    response.headers['Cache-Control'] = "max-age=#{1.year.to_i}"
    response.headers['Expires'] = 1.year.from_now.httpdate
    render layout: false
  end
end
