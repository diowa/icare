class ItineraryObserver < Mongoid::Observer
  def after_create(itinerary)
    if itinerary.share_on_timeline
      Resque.enqueue(FacebookTimelineUpdater, itinerary.id)
    end
  rescue
  end
end
