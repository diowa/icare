class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :require_login
  before_filter :set_locale
  before_filter :check_banned, except: [ :banned ]
  before_filter :check_admin, only: [ :index ] # whitelist approach

  around_filter :set_user_time_zone

  helper_method :current_user, :logged_in?

protected

  def set_user_time_zone
    old_time_zone = Time.zone
    Time.zone = current_user.time_zone if (logged_in? && current_user.time_zone?)
    yield
  ensure
    Time.zone = old_time_zone
  end

  def set_locale
    # TODO think about optimizing this
    I18n.locale = \
      (params[:locale].to_sym if params[:locale].present? && I18n.available_locales.include?(params[:locale].to_sym)) \
      || (current_user.locale.to_sym if logged_in? && current_user.locale && I18n.available_locales.include?(current_user.locale.to_sym)) \
      || (request.preferred_language_from(I18n.available_locales) if request.preferred_language_from(I18n.available_locales)) \
      || (request.compatible_language_from(I18n.available_locales) if request.compatible_language_from(I18n.available_locales))
  end

  def require_login
    if current_user.nil?
      redirect_to root_path, flash: { error: t('flash.error.not_authenticated') }
    end
  end

  def check_admin
    unless current_user && current_user.admin?
      redirect_to root_path, flash: { error: t('flash.error.not_allowed') }
    end
  end

  def check_banned
    if current_user && current_user.banned?
      redirect_to :banned
    end
  end

private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  rescue
    session[:user_id] = nil
  end

  def logged_in?
    !!current_user
  end
end
