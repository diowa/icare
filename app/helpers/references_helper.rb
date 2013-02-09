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
      content_tag :i, nil, class: 'icon-thumbs-down'
    elsif rating == 1
      content_tag :i, nil, class: 'icon-thumbs-up'
    end
  end

  def driver_or_passenger(reference)
    reference.itinerary.user == reference.referencing_user ? t('references.common.driver') : t('references.common.passenger')
  end

  def reference_tags(user)
    html = [:positives, :neutrals, :negatives].map { |reference_type| reference_tag user, reference_type }
    html.join.html_safe
  end

  def new_or_show_reference_path(reference, itinerary)
    reference && reference.persisted? ? user_reference_path(current_user, reference) : new_user_reference_path(current_user, itinerary_id: itinerary.id)
  end

  private
  def reference_tag(user, reference_type)
    content_tag(:span, t("references.snippet.#{reference_type}", count: @user.references.send(reference_type).count))
  end
end
