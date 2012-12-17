module NotificationsHelper
  def notification_message(notification)
=begin
    actor = User.find notification.actor_id
    actor_link = content_tag :a, actor, href: user_path(actor)
    case notification.class
    when Notifications
      link = content_tag(:a, HospitalityRequest.model_name.human.downcase, href: show_or_edit_incoming_invite(notification.request, notification.incoming_invite))
      t(notification.translation_key, user: actor_link, hospitality_request: link).html_safe
    end
=end
  end

  def notification_icon(notification)
=begin
    case notification.class
    when Notifications
      content_tag :i, nil, class: 'icon-comment'
    end
=end
  end
end
