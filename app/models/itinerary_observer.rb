class ItineraryObserver < Mongoid::Observer
  def after_create(itinerary)
    if itinerary.share_on_facebook_timeline
      Resque.enqueue(FacebookTimelinePublisher, itinerary.id)
    end
  rescue Redis::CannotConnectError
  end
end
