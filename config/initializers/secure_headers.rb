if defined?(SecureHeaders)
  ::SecureHeaders::Configuration.configure do |config|
    config.hsts = { max_age: 20.years.to_i, include_subdomains: true }
    config.x_frame_options = 'DENY'
    config.x_content_type_options = 'nosniff'
    config.x_xss_protection = { value: 1, mode: 'block' }
    config.x_download_options = 'noopen'
    config.x_permitted_cross_domain_policies = 'none'
    config.csp = false
    # config.csp = {
    #  default_src: 'self https:',
    #  font_src: 'self http://fonts.gstatic.com',
    #  frame_src: 'https: https://*.facebook.com http://*.facebook.com',
    #  img_src: 'data: http: https:',
    #  report_uri: '/report_uri',
    #  script_src: 'self eval inline http://*.facebook.net http://*.googleapis.com http://maps.gstatic.com https://*.facebook.net https://*.googleapis.com https://maps.gstatic.com',
    #  style_src: 'self inline http://fonts.googleapis.com http://netdna.bootstrapcdn.com https://fonts.googleapis.com https://netdna.bootstrapcdn.com'
    # }
  end
end
