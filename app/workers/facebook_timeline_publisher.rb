class FacebookTimelinePublisher
  @queue = :facebook_timeline_queue

  def self.perform(itinerary_id)
    itinerary = Itinerary.find itinerary_id
    itinerary_url = Rails.application.routes.url_helpers.itinerary_url itinerary, host: APP_CONFIG.base_url
    user = itinerary.user
    return unless user.has_facebook_permission?(:publish_stream)
    user.facebook do |fb|
      fb.put_connections 'me', "#{APP_CONFIG.facebook.namespace}:plan", itinerary: itinerary_url
    end
  end
end
