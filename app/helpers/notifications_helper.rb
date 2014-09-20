module NotificationsHelper
  def notifications_tag(type, icon)
    content_tag :li, class: 'notifications', id: "notifications-#{type}" do
      link_to send(:"#{type}_path"), data: { notifications_type: type, toggle: 'popover', unread: current_user.send(:"unread_#{type}_count"), remote: send(:"unread_#{type}_path", format: :json) } do
        content_tag(:span, nil, class: "notifications-icon fa fa-#{icon}") + content_tag(:span, nil, class: 'unread-count')
      end
    end
  end
end
