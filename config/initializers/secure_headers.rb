if defined?(SecureHeaders)
  ::SecureHeaders::Configuration.configure do |config|
    config.hsts = { max_age: 20.years.to_i, include_subdomains: true }
    config.x_frame_options = 'DENY'
    config.x_content_type_options = 'nosniff'
    config.x_xss_protection = { value: 1, mode: 'block' }
    config.csp = {
      default_src: 'https://* http://* inline eval',
      frame_src: 'https://* http://* https://*.facebook.com',
      img_src: 'https://* http://* data:',
      report_uri: '/report_uri'
    }
  end
end
