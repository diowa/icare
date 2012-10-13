class UsersController < ApplicationController

  skip_before_filter :require_login, only: [:new, :create, :activate]

  before_filter :set_user_as_current_user, only: [:dashboard, :settings]
  before_filter :check_admin, only: [:index, :ban, :unban]

  # TODO proper edit methods

  def index
    @users = User.sorted.page params[:page]
  end

  def show
    @user = User.any_of({ username: params[:id] }, { uid: params[:id] }, { _id: params[:id] }).first
    @facebook_details = @user.facebook_profile_batch(current_user != @user ? current_user : nil)
  end

  def create
  end

  def edit
  end

  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      redirect_to :settings, flash: { success: t('flash.user.success.update') }
    else
      render :settings
    end
  end

  def destroy
    if current_user.admin? && params[:id].present?
      @user = User.any_of({ username: params[:id] }, { uid: params[:id] }, { _id: params[:id] }).first
    else
      @user = current_user
    end
    if @user.destroy
      session[@user.id] = nil
      if current_user.admin? && @user != current_user
        redirect_to users_path
      else
        redirect_to root_path, flash: { success: t('flash.user.success.destroy') }
      end
    else
      redirect_to root_path, flash: { error: t('flash.user.error.destroy') }
    end
  end

  def dashboard
    @last_itineraries = Itinerary.includes(:user).sorted_by_creation.limit(10)

    # Gender filter
    @last_itineraries = @last_itineraries.where(pink: false) if current_user.male?
  end

  def banned
    redirect_to root_path unless current_user.banned?
  end

  def ban
    @user = User.any_of({ username: params[:id] }, { uid: params[:id] }, { _id: params[:id] }).first

    # Prevent autoban
    if @user == current_user
      redirect_to users_path, flash: { error: t('flash.user.error.ban') }
      return
    end

    @user.banned = true
    if @user.save
      redirect_to users_path, flash: { success: t('flash.user.success.ban') }
    else
      redirect_to users_path, flash: { error: t('flash.user.error.ban') }
    end
  end

  def unban
    @user = User.any_of({ username: params[:id] }, { uid: params[:id] }, { _id: params[:id] }).first
    @user.banned = false
    if @user.save
      redirect_to users_path, flash: { success: t('flash.user.success.unban') }
    else
      redirect_to users_path, flash: { error: t('flash.user.error.unban') }
    end
  end

private

  def set_user_as_current_user
    @user = current_user
  end
end
