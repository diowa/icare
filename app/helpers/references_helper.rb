module ReferencesHelper
  def make_thumbs(rating)
    case rating
    when -1 then content_tag :i, nil, class: 'icon-thumbs-down'
    when 1 then content_tag :i, nil, class: 'icon-thumbs-up'
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
    content_tag(:div, t("references.snippet.#{reference_type}", count: @user.references.send(reference_type).count), class: 'tag')
  end
end
