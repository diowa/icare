module ItinerariesHelper
  def boolean_options_for_select
    @boolean_options_for_select ||= options_for_select [[t('boolean.true'), true], [t('boolean.false'), false]]
  end

  def default_leave_date
    @default_leave_date ||= ((Time.now).change(min: (Time.now.min / 10) * 10) + 10.minutes).in_time_zone
  end

  def opengraph_header_content(itinerary)
    fb_namespace = APP_CONFIG.facebook.namespace
    content_for :head do
      html = ''
      html << tag(:meta, property: 'fb:app_id', content: APP_CONFIG.facebook.app_id)
      html << tag(:meta, property: 'og:url', content: itinerary_url(itinerary))
      html << tag(:meta, property: 'og:site_name', content: APP_CONFIG.app_name)
      html << tag(:meta, property: 'og:type', content: "#{fb_namespace}:itinerary")
      html << tag(:meta, property: 'og:title', content: itinerary.title)
      html << tag(:meta, property: 'og:image', content: itinerary.static_map)
      html << tag(:meta, property: 'og:description', content: itinerary.description)
      html << tag(:meta, property: "#{fb_namespace}:route_start_location:latitude", content: itinerary.start_location.lat)
      html << tag(:meta, property: "#{fb_namespace}:route_start_location:longitude", content: itinerary.start_location.lng)
      html << tag(:meta, property: "#{fb_namespace}:route_end_location:latitude", content: itinerary.end_location.lat)
      html << tag(:meta, property: "#{fb_namespace}:route_end_location:longitude", content: itinerary.end_location.lng)
      itinerary.sample_path.map do |point|
        html << tag(:meta, property: "#{fb_namespace}:route_sample_path:latitude", content: point[0])
        html << tag(:meta, property: "#{fb_namespace}:route_sample_path:longitude", content: point[1])
      end
      html.html_safe
    end
  end

  def share_on_facebook_timeline_checkbutton(form)
    has_publish_stream_permission = current_user.has_facebook_permission(:publish_stream)
    if background_jobs_available?
      (form.label :share_on_facebook_timeline, class: "btn btn-facebook btn-checkbox#{' disabled' unless has_publish_stream_permission}" do
        form.default_tag(:check_box, :share_on_facebook_timeline, disabled: !has_publish_stream_permission, checked: has_publish_stream_permission) +
        content_tag(:i, nil, class: 'icon-check-empty check') + ' ' +
        t('helpers.links.share_on_facebook_timeline')
      end) +
      (unless has_publish_stream_permission
        content_tag(:p, class: 'muted') do
          content_tag(:small) do
            content_tag(:i, nil, class: 'icon-ban-circle') + ' ' +
            t('.missing_publish_stream_permission', appname: APP_CONFIG.app_name)
          end
        end
      end)
    else
      t('.share_on_timeline_unavailable', appname: APP_CONFIG.app_name)
    end
  end
end
