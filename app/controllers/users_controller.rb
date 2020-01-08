# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user_as_current_user, only: %i[update dashboard itineraries settings]

  def show
    @user = User.find(params[:id])
  end

  def update
    if @user.update(user_params)
      redirect_to :settings, flash: { success: t('flash.users.success.update') }
    else
      render :settings
    end
  end

  def destroy
    current_user.destroy
    session[:user_id] = nil
    redirect_to root_path, flash: { success: t('flash.users.success.destroy') }
  end

  def banned
    redirect_to root_path unless current_user.banned?
  end

  def dashboard
    @latest_itineraries = Itinerary.includes(:user).order(created_at: :desc).limit 10

    # Gender filter
    @latest_itineraries = @latest_itineraries.where(pink: false) unless current_user.female?
  end

  def itineraries
    @itineraries = @user.itineraries.order(created_at: :desc)
  end

  def settings; end

  private

  def set_user_as_current_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit :time_zone, :locale, :vehicle_avg_consumption
  end
end
