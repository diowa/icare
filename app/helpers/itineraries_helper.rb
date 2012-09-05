module ItinerariesHelper
  def boolean_options_for_select
    @boolean_options_for_select ||= options_for_select([[t("boolean.true"),true], [t("boolean.false"),false]])
  end
end
