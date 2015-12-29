class ShareOnFacebookTimelineJob < ActiveJob::Base
  queue_as :share_on_facebook_timeline_queue

  def perform(itinerary_id)
    itinerary = Itinerary.find itinerary_id
    itinerary_url = Rails.application.routes.url_helpers.itinerary_url itinerary, host: APP_CONFIG.base_url
    user = itinerary.user
    return unless user.facebook_permission?(:publish_actions)
    user.facebook do |fb|
      if APP_CONFIG.facebook.restricted_group_id
        fb.put_wall_post itinerary.title,
                         { name: itinerary.title, link: itinerary_url },
                         APP_CONFIG.facebook.restricted_group_id
      else
        fb.put_connections 'me', "#{APP_CONFIG.facebook.namespace}:plan", itinerary: itinerary_url
      end
    end
  end
end
