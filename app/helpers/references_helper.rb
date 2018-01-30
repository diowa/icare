# frozen_string_literal: true

module ReferencesHelper
  RATINGS = {
    -1 => {
      form_field: 'rating_negative',
      icon:       'fa-frown'
    },
    0  => {
      form_field: 'rating_neutral',
      icon:       'fa-meh'
    },
    1  => {
      form_field: 'rating_positive',
      icon:       'fa-smile'
    }
  }.freeze

  def reference_icon(rating)
    content_tag :span, nil, class: "fas #{RATINGS[rating][:icon]}" if RATINGS.key?(rating)
  end

  def reference_text(rating)
    Reference.human_attribute_name(RATINGS[rating][:form_field]) if RATINGS.key?(rating)
  end

  def driver_or_passenger(reference)
    reference.itinerary.user == reference.referencing_user ? t('references.common.driver') : t('references.common.passenger')
  end

  def new_or_show_reference_path(reference, itinerary)
    reference&.persisted? ? user_reference_path(current_user, reference) : new_user_reference_path(current_user, itinerary_id: itinerary.id)
  end

  def reference_radio_buttons(form)
    content_tag(:div, class: 'btn-group btn-group-toggle', role: 'group', aria: { label: Reference.human_attribute_name(:rating) }, data: { toggle: 'buttons' }) do
      RATINGS.each do |rating, info|
        concat reference_radio_button(form, rating, info)
      end
    end
  end

  def reference_tags(user)
    html = %i[positives neutrals negatives].map { |reference_type| reference_tag user, reference_type }
    safe_join html
  end

  private

  def reference_radio_button(form, rating, info)
    form.label :rating, value: rating, class: 'btn btn-secondary' do
      concat form.radio_button(:rating, rating)
      concat reference_icon(rating) + ' '
      concat Reference.human_attribute_name(info[:form_field])
    end
  end

  def reference_tag(user, reference_type)
    content_tag(:div, t("references.snippet.#{reference_type}", count: user.references.public_send(reference_type).count), class: 'tag')
  end
end
