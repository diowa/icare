module NotificationsHelper
  def notification_message(notification)
    actor = User.find(notification.actor_id)
    actor_link = content_tag(:a, actor, href: user_path(actor))
    case notification.class
    when Notifications::HospitalityRequest
      link = content_tag(:a, HospitalityRequest.model_name.human.downcase, href: show_or_edit_incoming_invite(notification.request, notification.incoming_invite))
      t(notification.translation_key, user: actor_link, hospitality_request: link).html_safe
    when Notifications::HospitalityOutgoingInvite
      link = content_tag(:a, HospitalityOutgoingInvite.model_name.human.downcase, href: show_or_edit_outgoing_invite(notification.outgoing_invite))
      t(notification.translation_key, user: actor_link, hospitality_outgoing_invite: link).html_safe
    when Notifications::Reference
      link = content_tag(:a, Reference.model_name.human.downcase, href: edit_incoming_reference_path(notification.reference_id))
      t(notification.translation_key, user: actor_link, reference: link).html_safe
    end
  end

  def notification_icon(notification)
    case notification.class
    when Notifications::HospitalityRequest
      content_tag(:i, nil, class: "icon-plane")
    when Notifications::HospitalityOutgoingInvite
      content_tag(:i, nil, class: "icon-home")
    when Notifications::Reference
      content_tag(:i, nil, class: "icon-thumbs-up")
    end
  end
end
