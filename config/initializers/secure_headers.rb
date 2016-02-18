# frozen_string_literal: true
if defined?(SecureHeaders)
  SecureHeaders::Configuration.default do |config|
    config.hsts = "max-age=#{20.years.to_i}; includeSubdomains"
    config.x_frame_options = 'DENY'
    config.x_content_type_options = 'nosniff'
    config.x_xss_protection = '1; mode=block'
    config.x_download_options = 'noopen'
    config.x_permitted_cross_domain_policies = 'none'
  end
end
