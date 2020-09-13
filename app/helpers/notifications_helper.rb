# frozen_string_literal: true

module NotificationsHelper
  def notifications_tag(type, icon)
    tag.li class: 'notifications', id: "notifications-#{type}" do
      link_to send(:"#{type}_path"), data: { notifications_type: type, toggle: 'popover', unread: current_user.public_send(:"unread_#{type}_count"), remote: public_send(:"unread_#{type}_path", format: :json) } do
        tag.span(nil, class: "notifications-icon fa fa-#{icon}") + tag.span(nil, class: 'unread-count')
      end
    end
  end
end
