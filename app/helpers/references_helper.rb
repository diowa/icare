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

  def new_or_show_reference_path(reference, itinerary)
    reference && reference.persisted? ? user_reference_path(current_user, reference) : new_user_reference_path(current_user, itinerary_id: itinerary.id)
  end
end
