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
    if @user.update_attributes(banned: true)
      redirect_to admin_users_path, flash: { success: t('flash.admin.users.success.ban') }
    else
      redirect_to admin_users_path, flash: { error: t('flash.admin.users.error.ban') }
    end
  end

  def unban
    if @user.update_attributes(banned: false)
      redirect_to admin_users_path, flash: { success: t('flash.admin.users.success.unban') }
    else
      redirect_to admin_users_path, flash: { error: t('flash.admin.users.error.unban') }
    end
  end

  private
  def prevent_autoban
    @user = User.find params[:id]
    redirect_to admin_users_path, flash: { error: t('flash.admin.users.error.ban') } if @user == current_user
  end
end
