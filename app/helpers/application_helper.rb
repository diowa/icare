# frozen_string_literal: true

module ApplicationHelper
  def google_maps_api_source
    if APP_CONFIG.google_maps_api_key
      "https://maps.googleapis.com/maps/api/js?libraries=geometry&key=#{APP_CONFIG.google_maps_api_key}"
    else
      'https://maps.googleapis.com/maps/api/js?libraries=geometry'
    end
  end

  def map_config_attributes
    {
      'data-map-center': APP_CONFIG.map.center,
      'data-map-zoom': APP_CONFIG.map.zoom
    }
  end

  def title(page_title)
    content_for(:title) { page_title.to_s }
  end

  def yield_or_default(section, default = '')
    content_for?(section) ? content_for(section) + (" | #{APP_CONFIG.app_name}" unless user_signed_in? || content_for(section) == APP_CONFIG.app_name) : default
  end

  def twitterized_type(type)
    case type
    when 'alert' then 'warning'
    when 'error' then 'danger'
    when 'notice' then 'info'
    else type
    end
  end

  def transparent_gif_image_data
    'data:image/gif;base64,R0lGODlhAQABAIAAAP///wAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=='
  end

  def options_for_array_collection(model, attr_name, *_args)
    "#{model}::#{attr_name.to_s.upcase}".safe_constantize.map { |e| [model.human_attribute_name("#{attr_name}_#{e}"), e] }
  end

  def background_jobs_available?
    Resque.workers.any?
  rescue
    false
  end
end
