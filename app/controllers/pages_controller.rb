class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def home
    redirect_to :dashboard if user_signed_in?
  end

  def fbjssdk_channel
    response.headers['Pragma'] = 'public'
    response.headers['Cache-Control'] = "max-age=#{1.year.to_i}"
    response.headers['Expires'] = 1.year.from_now.httpdate
    render layout: false
  end
end
