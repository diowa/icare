class Admin::UsersController < Admin::BaseController
  before_filter :prevent_autoban, only: [:ban, :unban]

  def index
    @users = User.asc(:name).page params[:page]
  end

  def login_as
    user = User.find params[:id]
    session[:user_id] = user.id.to_s
    redirect_to :dashboard
  end

  def ban
    @user.banned = true
    redirect_to admin_users_path, flash: (@user.save ? { success: t('flash.admin.users.success.ban') } : { error: t('flash.admin.users.error.ban') })
  end

  def unban
    @user.banned = false
    redirect_to admin_users_path, flash: (@user.save ? { success: t('flash.admin.users.success.unban') } : { error: t('flash.admin.users.error.unban') })
  end

  private
  def prevent_autoban
    @user = User.find params[:id]
    redirect_to admin_users_path, flash: { error: t('flash.admin.users.error.ban') } if @user == current_user
  end
end
