class ItineraryBuild
  def initialize(params, user)
    @params = params
    @user = user
  end

  def itinerary
    @itinerary ||= build @params, @user
  end

  private
  def build(params, user)
    Itinerary.new(params) do |itinerary|
      set_route_fields itinerary

      itinerary.user = @user

      # Caching some data
      itinerary.driver_gender = @user.gender
      itinerary.verified = @user.facebook_verified
    end
  end

  def set_route_fields(itinerary)
    route = JSON.parse(@params[:route])
    itinerary.start_location    = { lat: route['start_location']['lat'],
                                    lng: route['start_location']['lng'] } if route['start_location']
    itinerary.end_location      = { lat: route['end_location']['lat'],
                                    lng: route['end_location']['lng'] } if route['end_location']
    itinerary.via_waypoints     = route['via_waypoints']
    itinerary.overview_path     = route['overview_path']
    itinerary.overview_polyline = route['overview_polyline']
  rescue
    itinerary.errors.add :route, :invalid
  end
end
