# frozen_string_literal: true

class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def home
    redirect_to :dashboard if user_signed_in?
  end
end
