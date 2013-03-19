class UsersController < ApplicationController

  skip_before_filter :require_login, only: [:new, :create, :activate]

  before_filter :set_user, only: [:show, :ban, :unban]
  before_filter :set_user_as_current_user, only: [:dashboard, :settings, :itineraries]
  before_filter :check_admin, only: [:index, :ban, :unban]

  def index
    @users = User.asc(:name).page params[:page]
  end

  def show
  end

  def create
  end

  def edit
  end

  def update
    @user = current_user
    if @user.update_attributes params[:user]
      redirect_to :settings, flash: { success: t('flash.users.success.update') }
    else
      render :settings
    end
  end

  def destroy
    unless current_user.admin?
      @user = current_user
    end
    if @user.destroy
      session[@user.id] = nil
      if current_user.admin? && @user != current_user
        redirect_to users_path
      else
        redirect_to root_path, flash: { success: t('flash.users.success.destroy') }
      end
    else
      redirect_to root_path, flash: { error: t('flash.users.error.destroy') }
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

  def ban
    # Prevent autoban
    if @user == current_user
      redirect_to users_path, flash: { error: t('flash.users.error.ban') }
    else
      @user.banned = true
      redirect_to users_path, flash: (@user.save ? { success: t('flash.users.success.ban') } : { error: t('flash.users.error.ban') })
    end
  end

  def unban
    @user.banned = false
    redirect_to users_path, flash: (@user.save ? { success: t('flash.users.success.unban') } : { error: t('flash.users.error.unban') })
  end

  private
  def set_user_as_current_user
    @user = current_user
  end

  def set_user
    @user = find_user params[:id]
  end
end
