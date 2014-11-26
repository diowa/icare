module ApplicationHelper

  def title(page_title)
    content_for(:title) { page_title.to_s }
  end

  def yield_or_default(section, default = '')
    content_for?(section) ? content_for(section) + (" | #{APP_CONFIG.app_name}" unless (user_signed_in? || content_for(section) == APP_CONFIG.app_name)) : default
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

  def bootstrap_form_for(object, options = {}, &block)
    options[:builder] = BootstrapFormBuilder
    form_for(object, options, &block)
  end

  def options_for_array_collection(model, attr_name, *args)
    options_for_select("#{model}::#{attr_name.to_s.upcase}".safe_constantize.map { |e| [ model.human_attribute_name("#{attr_name}_#{e}"), e] }, *args)
  end

  def background_jobs_available?
    Resque.workers.any?
  rescue
    false
  end
end
