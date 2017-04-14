# frozen_string_literal: true

module Admin
  class BaseController < ::ApplicationController
    before_action :check_admin

    private

    def check_admin
      redirect_to root_path, flash: { error: t('flash.errors.not_allowed') } unless current_user.admin?
    end
  end
end
