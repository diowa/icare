module ReferencesHelper
  RATINGS = {
    rating_negative: { value: -1, icon: 'fa-thumbs-down' },
    rating_neutral: { value: 0 },
    rating_positive: { value: 1, icon: 'fa-thumbs-up' }
  }

  def make_thumbs(rating)
    case rating
    when -1 then content_tag :span, nil, class: 'fa fa-thumbs-down'
    when 1 then content_tag :span, nil, class: 'fa fa-thumbs-up'
    end
  end

  def driver_or_passenger(reference)
    reference.itinerary.user == reference.referencing_user ? t('references.common.driver') : t('references.common.passenger')
  end

  def new_or_show_reference_path(reference, itinerary)
    reference && reference.persisted? ? user_reference_path(current_user, reference) : new_user_reference_path(current_user, itinerary_id: itinerary.id)
  end

  def reference_radio_buttons(form)
    content_tag(:div, class: 'btn-group', data: { toggle: 'buttons' }) do
      RATINGS.each do |field, info|
        concat reference_radio_button(form, field, info)
      end
    end
  end

  def reference_tags(user)
    html = [:positives, :neutrals, :negatives].map { |reference_type| reference_tag user, reference_type }
    html.join.html_safe
  end

  private

  def reference_radio_button(form, field, info)
    form.label :rating, value: info[:value], class: 'btn btn-default' do
      concat form.radio_button(:rating, info[:value])
      concat content_tag(:span, nil, class: "fa #{info[:icon]}") + ' ' if info[:icon]
      concat Reference.human_attribute_name(field)
    end
  end

  def reference_tag(user, reference_type)
    content_tag(:div, t("references.snippet.#{reference_type}", count: user.references.send(reference_type).count), class: 'tag')
  end
end
