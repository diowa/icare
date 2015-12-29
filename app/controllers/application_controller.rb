class ApplicationController < ActionController::Base
  ensure_security_headers
  protect_from_forgery with: :exception

  before_action :authenticate_user!
  before_action :check_banned, except: [:banned]

  around_action :set_locale_from_params
  around_action :time_zone_from_user, if: :user_signed_in?

  helper_method :permitted_params

  protected

  def set_locale_from_params
    locale = check_locale_availability(params[:locale] || (current_user.locale if user_signed_in?)) ||
             http_accept_language.preferred_language_from(I18n.available_locales) ||
             http_accept_language.compatible_language_from(I18n.available_locales)
    I18n.with_locale(locale) do
      yield
    end
  end

  def time_zone_from_user
    Time.use_zone(current_user.time_zone) do
      yield
    end
  end

  def check_banned
    redirect_to :banned if user_signed_in? && current_user.banned?
  end

  def find_user(param)
    User.find_by(username_or_uid: param)
  end

  private

  def after_sign_in_path_for(_resource_or_scope)
    session.delete(:redirect_to) || dashboard_path
  end

  def check_locale_availability(locale)
    locale if locale.present? && I18n.available_locales.include?(locale.to_sym)
  end

  def permitted_params
    @permitted_params ||= PermittedParams.new(params, current_user)
  end
end
