module ItinerariesHelper
  def boolean_options_for_select
    @boolean_options_for_select ||= options_for_select [[t('boolean.true'), true], [t('boolean.false'), false]]
  end

  def default_leave_date
    @default_leave_date ||= ((Time.now).change(min: (Time.now.min / 10) * 10) + 10.minutes).in_time_zone
  end

  def boolean_tag(value, field)
    status = value ? 'allowed' : 'forbidden'
    content_tag :span, t(".#{field}.#{status}"), class: "tag tag-#{status}"
  end

  def share_on_facebook_timeline_checkbutton(form)
    publish_stream_permission = current_user.facebook_permission?(:publish_stream)
    if background_jobs_available?
      (form.label :share_on_facebook_timeline, class: "btn btn-facebook btn-checkbox#{' disabled' unless publish_stream_permission}" do
        form.default_tag(:check_box, :share_on_facebook_timeline, disabled: !publish_stream_permission, checked: publish_stream_permission) +
        content_tag(:span, nil, class: 'fa fa-square-o check') + ' ' +
        Itinerary.human_attribute_name(:share_on_facebook_timeline)
      end) +
      (unless publish_stream_permission
        content_tag(:p, class: 'text-muted') do
          content_tag(:small) do
            content_tag(:span, nil, class: 'fa fa-ban') + ' ' +
            t('.missing_publish_stream_permission', appname: APP_CONFIG.app_name)
          end
        end
      end)
    else
      t('.share_on_timeline_unavailable', appname: APP_CONFIG.app_name)
    end
  end
end
