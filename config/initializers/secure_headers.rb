# frozen_string_literal: true

SecureHeaders::Configuration.default do |config|
  config.cookies = {
    secure:   true,
    httponly: true,
    samesite: {
      lax: true
    }
  }

  config.hsts                              = "max-age=#{20.weeks.to_i}; includeSubdomains"
  config.x_frame_options                   = 'DENY'
  config.x_content_type_options            = 'nosniff'
  config.x_xss_protection                  = '1; mode=block'
  config.x_download_options                = 'noopen'
  config.x_permitted_cross_domain_policies = 'none'
  config.referrer_policy                   = %w[origin-when-cross-origin strict-origin-when-cross-origin]
  config.clear_site_data = SecureHeaders::OPT_OUT

  config.csp = SecureHeaders::OPT_OUT
end
