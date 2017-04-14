# frozen_string_literal: true

SecureHeaders::Configuration.default do |config|
  config.hsts                              = "max-age=#{20.years.to_i}; includeSubdomains"
  config.x_frame_options                   = 'DENY'
  config.x_content_type_options            = 'nosniff'
  config.x_xss_protection                  = '1; mode=block'
  config.x_download_options                = 'noopen'
  config.x_permitted_cross_domain_policies = 'none'
  config.csp = SecureHeaders::OPT_OUT
  # config.csp = {
  #   default_src: %w(https: 'self'),
  #   frame_src: %w(*.facebook.com),
  #   connect_src: %w('self'),
  #   font_src: %w('self' data: fonts.gstatic.com netdna.bootstrapcdn.com),
  #   img_src: %w('self' data: *.fbcdn.net *.googleapis.com *.gstatic.com *.facebook.com),
  #   media_src: %w('none'),
  #   object_src: %w('none'),
  #   script_src: %w('self' 'unsafe-eval' 'unsafe-inline' maps.googleapis.com connect.facebook.net),
  #   style_src: %w('self' 'unsafe-inline' fonts.googleapis.com netdna.bootstrapcdn.com),
  #   base_uri: %w('self'),
  #   child_src: %w('self'),
  #   form_action: %w('self'),
  #   frame_ancestors: %w('none'),
  #   plugin_types: %w(),
  #   block_all_mixed_content: true,
  #   report_uri: %w(/uri-directive)
  # }
end
