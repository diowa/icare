module Admin
  class UsersController < BaseController
    before_action :set_user, only: [:login_as, :ban, :unban]
    before_action :prevent_autoban, only: [:ban, :unban]

    def index
      @users = User.asc(:name).page params[:page]
    end

    def login_as
      sign_in_and_redirect :user, @user
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

    def set_user
      @user = User.find params[:id]
    end

    def prevent_autoban
      redirect_to admin_users_path, flash: { error: t('flash.admin.users.error.ban') } if @user == current_user
    end
  end
end
