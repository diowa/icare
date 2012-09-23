module ReferencesHelper

  def make_stars(stars, text = true)
    stars = stars.to_i
    return unless stars
    (stars.times.map do
      content_tag(:i, nil, class: "minstrels-star icon-star", title: "*")
    end +
    (5 - stars).times.map do
      content_tag(:i, nil, class: "minstrels-star icon-star-empty")
    end).join.html_safe +
    if text
      content_tag(:small, " #{t("references.stars", count: stars)}").html_safe
    end
  end

  def make_thumbs(rating)
    if rating == -1
      content_tag(:i, nil, class: "icon-thumbs-down")
    elsif rating == 1
      content_tag(:i, nil, class: "icon-thumbs-up")
    end
  end

  def reference_help_text_for(reference)
    if reference.hospitality?
      if reference.is_host
        t(".reference_hosting_help")
      elsif reference.is_guest
        t(".reference_travelling_help")
      end
    end
  end

  def reference_snippet(reference)
    [ make_thumbs(reference.rating),
    " ",
    content_tag(:b) do
      link_to reference.referencing_user, user_path(reference.referencing_user)
    end,
    ": ",
    content_tag(:em) do
     "&laquo;#{reference.message}&raquo;".html_safe
   end,
   " ",
   if reference.is_host
     content_tag(:i, nil, class: "icon-home")
   else
     content_tag(:i, nil, class: "icon-plane")
   end
   ].join.html_safe
  end

  def references_summary_tags(user)
    content_tag(:p, class: "tags") do
      content_tag(:span, "#{user.references.visible.filled_up.positive.size} positive") +
      content_tag(:span, "#{user.references.visible.filled_up.neutral.size} neutral") +
      content_tag(:span, "#{user.references.visible.filled_up.negative.size} negative")
    end
  end

  def reference_status_for(reference)
    if reference.hospitality?
      if reference.is_host
        invites = current_user.hospitality_outgoing_invite_days.where(outgoing_invite_id: reference.experience_id)
        cancelled_invites = invites.where(state: "cancelled")
        accepted_invites = invites.where(state: "accepted")
        declined_invites = invites.where(state: "declined")
        "#{t(".outgoing_invite_status", count: invites.size, name: reference.referencing_user.name)} #{t(".host_outgoing_invites_cancelled", count: cancelled_invites.size)}
         #{t(".host_incoming_invites_accepted", count: accepted_invites.size)} #{t(".host_incoming_invites_declined", count: declined_invites.size)}"
      elsif reference.is_guest
        invites = current_user.hospitality_request_days.where(request_id: reference.experience_id,
                                                              :"incoming_invite_days.inviting_user_id" => reference.referencing_user.id)
        accepted_invites = invites.where(:"incoming_invite_days.inviting_user_id" => reference.referencing_user.id,
                                         :"incoming_invite_days.state" => "accepted")
        declined_invites = invites.where(:"incoming_invite_days.inviting_user_id" => reference.referencing_user.id,
                                         :"incoming_invite_days.state" => "declined")
        cancelled_invites = invites.where(:"incoming_invite_days.inviting_user_id" => reference.referencing_user.id,
                                          :"incoming_invite_days.state" => "cancelled")

        "#{t(".incoming_invite_status", count: invites.size, name: reference.referencing_user.name)} #{t(".guest_incoming_invites_accepted", count: accepted_invites.size)}
         #{t(".guest_incoming_invites_declined", count: declined_invites.size)} #{t(".guest_outgoing_invites_cancelled", count: cancelled_invites.size)}"
      end
    end
  end
  def new_or_show_reference_path(reference, itinerary)
    reference && reference.persisted? ? reference_path(reference) : new_reference_path(itinerary_id: itinerary.id)
  end
end
