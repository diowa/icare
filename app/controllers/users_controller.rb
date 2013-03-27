class UsersController < ApplicationController

  before_filter :set_user_as_current_user, only: [:update, :dashboard, :settings, :itineraries]

  def show
    @user = find_user params[:id]
  end

  def edit
  end

  def update
    if @user.update_attributes(permitted_params.user)
      redirect_to :settings, flash: { success: t('flash.users.success.update') }
    else
      render :settings
    end
  end

  def destroy
    if current_user.destroy
      session[:user_id] = nil
      redirect_to root_path, flash: { success: t('flash.users.success.destroy') }
    else
      redirect_to dashboard_path, flash: { error: t('flash.users.error.destroy') }
    end
  end

  def dashboard
    @latest_itineraries = Itinerary.includes(:user).desc(:created_at).limit 10

    # Gender filter
    @latest_itineraries = @latest_itineraries.where(pink: false) if current_user.male?
  end

  def itineraries
    @itineraries = @user.itineraries.desc :created_at
  end

  def banned
    redirect_to root_path unless current_user.banned?
  end

  private
  def set_user_as_current_user
    @user = current_user
  end
end
