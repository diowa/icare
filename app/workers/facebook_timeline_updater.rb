class FacebookTimelineUpdater
  @queue = :facebook_timeline_queue
  def self.perform(itinerary_id)
    itinerary = Itinerary.find(itinerary_id)
    itinerary_url = Rails.application.routes.url_helpers.itinerary_url(itinerary, host: APP_CONFIG.base_url)
    user = itinerary.user
    user.facebook do |fb|
      permissions = fb.get_connections("me", "permissions")
      if permissions[0]["publish_stream"].to_i == 1
        fb.put_connections("me", "#{APP_CONFIG.facebook.namespace}:plan", itinerary: itinerary_url)
      end
    end
  end
end
