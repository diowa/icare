module ItinerariesHelper
  def boolean_options_for_select
    @boolean_options_for_select ||= options_for_select([[t("boolean.true"),true], [t("boolean.false"),false]])
  end

  def opengraph_header_content(itinerary)
    fb_namespace = APP_CONFIG.facebook.namespace
    content_for :head do
      tag(:meta, property: "fb:app_id", content: APP_CONFIG.facebook.app_id) +
      tag(:meta, property: "og:url", content: itinerary_url(itinerary)) +
      tag(:meta, property: "og:site_name", content: APPNAME) +
      tag(:meta, property: "og:type", content: "#{fb_namespace}:itinerary") +
      tag(:meta, property: "og:title", content: itinerary.title) +
      tag(:meta, property: "og:image", content: itinerary.static_map) +
      tag(:meta, property: "og:description", content: itinerary.description) +
      tag(:meta, property: "#{fb_namespace}:route_start_location:latitude", content: itinerary.start_location["lat"]) +
      tag(:meta, property: "#{fb_namespace}:route_start_location:longitude", content: itinerary.start_location["lng"]) +
      tag(:meta, property: "#{fb_namespace}:route_end_location:latitude", content: itinerary.end_location["lat"]) +
      tag(:meta, property: "#{fb_namespace}:route_end_location:longitude", content: itinerary.end_location["lng"]) +
      itinerary.sample_path.map do |point|
        tag(:meta, property: "#{fb_namespace}:route_sample_path:latitude", content: point[0])
        tag(:meta, property: "#{fb_namespace}:route_sample_path:longitude", content: point[1])
      end.join.html_safe
    end
  end
end
