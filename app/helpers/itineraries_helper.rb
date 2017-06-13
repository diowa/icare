# frozen_string_literal: true

module ItinerariesHelper
  def boolean_options_for_select
    @boolean_options_for_select ||= [[t('boolean.true'), true], [t('boolean.false'), false]]
  end

  def default_leave_date
    @default_leave_date ||= Time.current.change(min: (Time.current.min / 10) * 10) + 10.minutes
  end

  def boolean_tag(value, field)
    status = value ? 'allowed' : 'forbidden'
    content_tag :span, t(".#{field}.#{status}"), class: "tag tag-#{status}"
  end
end
