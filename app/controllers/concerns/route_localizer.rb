# frozen_string_literal: true

module RouteLocalizer
  extend ActiveSupport::Concern

  included do
    private

    def available_locale_from(*locales)
      (locales.compact.map(&:to_sym) & I18n.available_locales).first
    end

    def locale_from_http_request
      http_accept_language.preferred_language_from(I18n.available_locales) ||
        http_accept_language.compatible_language_from(I18n.available_locales)
    end

    def localize_route(&block)
      locale = available_locale_from(params[:locale],
                                     current_user.try(:locale)) ||
               locale_from_http_request ||
               I18n.default_locale

      I18n.with_locale locale, &block
    end
  end
end
