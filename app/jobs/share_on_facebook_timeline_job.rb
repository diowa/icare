# frozen_string_literal: true
class ShareOnFacebookTimelineJob < ActiveJob::Base
  queue_as :share_on_facebook_timeline_queue

  def perform(itinerary)
    itinerary_url = Rails.application.routes.url_helpers.itinerary_url itinerary, host: APP_CONFIG.base_url
    user = itinerary.user
    return unless user.facebook_permission?(:publish_actions)
    user.facebook do |fb|
      fb.put_connections 'me', "#{APP_CONFIG.facebook.namespace}:plan", itinerary: itinerary_url
    end
  end
end
